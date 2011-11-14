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

@implementation NTWriteViewController

@synthesize noteTextView  = _noteTextView;
@synthesize navigationBar = _navigationBar;
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.noteTextView becomeFirstResponder];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Writing...", @"Writing...");
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    self.noteTextView.font = [styleApplicationService fontNoteWrite];
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
        [self.parentNote addNoteThreadsObject:newNote];
        newNote.parentNote = self.parentNote;
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } 
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@%@", textView.text, text];      
    return YES;
}

@end
