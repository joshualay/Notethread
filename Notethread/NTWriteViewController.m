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
    NSLog(@"existingTags - %i", [self->_existingTags count]);
    
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
    NSLog(@"range.location = %i, range.length = %i, replacementText = %@", range.location, range.length, text);
    
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@%@", textView.text, text];
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.navigationBar.topItem.title = @"";
        self.saveButton.enabled = NO;
        
        [self resetTagTracking:NO withTermOrNil:nil];
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];    
        
        return YES;
    }
    
    // deleting
    if (range.length == 1) {
        BOOL isSpaceCharacter = NO;
        
        NSMutableArray *foundCharacters = [[NSMutableArray alloc] init];
        NSUInteger location = range.location - 1;
        while (!isSpaceCharacter) {
            unichar prevChar = [textView.text characterAtIndex:location];
            NSString *prevCharStr = [NSString stringWithFormat:@"%C", prevChar];
            
            if ([prevCharStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
                isSpaceCharacter = YES;
                break;
            }
            
            [foundCharacters addObject:prevCharStr];
            location--;
        }
        
        NSArray *orderedFoundCharacters = [foundCharacters reverseArray];
        NSMutableString *prevWord = [[NSMutableString alloc] initWithCapacity:[orderedFoundCharacters count]];
        for (NSString *str in orderedFoundCharacters) {
            [prevWord appendString:str];
        }
        
        NSArray *tags = [self->_tagService arrayOfTagsInText:prevWord];
        if ([tags count]) {
            NSString *prevTag = [tags objectAtIndex:0];
            [self resetTagTracking:YES withTermOrNil:prevTag];
            
            self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
            
            [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
        }
        
        return YES;
    }
    
    if ([text isEqualToString:@"#"]) {
        [self resetTagTracking:YES withTermOrNil:nil];
  
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
        
        return YES;
    }
    
    if (self->_isEnteringTag) {
        if ([text isEqualToString:@" "]) {
            [self resetTagTracking:NO withTermOrNil:nil];
            [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
            return YES;
        }

        self->_currentTagSearch = [NSString stringWithFormat:@"%@%@", self->_currentTagSearch, text];
        self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
        
        [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
        
        NSLog(@"currentTagSearch - %@", self->_currentTagSearch);
        NSLog(@"matchedTags count - %i", [self->_matchedTags count]);
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
}

#pragma mark - (Private)
- (void)resetTagTracking:(BOOL)isTracking withTermOrNil:(NSString *)term {
    if (term == nil)
        term = @"";
    
    self->_isEnteringTag = isTracking;
    self->_matchedTags = nil;
    self->_currentTagSearch = term;
}

#pragma mark - JLButtonScrollerDelegate
- (UIFont *)fontForButton {
    return [UIFont systemFontOfSize:14.0f];
}

- (NSInteger)numberOfButtons {
    return [self->_matchedTags count];
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    return [UIButton buttonWithType:UIButtonTypeRoundedRect];
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [[self->_matchedTags objectAtIndex:position] name];
}

- (CGFloat)heightForScrollView {
    return 32.0f;
}

@end
