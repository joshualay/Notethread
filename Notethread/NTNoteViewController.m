//
//  NTNoteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTNoteViewController.h"
#import "NTWriteViewController.h"
#import "StyleApplicationService.h"
#import "AppDelegate.h"

@interface NTNoteViewController()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (UIBarButtonItem *)defaultRightBarButtonItem;
- (void)editingNoteDone:(id)sender;
- (void)editingNoteCancel:(id)sender;
- (void)resetNavigationItemFromEditing;
- (void)setSortedNoteThreads;
@end

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteTextView    = _noteTextView;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;

@synthesize styleApplicationService = _styleApplicationService;

@synthesize backButton = _backButton;

- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        self.noteThreads = nil;
        self.styleApplicationService = [StyleApplicationService sharedSingleton];
    }
    return self;  
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title             = self.note.text;
    self.noteTextView.text = self.note.text;
    
    CGRect viewRect      = self.view.frame;
    self.noteTextView.frame = CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height / 2.1);
    self.noteTextView.font = [self.styleApplicationService fontNoteView];
    
    CGRect noteLabelRect = self.noteTextView.frame;
    CGFloat tableHeight  = self.view.frame.size.height - noteLabelRect.size.height;
    CGFloat tableWidth   = self.view.frame.size.width;
    CGRect tableRect     = CGRectMake(0, noteLabelRect.size.height + 11.0f, tableWidth, tableHeight);
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    
    self.threadTableView.delegate   = self;
    self.threadTableView.dataSource = self;
        
    [self.view addSubview:self.threadTableView];
    
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.backButton = self.navigationItem.leftBarButtonItem;
    
    [self setSortedNoteThreads];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self.note mergeChanges:YES];
    
    [self setSortedNoteThreads];
    [self.threadTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIBarButtonItem *)defaultRightBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(displayChildThreadWriteViewForActiveNote:)];
}

- (void)editingNoteDone:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    self.note.text = self.noteTextView.text;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    }
    
    [self resetNavigationItemFromEditing];
}

- (void)editingNoteCancel:(id)sender {
    [self resetNavigationItemFromEditing];
}

- (void)resetNavigationItemFromEditing {
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.navigationItem.leftBarButtonItem  = self.backButton;
    [self.noteTextView resignFirstResponder];     
}

- (void)setSortedNoteThreads {
    self.noteThreads = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:FALSE];
    self.noteThreads = [[self.note.noteThreads allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noteThreads == nil)
        return 0;
    
    return [self.noteThreads count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
           
    [self configureCell:cell atIndexPath:indexPath];
    return cell;    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.noteThreads objectAtIndex:indexPath.row];
    [self.styleApplicationService configureNoteTableCell:cell note:note];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        Note *noteThread = [self.noteThreads objectAtIndex:indexPath.row];
        [self.note removeNoteThreadsObject:noteThread];
        [self setSortedNoteThreads];

        [self.threadTableView beginUpdates];
        [self.threadTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.threadTableView endUpdates];
                
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTNoteViewController *noteViewController = [[NTNoteViewController alloc] init];
    
    Note *selectedNote             = [self.noteThreads objectAtIndex:indexPath.row];
    noteViewController.note        = selectedNote;
    noteViewController.noteThreads = [selectedNote.noteThreads allObjects];
    
    [self.navigationController pushViewController:noteViewController animated:YES];
}

#pragma NTThreadWriteViewDelegate
- (void)displayChildThreadWriteViewForActiveNote:(id)sender {
    NSInteger threadDepthInteger = [self.note.depth integerValue] + 1;
    
    NTWriteViewController *threadWriteViewController = [[NTWriteViewController alloc] initWithThreadDepth:threadDepthInteger parent:self.note];
    
    [self.styleApplicationService modalStyleForThreadWriteView:threadWriteViewController];
    
    [self presentModalViewController:threadWriteViewController animated:YES];    
}

#pragma UITextViewDelegate
/*
 - (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
 - (BOOL)textViewShouldEndEditing:(UITextView *)textView;
 
 - (void)textViewDidBeginEditing:(UITextView *)textView;
 - (void)textViewDidEndEditing:(UITextView *)textView;
 
 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
 - (void)textViewDidChange:(UITextView *)textView;
 
 - (void)textViewDidChangeSelection:(UITextView *)textView;
 */

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editingNoteDone:)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingNoteCancel:)];
    return YES;
}

@end
