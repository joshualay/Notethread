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

@synthesize navigationBar = _navigationBar;
@synthesize saveButton    = _saveButton;
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
    
    self.navigationBar.topItem.title = NSLocalizedString(@"New note", @"New note");

    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.noteTextView.text = [self->_initialNoteText copy];
    NSUInteger textLength = [self->_initialNoteText length];
    if (textLength) {
        self.noteTextView.selectedRange = NSMakeRange(0, 0);
    }
    self->_initialNoteText = nil;
    self.view.backgroundColor = [self->_styleService paperColor];

    self.saveButton.enabled = ([self.noteTextView.text length]) ? YES : NO;
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

- (IBAction)cancelWriting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveNote:(id)sender {
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
    
    CGFloat scrollViewHeight = self->_tagButtonScrollView.frame.size.height;
    newFrame.origin.y = self.navigationBar.frame.size.height;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        CGFloat height = VIEWHEIGHT - keyboardFrame.size.height - self.navigationBar.frame.size.height - scrollViewHeight;
        newFrame.size = CGSizeMake(PORTRAIT_WIDTH, height);
    }
    else {
        CGFloat height = VIEWWIDTH - keyboardFrame.size.width - self.navigationBar.frame.size.height - scrollViewHeight;
        height += scrollViewHeight / 2.7f;
        newFrame.size = CGSizeMake(VIEWHEIGHT, height);
    }
    self.noteTextView.frame = newFrame;
        
    [UIView commitAnimations];  
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification keyboardHidden:NO];       
}


#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {    
    [super textView:textView shouldChangeTextInRange:range replacementText:text];

    self.navigationBar.topItem.title = [self titleForNote:textView.text];
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.navigationBar.topItem.title = @"";
        self.saveButton.enabled = NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    self.navigationBar.topItem.title = [self titleForNote:textView.text];
}


- (void)addButtonTagNameToText:(id)sender {
    [super addButtonTagNameToText:sender];
    self.navigationBar.topItem.title = self.noteTextView.text;
}


@end
