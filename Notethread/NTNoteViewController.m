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
#import "AlertApplicationService.h"
#import "AppDelegate.h"
#import "UserSettingsConstants.h"
#import "EmailApplicationService.h"


@interface NTNoteViewController()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (UIBarButtonItem *)defaultRightBarButtonItem;
- (void)resetNavigationItemFromEditing;
- (void)setSortedNoteThreads;
- (NSString *)titleForNote:(NSString *)text;
@end

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteTextView    = _noteTextView;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;

@synthesize styleApplicationService = _styleApplicationService;

@synthesize backButton = _backButton;

const CGFloat threadCellRowHeight = 40.0f;

- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        self.noteThreads = nil;
        self.styleApplicationService = [StyleApplicationService sharedSingleton];
    }
    return self;  
}

- (NSString *)titleForNote:(NSString *)text {
    NSRange newLineRange = [text rangeOfString:@"\n"];
    if (newLineRange.location != NSNotFound) {
        NSRange headingRange   = NSMakeRange(0, newLineRange.location);
        
        return [text substringWithRange:headingRange];
    }
    
    return text;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.title             = [self titleForNote:self.note.text];
    self.noteTextView.text = self.note.text;
    
    [self viewForNoteThread];
        
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
    return nil;
//    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayChildThreadWriteViewForActiveNote:)];
}

- (void)resetNavigationItemFromEditing {
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.navigationItem.leftBarButtonItem  = self.backButton;
    [self.noteTextView resignFirstResponder];     
}

- (void)setSortedNoteThreads {
    self.noteThreads = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:FALSE];
    self.noteThreads = [[self.note.noteThreads allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

#pragma NTThreadViewDelegate
- (void)editingNoteDone:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    self.note.text             = self.noteTextView.text;
    self.note.lastModifiedDate = [NSDate date];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:nil];
    }
    
    [self resetNavigationItemFromEditing];
}

- (void)editingNoteCancel:(id)sender {
    self.noteTextView.text = self.note.text;
    [self resetNavigationItemFromEditing];
}

- (void)viewForNoteThread {
    self.view.backgroundColor = [UIColor blackColor];
    
    NSInteger rowsDisplayed;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    rowsDisplayed = [userDefaults integerForKey:ThreadRowsDisplayedKey];
    
    if (!rowsDisplayed) {
        rowsDisplayed = ThreadRowsDisplayedDefault;
        [userDefaults setInteger:rowsDisplayed forKey:ThreadRowsDisplayedKey];
    }
    
    CGFloat heightOffset = 28.0f;
    CGFloat threadTableHeightOffset = ((CGFloat)rowsDisplayed * threadCellRowHeight) + heightOffset;
    
    CGRect viewRect      = self.view.frame;
    self.noteTextView.frame = CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height - threadTableHeightOffset);
    self.noteTextView.font = [self.styleApplicationService fontNoteView];    
    
    CGRect noteLabelRect = self.noteTextView.frame;
    CGFloat tableHeight  = self.view.frame.size.height - noteLabelRect.size.height - heightOffset;
    CGFloat tableWidth   = self.view.frame.size.width;
    CGRect tableRect     = CGRectMake(0, noteLabelRect.size.height + heightOffset, tableWidth, tableHeight);
    
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    
    UIToolbar *actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(viewRect.origin.x, noteLabelRect.size.height, tableWidth, heightOffset - 1)];
    
    actionToolbar.tintColor   = [UIColor lightGrayColor];
    actionToolbar.translucent = YES;
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActionSheetForNote:)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *addNoteThreadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayChildThreadWriteViewForActiveNote:)];
    
    actionButton.style = UIBarButtonItemStylePlain;
    [actionToolbar setItems:[NSArray arrayWithObjects:actionButton,flexible,addNoteThreadButton,nil]];
    [self.view addSubview:actionToolbar];
    
    
    actionToolbar.autoresizingMask        = UIViewAutoresizingFlexibleWidth;
    self.threadTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.noteTextView.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
}

- (IBAction)presentActionSheetForNote:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
    [actionSheet showInView:self.view];
}

- (void)emailNotethread {
    EmailApplicationService *emailService = [EmailApplicationService sharedSingleton];
    [emailService presentMailComposeViewWithNote:self.note forObject:self];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noteThreads == nil)
        return 0;
    
    return [self.noteThreads count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return threadCellRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Small";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
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
            [AlertApplicationService alertViewForCoreDataError:nil];
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
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editingNoteDone:)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingNoteCancel:)];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.title = [self titleForNote:textView.text];
}

#pragma MFMailComposeViewControllerDelegate
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self dismissModalViewControllerAnimated:YES];
      
    switch (result)
    {
        case MFMailComposeResultFailed:
            [AlertApplicationService alertViewForEmailFailure];
            break;
        default:
            break;
    }
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self emailNotethread];
    }
}



@end
