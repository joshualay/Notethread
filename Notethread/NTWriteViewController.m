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
    }
    return self;
}

- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note {
    self = [super initWithNibName:@"NTWriteViewController" bundle:nil];
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
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    
    self.noteTextView.font = [styleApplicationService fontNoteWrite];
    self.noteTextView.inputAccessoryView = [styleApplicationService inputAccessoryViewForTextView:self.noteTextView];
    
    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [styleApplicationService paperColor];

    self.saveButton.enabled = ([self.noteTextView.text length]) ? YES : NO;
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
    
    if (range.location == 0 && [text isEqualToString:@""])
        self.saveButton.enabled = NO;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.saveButton.enabled = ([textView.text length]) ? YES : NO;
}
@end
