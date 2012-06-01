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
- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden;
@end

@implementation NTWriteViewController

@synthesize navigationBar = _navigationBar;
@synthesize saveButton    = _saveButton;
@synthesize noteDepth     = _noteDepth;
@synthesize parentNote    = _parentNote;

// For the note view sizings
CGFloat const NoteViewOriginY = 49.0f;
CGFloat const NoteViewPortraitSizeWidth = 310.0f;
CGFloat const NoteViewPortraitSizeHeight = 196.0f;
CGFloat const NoteViewLandscapeSizeWidth = 480.0f;
CGFloat const NoteViewLandscapeSizeHeight = 90.0f;


- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note {
    self = [super init];
    if (self) {
        _noteDepth  = threadDepth;
        _parentNote = note;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.noteTextView becomeFirstResponder];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Writing...", @"Writing...");

    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [self->_styleService paperColor];

    self.saveButton.enabled = ([self.noteTextView.text length]) ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setKeyboardNotificationsObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeKeyboardNotificationObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)cancelWriting:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveNote:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    newNote.createdDate = [NSDate date];
    newNote.lastModifiedDate = [NSDate date];
    newNote.depth = [NSNumber numberWithInteger:self.noteDepth];
    newNote.text = self.noteTextView.text;
    
    NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:newNote.text];
    
    [self->_tagService storeTags:tagsInNote withRelationship:newNote inManagedContext:managedObjectContext];
    
    if (self.parentNote != nil) {
        NSMutableArray *noteThreads = [[self.parentNote.noteThreads array] mutableCopy];
        [noteThreads addObject:newNote];
        
        [self.parentNote setNoteThreads:[NSOrderedSet orderedSetWithArray:noteThreads]];
        
        newNote.parentNote = self.parentNote;
        self.parentNote.lastModifiedDate = [NSDate date];
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:nil];
    } 
    
    [self dismissModalViewControllerAnimated:YES];
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
    
    CGRect newFrame = self.noteTextView.frame;

    CGFloat scrollViewHeight = self->_tagButtonScrollView.frame.size.height;
    newFrame.origin.y = NoteViewOriginY;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        newFrame.size = CGSizeMake(NoteViewPortraitSizeWidth, NoteViewPortraitSizeHeight - scrollViewHeight);
    }
    else {
        newFrame.size = CGSizeMake(NoteViewLandscapeSizeWidth, NoteViewLandscapeSizeHeight - scrollViewHeight);
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

    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@%@", textView.text, text];
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.navigationBar.topItem.title = @"";
        self.saveButton.enabled = NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
}


- (void)addButtonTagNameToText:(id)sender {
    [super addButtonTagNameToText:sender];
    self.navigationBar.topItem.title = self.noteTextView.text;
}


@end
