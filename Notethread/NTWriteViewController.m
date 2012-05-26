//
//  NTWriteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTWriteViewController.h"
#import "AppDelegate.h"
#import "StyleApplicationService.h"
#import "AlertApplicationService.h"
#import "TagService.h"
#import "TagTracker.h"
#import "StyleConstants.h"
#import "NSArray+Reverse.h"

@interface NTWriteViewController(Private) 
- (void)addButtonTagNameToText:(id)sender;
- (void)setKeyboardNotificationsObservers;
- (void)removeKeyboardNotificationObservers;
- (void)keyboardWillAppear:(NSNotification *)notification;
- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden;
@end

@implementation NTWriteViewController

@synthesize noteTextView  = _noteTextView;
@synthesize navigationBar = _navigationBar;
@synthesize saveButton    = _saveButton;
@synthesize noteDepth     = _noteDepth;
@synthesize parentNote    = _parentNote;

@synthesize styleApplicationService = _styleApplicationService;

// For the note view sizings
CGFloat const NoteViewOriginY = 49.0f;
CGFloat const NoteViewPortraitSizeWidth = 310.0f;
CGFloat const NoteViewPortraitSizeHeight = 196.0f;
CGFloat const NoteViewLandscapeSizeWidth = 480.0f;
CGFloat const NoteViewLandscapeSizeHeight = 90.0f;


- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note {
    self = [super initWithNibName:@"NTWriteViewController" bundle:nil];
    if (self) {
        _noteDepth  = threadDepth;
        _parentNote = note;
        _tagService = [[TagService alloc] init];
        _styleApplicationService = [StyleApplicationService sharedSingleton];
        _tagTracker = [[TagTracker alloc] initWithTagService:_tagService];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.noteTextView becomeFirstResponder];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Writing...", @"Writing...");
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    
    self.noteTextView.font = [styleApplicationService fontNoteWrite];
    self.noteTextView.inputAccessoryView = [styleApplicationService inputAccessoryViewForTextView:self.noteTextView];
    self.noteTextView.keyboardType = UIKeyboardTypeTwitter;
    
    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [styleApplicationService paperColor];

    self.saveButton.enabled = ([self.noteTextView.text length]) ? YES : NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObject = [appDelegate managedObjectContext];
    self->_existingTags = nil;
    self->_existingTags = [self->_tagService arrayExistingTagsIn:managedObject];
    
    self->_tagButtonScrollView = [self.styleApplicationService scrollViewForTagAtPoint:CGPointZero width:self.view.frame.size.width];

    CGRect tagLabelRect = CGRectMake(5.0f, 0, self.view.frame.size.width, self->_tagButtonScrollView.frame.size.height);
    UILabel *tagInfoLabel = [styleApplicationService labelForTagScrollBarWithFrame:tagLabelRect];
    
    [self->_tagButtonScrollView addSubview:tagInfoLabel];
        
    self->_buttonScroller = [[JLButtonScroller alloc] init];
    self->_buttonScroller.delegate = self;
    
    self.noteTextView.inputAccessoryView = self->_tagButtonScrollView;
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
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@%@", textView.text, text];
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.navigationBar.topItem.title = @"";
        self.saveButton.enabled = NO;
    }
    
    self->_matchedTags = [self->_tagTracker arrayOfMatchedTagsInEnteredText:text inTextView:textView inRange:range withExistingTags:self->_existingTags];
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];    
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSUInteger location = textView.selectedRange.location;
    if (location == 0 || ![textView.text length])
        return;

    self->_matchedTags = [self->_tagTracker arrayOfMatchedTagsWhenPreviousWordIsTagInText:textView.text fromLocation:location withExistingTags:self->_existingTags];
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
}

#pragma mark - (Private)
- (void)addButtonTagNameToText:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    NSString *tagString = button.titleLabel.text;
    NSUInteger insertionLocation = self.noteTextView.selectedRange.location;
        
    NSMutableString *noteText = [self.noteTextView.text mutableCopy];
    
    NSString *prevTag = [self->_tagService stringTagPreviousWordInText:noteText fromLocation:insertionLocation];
    NSUInteger enteredLength = [prevTag length];
    NSUInteger tagStartLocation = insertionLocation - enteredLength;
    NSRange range = NSMakeRange(tagStartLocation, enteredLength);
    
    [noteText replaceCharactersInRange:range withString:tagString];
    [noteText appendString:@" "];
    
    self.noteTextView.text = noteText;
    
    // Tidying up
    self.navigationBar.topItem.title = noteText;
    [self->_tagTracker setIsTracking:NO withTermOrNil:nil];
    self->_matchedTags = nil;
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
}

#pragma mark - JLButtonScrollerDelegate
- (UIFont *)fontForButton {
    return [self.styleApplicationService fontTagButton];
}

- (NSInteger)numberOfButtons {
    return [self->_matchedTags count];
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    UIButton *tagButton = [self.styleApplicationService buttonForTagScrollView];
    [tagButton addTarget:self action:@selector(addButtonTagNameToText:) forControlEvents:UIControlEventTouchUpInside];
    return tagButton;
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [[self->_matchedTags objectAtIndex:position] name];
}

- (CGFloat)heightForScrollView {
    return TagScrollViewHeight;
}

- (CGFloat)heightForButton {
    return TagButtonHeight;
}

@end
