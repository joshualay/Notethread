//
//  NTNoteController.m
//  Notethread
//
//  Created by Joshua Lay on 29/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NTNoteController.h"

#import "AppDelegate.h"
#import "TagService.h"
#import "TagTracker.h"
#import "StyleApplicationService.h"
#import "StyleConstants.h"

@implementation NTNoteController

@synthesize noteTextView=_noteTextView;

- (id)init {
    self = [super init];
    if (self) {
        _tagService = [[TagService alloc] init];
        _tagTracker = [[TagTracker alloc] initWithTagService:_tagService];
        _styleService = [StyleApplicationService sharedSingleton];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    self.noteTextView.delegate = self;
    
    self.noteTextView.font = [self->_styleService fontNoteWrite];
    self.noteTextView.inputAccessoryView = [self->_styleService inputAccessoryViewForTextView:self.noteTextView];
    self.noteTextView.keyboardType = UIKeyboardTypeTwitter;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObject = [appDelegate managedObjectContext];
    self->_existingTags = nil;
    self->_existingTags = [self->_tagService arrayExistingTagsIn:managedObject];
    self->_tagButtonScrollView = [self->_styleService scrollViewForTagAtPoint:CGPointZero width:self.view.frame.size.width];

    CGRect tagLabelRect = CGRectMake(5.0f, 0, self.view.frame.size.width, self->_tagButtonScrollView.frame.size.height);
    UILabel *tagInfoLabel = [self->_styleService labelForTagScrollBarWithFrame:tagLabelRect];
    
    [self->_tagButtonScrollView addSubview:tagInfoLabel];
    
    self->_buttonScroller = [[JLButtonScroller alloc] init];
    self->_buttonScroller.delegate = self;
    
    self.noteTextView.inputAccessoryView = self->_tagButtonScrollView;
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
    [noteText appendString:@" "];
    
    self.noteTextView.text = noteText;
    
    // Tidying up
    [self->_tagTracker setIsTracking:NO withTermOrNil:nil];
    self->_matchedTags = nil;
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];   
}


#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {    
    self->_matchedTags = [self->_tagTracker arrayOfMatchedTagsInEnteredText:text inTextView:textView inRange:range withExistingTags:self->_existingTags];
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];    
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSUInteger location = textView.selectedRange.location;
    if (location == 0 || ![textView.text length])
        return;
    
    self->_matchedTags = [self->_tagTracker arrayOfMatchedTagsWhenPreviousWordIsTagInText:textView.text fromLocation:location withExistingTags:self->_existingTags];
    [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
}

#pragma mark - JLButtonScrollerDelegate
- (UIFont *)fontForButton {
    return [self->_styleService fontTagButton];
}

- (NSInteger)numberOfButtons {
    return [self->_matchedTags count];
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    UIButton *tagButton = [self->_styleService buttonForTagScrollView];
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