//
//  NTNoteController.m
//  Notethread
//
//  Created by Joshua Lay on 29/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NTNoteController.h"

#import "AppDelegate.h"
#import "TagService.h"
#import "TagTracker.h"
#import "StyleApplicationService.h"
#import "StyleConstants.h"

@interface NTNoteController(Private) 
- (IBAction)addTagToNote:(id)sender;
@end

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
    self.noteTextView.keyboardType = UIKeyboardTypeDefault;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObject = [appDelegate managedObjectContext];
    self->_existingTags = nil;
    self->_existingTags = [self->_tagService arrayExistingTagsIn:managedObject];
    self->_tagButtonScrollView = [self->_styleService scrollViewForTagAtPoint:CGPointZero width:self.view.frame.size.width];

    UIButton *addTagButton = [self->_styleService customUIButtonStyle];
    addTagButton.frame =  CGRectMake(5.0f, 2.0f, 30.0f, 26.0f);
    addTagButton.titleLabel.font = [UIFont fontWithName:@"Courier-New-Bold" size:17.0f];
    [addTagButton setTitle:@" # " forState:UIControlStateNormal];
    
    [addTagButton addTarget:self action:@selector(addTagToNote:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect tagLabelRect = CGRectMake(5.0f, 0, self.view.frame.size.width, self->_tagButtonScrollView.frame.size.height);
    UILabel *tagInfoLabel = [self->_styleService labelForTagScrollBarWithFrame:tagLabelRect];
    [tagInfoLabel addSubview:addTagButton];
    [tagInfoLabel setUserInteractionEnabled:YES];
    
    [tagInfoLabel addSubview:addTagButton];
    
    [self->_tagButtonScrollView addSubview:tagInfoLabel];
    
    self->_buttonScroller = [[JLButtonScroller alloc] init];
    self->_buttonScroller.delegate = self;
    
    self.noteTextView.inputAccessoryView = self->_tagButtonScrollView;
}

- (NSString *)titleForNote:(NSString *)text {
    NSRange newLineRange = [text rangeOfString:@"\n"];
    if (newLineRange.location != NSNotFound) {
        NSRange headingRange   = NSMakeRange(0, newLineRange.location);
        
        return [text substringWithRange:headingRange];
    }
    
    return text;
}

- (IBAction)addTagToNote:(id)sender {
    NSRange selectedRange = self.noteTextView.selectedRange;
    NSUInteger insertionLocation = selectedRange.location;
    
    NSInteger tagStartLocation = selectedRange.location;
    if (tagStartLocation < 0)
        tagStartLocation = 0;
    
    NSUInteger enteredLength = 0;
    NSRange range = NSMakeRange(tagStartLocation, enteredLength);
    
    NSMutableString *noteText = [self.noteTextView.text mutableCopy];
    if ([noteText length] == 0 || [noteText length] < (tagStartLocation + enteredLength)) {
        [noteText appendString:@"#"];
        insertionLocation = [noteText length];
    }
    else {
        [noteText replaceCharactersInRange:range withString:@"#"];
    }
    
    // This is so the UITextView doesn't scroll to the bottom when text is changed
    self.noteTextView.scrollEnabled = NO;
    self.noteTextView.text = noteText;
    self.noteTextView.scrollEnabled = YES;
    
    NSUInteger afterHashSymbolLocation = insertionLocation + 1;
    NSRange newRange = NSMakeRange(afterHashSymbolLocation, 0);
    self.noteTextView.selectedRange = newRange;
    
    [self->_tagTracker setIsTracking:YES withTermOrNil:nil];
}

- (void)addButtonTagNameToText:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    NSString *tagString = [button.titleLabel.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSRange selectedRange = self.noteTextView.selectedRange;
    NSUInteger insertionLocation = selectedRange.location;
    
    NSMutableString *noteText = [self.noteTextView.text mutableCopy];
    
    NSString *prevTag = [self->_tagService tagNameOrNilOfPreviousWordInText:noteText fromLocation:insertionLocation];
    NSUInteger enteredLength = [prevTag length];
    NSUInteger tagStartLocation = insertionLocation - enteredLength;
    NSRange range = NSMakeRange(tagStartLocation, enteredLength);
    
    [noteText replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%@ ",tagString]];
    
    self.noteTextView.scrollEnabled = NO;
    self.noteTextView.text = noteText;
    self.noteTextView.scrollEnabled = YES;
    
    NSUInteger newCursorLocation = insertionLocation + [tagString length];
    NSRange newRange = NSMakeRange(newCursorLocation, 0);
    self.noteTextView.selectedRange = newRange;
    
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
    
    NSArray *tagMatchesForCurrentWord = [self->_tagTracker arrayOfMatchedTagsWhenCurrentWordIsTagInText:textView.text fromLocation:location withExistingTags:self->_existingTags];
    
    if (tagMatchesForCurrentWord != nil)
        self->_matchedTags = tagMatchesForCurrentWord;
    else
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
    UIButton *tagButton = [self->_styleService customUIButtonStyle];
    [tagButton addTarget:self action:@selector(addButtonTagNameToText:) forControlEvents:UIControlEventTouchUpInside];
    return tagButton;
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [NSString stringWithFormat:@"#%@", [[self->_matchedTags objectAtIndex:position] name]];
}

- (CGFloat)heightForScrollView {
    return TagScrollViewHeight;
}

- (CGFloat)heightForButton {
    return TagButtonHeight;
}

- (CGFloat)paddingForButton {
    return 12.0f;
}


@end
