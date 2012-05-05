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


@interface NTWriteViewController(Private) 
- (void)resetTagTracking:(BOOL)isTracking withTermOrNil:(NSString *)term;
- (void)previousWordIsTagDetectionForText:(NSString *)text fromLocation:(NSUInteger)location;
- (void)addButtonTagNameToText:(id)sender;
@end

@implementation NTWriteViewController

@synthesize noteTextView  = _noteTextView;
@synthesize navigationBar = _navigationBar;
@synthesize saveButton    = _saveButton;
@synthesize noteDepth     = _noteDepth;
@synthesize parentNote    = _parentNote;


- (id)initWithDepth:(NSInteger)noteDepth parent:(Note *)note {
    self = [super initWithNibName:@"NTWriteViewController" bundle:nil];
    if (self) {
        _noteDepth  = noteDepth;
        _parentNote = note;
        _tagService = [[TagService alloc] init];
        _isEnteringTag = NO;
    }
    return self;
}

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
    
    self->_tagButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32.0f)];
    self->_tagButtonScrollView.backgroundColor = [UIColor blackColor];
    
    self->_buttonScroller = [[JLButtonScroller alloc] init];
    self->_buttonScroller.delegate = self;
    
    self.noteTextView.inputAccessoryView = self->_tagButtonScrollView;
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
    NSLog(@"tagsInNote - %i", [tagsInNote count]);
    
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
}

#pragma mark - JLButtonScrollerDelegate
- (UIFont *)fontForButton {
    return [UIFont systemFontOfSize:14.0f];
}

- (NSInteger)numberOfButtons {
    return [self->_matchedTags count];
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
    return 32.0f;
}

@end
