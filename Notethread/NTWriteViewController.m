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

@implementation NSArray (reverse)

- (NSArray *)reverseArray {
    NSMutableArray *array =
    [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
@end

@interface NTWriteViewController(Private) 
- (void)resetTagTracking:(BOOL)isTracking withTermOrNil:(NSString *)term;
- (void)previousWordIsTagDetectionForText:(NSString *)text fromLocation:(NSUInteger)location;
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


- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note {
    self = [super initWithNibName:@"NTWriteViewController" bundle:nil];
    if (self) {
        _noteDepth  = threadDepth;
        _parentNote = note;
        _tagService = [[TagService alloc] init];
        _isEnteringTag = NO;
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
    
    self->_tagButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26.0f)];
    self->_tagButtonScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray-tile-tagbar.png"]];
    [self->_tagButtonScrollView setHidden:YES];
    
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

    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        newFrame.origin.y = 49.0f;
        newFrame.size = CGSizeMake(310.0f, 196.0f);
    }
    else {
        newFrame.origin.y = 49.0f;
        newFrame.size = CGSizeMake(480.0f, 90.0f);
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
    
    // Back to the start
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.navigationBar.topItem.title = @"";
        self.saveButton.enabled = NO;
        
        [self resetTagTracking:NO withTermOrNil:nil];
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];    
        
        return YES;
    }
    
    // deleting
    if (range.length == 1) {
        [self previousWordIsTagDetectionForText:textView.text fromLocation:range.location];
        return YES;
    }
    
    // Entering a #tag
    if ([text isEqualToString:@"#"]) {
        [self resetTagTracking:YES withTermOrNil:nil];
  
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
        
        return YES;
    }
    
    // Currently entering a #tag
    if (self->_isEnteringTag) {
        if ([text isEqualToString:@" "]) {
            [self resetTagTracking:NO withTermOrNil:nil];
            [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
            
            return YES;
        }

        self->_currentTagSearch = [NSString stringWithFormat:@"%@%@", self->_currentTagSearch, text];
        self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSUInteger location = textView.selectedRange.location;
    if (location == 0 || ![textView.text length])
        return;
    
    [self previousWordIsTagDetectionForText:textView.text fromLocation:location];
}

#pragma mark - (Private)
- (void)resetTagTracking:(BOOL)isTracking withTermOrNil:(NSString *)term {
    if (term == nil)
        term = @"";
    
    self->_isEnteringTag = isTracking;
    self->_matchedTags = nil;
    self->_currentTagSearch = term;
}

- (void)previousWordIsTagDetectionForText:(NSString *)text fromLocation:(NSUInteger)location {
    NSString *prevTag = [self->_tagService stringTagPreviousWordInText:text fromLocation:location];
    BOOL isTracking = (prevTag == nil) ? NO : YES;
    [self resetTagTracking:isTracking withTermOrNil:prevTag];
    
    if (prevTag != nil)
        self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
    
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];    
}

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
    
    self.noteTextView.text = noteText;
    
    // Tidying up
    self.navigationBar.topItem.title = noteText;
}

#pragma mark - JLButtonScrollerDelegate
- (UIFont *)fontForButton {
    return [UIFont systemFontOfSize:14.0f];
}

- (NSInteger)numberOfButtons {
    NSInteger numberOfButtons = [self->_matchedTags count];
        
    BOOL isHidden = (numberOfButtons) ? NO : YES;
    [self->_tagButtonScrollView setHidden:isHidden];
    
    return numberOfButtons;
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [tagButton addTarget:self action:@selector(addButtonTagNameToText:) forControlEvents:UIControlEventTouchUpInside];
    return tagButton;
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [[self->_matchedTags objectAtIndex:position] name];
}

- (CGFloat)heightForScrollView {
    return 26.0f;
}

- (CGFloat)heightForButton {
    return 24.0f;
}

@end
