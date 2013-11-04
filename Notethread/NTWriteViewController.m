//
//  NTWriteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTWriteViewController.h"
#import "AppDelegate.h"
#import "AlertApplicationService.h"
#import "Note.h"
#import "StyleConstants.h"

@interface NTWriteViewController(Private) 
- (void)setKeyboardNotificationsObservers;
- (void)removeKeyboardNotificationObservers;
- (void)keyboardWillAppear:(NSNotification *)notification;

// When the keyboard displays the note view must be resized. Hooking into keyboard notifications
// provide knowledge of the keyboards frame. This method will use keyboard.frame.origin.y to work 
// out the note view's height.
- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden;
@end

@implementation NTWriteViewController

@synthesize delegate;

@synthesize noteDepth     = _noteDepth;
@synthesize parentNote    = _parentNote;

#define CGRECTSCREEN [[UIScreen mainScreen] bounds]
#define VIEWHEIGHT CGRECTSCREEN.size.height
#define VIEWWIDTH CGRECTSCREEN.size.width

#define PORTRAIT_WIDTH 0.97 * VIEWWIDTH


- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super initWithManagedObjectContext:managedObjectContext];
    if (self) {
        _noteDepth  = threadDepth;
        _parentNote = note;
        _initialNoteText = @"";
    }
    return self;
}

- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note initialText:(NSString *)text managedObjectContext:(NSManagedObjectContext *)managedObjectContext 
{
    self = [self initWithThreadDepth:threadDepth parent:note managedObjectContext:managedObjectContext];
    if (self) {
        _initialNoteText = [text copy];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.noteTextView becomeFirstResponder];
    
    self.title = NSLocalizedString(@"New note", @"New note");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelWriting:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNote:)];

    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.noteTextView.text = [self->_initialNoteText copy];
    NSUInteger textLength = [self->_initialNoteText length];
    if (textLength) {
        self.noteTextView.selectedRange = NSMakeRange(0, 0);
    }
    self->_initialNoteText = nil;
    self.view.backgroundColor = [self->_styleService paperColor];

    self.navigationItem.rightBarButtonItem.enabled = ([self.noteTextView.text length]) ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setKeyboardNotificationsObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeKeyboardNotificationObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)cancelWriting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNote:(id)sender {
    if ([self.delegate respondsToSelector:@selector(willSaveNote)]) {
        [self.delegate willSaveNote];
    }

    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    
    newNote.createdDate = [NSDate date];
    newNote.lastModifiedDate = [NSDate date];
    newNote.depth = [NSNumber numberWithInteger:self.noteDepth];
    newNote.text = self.noteTextView.text;
    
    NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:newNote.text];
    
    [self->_tagService storeTags:tagsInNote withRelationship:newNote inManagedContext:self.managedObjectContext];
    
    if (self.parentNote != nil) {
        NSMutableArray *noteThreads = [[self.parentNote.noteThreads array] mutableCopy];
        [noteThreads addObject:newNote];
        
        [self.parentNote setNoteThreads:[NSOrderedSet orderedSetWithArray:noteThreads]];
        
        newNote.parentNote = self.parentNote;
        self.parentNote.lastModifiedDate = [NSDate date];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
    } 
    
    if ([self.delegate respondsToSelector:@selector(didSaveNote)]) {
        [self.delegate didSaveNote];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setKeyboardNotificationsObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)removeKeyboardNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
    CGRect newFrame = self.noteTextView.frame;
    
    newFrame.origin.y = 0.0f;
    newFrame.size.height = (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) ? keyboardFrame.origin.y : keyboardFrame.origin.x;
    newFrame.size.height -= 10.0f;
    self.noteTextView.frame = newFrame;
        
    [UIView commitAnimations];  
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification keyboardHidden:NO];       
}


#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {    
    [super textView:textView shouldChangeTextInRange:range replacementText:text];

    self.title = [self titleForNote:textView.text];
    self.navigationItem.rightBarButtonItem.enabled = ([textView.text length]) ? YES : NO;
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.title = @"";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = ([textView.text length]) ? YES : NO;
    self.title = [self titleForNote:textView.text];
}


- (void)addButtonTagNameToText:(id)sender {
    [super addButtonTagNameToText:sender];
    self.title = self.noteTextView.text;
}


@end
