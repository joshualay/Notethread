//
//  NTNoteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NTNoteViewController.h"
#import "NTWriteViewController.h"
#import "StyleApplicationService.h"
#import "AlertApplicationService.h"
#import "AppDelegate.h"
#import "UserSettingsConstants.h"
#import "StyleConstants.h"
#import "EmailApplicationService.h"


@interface NTNoteViewController()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (UIBarButtonItem *)defaultRightBarButtonItem;
- (void)resetNavigationItemFromEditing;
- (NSString *)titleForNote:(NSString *)text;
- (IBAction)presentActionSheetForNote:(id)sender;
- (void)willEditNoteTextView:(id)sender;
- (void)navigationBarForNoteEditing;
- (CGRect)frameForNoteTextViewLandscapeWithViewFrame:(CGRect)viewFrame;
- (void)setKeyboardNotificationsObservers;
- (void)removeKeyboardNotificationObservers;
- (void)keyboardWillAppear:(NSNotification *)notification;
- (void)keyboardWillDisappear:(NSNotification *)notification;
@end

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteTextView    = _noteTextView;
@synthesize actionToolbar   = _actionToolbar;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;

@synthesize styleApplicationService = _styleApplicationService;

@synthesize backButton = _backButton;

@synthesize keyboardIsDisplayed = _keyboardIsDisplayed;

const CGFloat threadCellRowHeight = 40.0f;

- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        self.noteThreads = nil;
        self.styleApplicationService = [StyleApplicationService sharedSingleton];
        
        self.keyboardIsDisplayed = NO;
    }
    return self;  
}

- (void)setKeyboardNotificationsObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeKeyboardNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    if (self.keyboardIsDisplayed == YES)
        return;
    
    self.keyboardIsDisplayed = YES;
    
    NSValue *value = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGRect keyboardRect = [value CGRectValue];
    
    CGFloat adjustedHeight = self.view.frame.size.height - keyboardRect.size.height;
    
    CGRect adjustedNoteRect = CGRectMake(self.noteTextView.frame.origin.x, self.noteTextView.frame.origin.y, self.noteTextView.frame.size.width, adjustedHeight);
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        adjustedNoteRect = [self frameForNoteTextViewLandscapeWithViewFrame:self.view.frame];
    }
    
    [UIView animateWithDuration:0.5f 
                     animations:^{
                         self.noteTextView.frame = adjustedNoteRect;
                         self.actionToolbar.layer.opacity = 0.0f;
                         self.threadTableView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {                                                       
                         self.actionToolbar.hidden = YES;
                         self.threadTableView.hidden = YES;
                     }
     ];    
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    if (self.keyboardIsDisplayed == NO)
        return;
    
    self.keyboardIsDisplayed = NO;
    
    CGRect noteRectAdjusted = self.noteTextView.frame;
    CGFloat heightAnimatedOffset = 2.5f;
    if (noteRectAdjusted.size.height > self.actionToolbar.frame.origin.y)
        noteRectAdjusted.size.height += heightAnimatedOffset;
    else 
        noteRectAdjusted.size.height -= heightAnimatedOffset;
    
    CGRect noteRect = [self frameForNoteView:self.view.frame threadTableOffset:threadCellRowHeight];
    noteRect.size.height = self.actionToolbar.frame.origin.y;
    
    [UIView animateWithDuration:0.3f 
                     animations:^{
                         self.noteTextView.frame = noteRectAdjusted;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3f 
                                          animations:^{
                                              self.noteTextView.frame = noteRect;
                                          }
                                          completion:^(BOOL finished) {
                                              self.actionToolbar.hidden = NO;
                                              self.threadTableView.hidden = NO;
                                              
                                              [UIView animateWithDuration:0.5f 
                                                               animations:^{
                                                                   self.actionToolbar.layer.opacity = 1.0f;
                                                                   self.threadTableView.layer.opacity = 1.0f;
                                                               }
                                               ];
                                          }];
                     }
     ];     
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
    
    self.noteTextView.inputAccessoryView = [self.styleApplicationService inputAccessoryViewForTextView:self.noteTextView];
    
    [self viewForNoteThread];
        
    self.threadTableView.delegate   = self;
    self.threadTableView.dataSource = self;
            
    [self.view addSubview:self.threadTableView];
    
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.backButton = self.navigationItem.leftBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self.note mergeChanges:YES];
    
    self.noteThreads = nil;
    self.noteThreads = [self.note.noteThreads array];
    [self.threadTableView reloadData];   
    
//    [self setKeyboardNotificationsObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    return;
    if (self.keyboardIsDisplayed == NO)
        return;
    
    CGRect viewFrame = self.view.frame;
    CGRect noteFrame = CGRectZero;
    
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        noteFrame = [self frameForNoteTextViewLandscapeWithViewFrame:viewFrame];
        CGRect actionFrame = self.actionToolbar.frame;
        if (self.keyboardIsDisplayed == NO)
            noteFrame.size.height = actionFrame.origin.y;
    }
    else {
        NSInteger rowsDisplayed = [self rowsForThreadTableView];
        //CGFloat threadTableHeightOffset = ((CGFloat)rowsDisplayed * threadCellRowHeight) + NoteThreadActionToolbarHeight;
        CGFloat threadTableHeightOffset = ((CGFloat)rowsDisplayed * threadCellRowHeight);
        noteFrame = [self frameForNoteView:viewFrame threadTableOffset:threadTableHeightOffset];                            
    }
    
    [UIView animateWithDuration:0.3f 
                     animations:^{             
                         self.noteTextView.frame = noteFrame;
                     }];
}

- (UIBarButtonItem *)defaultRightBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Edit Note" style:UIBarButtonItemStylePlain target:self action:@selector(willEditNoteTextView:)];
}

- (void)resetNavigationItemFromEditing {
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.navigationItem.leftBarButtonItem  = self.backButton;
    [self.noteTextView resignFirstResponder];     
}

- (IBAction)presentActionSheetForNote:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
    [actionSheet showInView:self.view];
}

#pragma override
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.threadTableView setEditing:editing];
}


- (void)willEditNoteTextView:(id)sender {
    [self.noteTextView becomeFirstResponder];
    [self navigationBarForNoteEditing];
}

- (void)navigationBarForNoteEditing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editingNoteDone:)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingNoteCancel:)];
}

- (CGRect)frameForNoteTextViewLandscapeWithViewFrame:(CGRect)viewFrame {
    CGFloat offset = (self.keyboardIsDisplayed) ? NoteTextViewLandscapeViewOffset : 0.0;
    return CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height - offset);   
}

#pragma NTThreadViewDelegate
- (void)editingNoteDone:(id)sender {
    if ([self respondsToSelector:@selector(saveNote:)])
        [self saveNote:sender];

    self.title = [self titleForNote:self.noteTextView.text];
    [self resetNavigationItemFromEditing];
}

- (void)editingNoteCancel:(id)sender {
    self.noteTextView.text = self.note.text;
    self.title = [self titleForNote:self.noteTextView.text];
    [self resetNavigationItemFromEditing];
}

- (NSInteger)rowsForThreadTableView {
    NSInteger rowsDisplayed;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    rowsDisplayed = [userDefaults integerForKey:ThreadRowsDisplayedKey];
    
    if (!rowsDisplayed) {
        rowsDisplayed = ThreadRowsDisplayedDefault;
        [userDefaults setInteger:rowsDisplayed forKey:ThreadRowsDisplayedKey];
    }
    
    return rowsDisplayed;
}

- (CGRect)frameForThreadViewTable:(CGRect)viewRect noteFrame:(CGRect)noteViewRect withRows:(NSInteger)rowsDisplayed toolBarHeight:(CGFloat)height {
    CGFloat tableHeight  = viewRect.size.height - noteViewRect.size.height - height;
    CGFloat tableWidth   = viewRect.size.width;
    
    return CGRectMake(0, noteViewRect.size.height + height, tableWidth, tableHeight);    
}

- (CGRect)frameForNoteView:(CGRect)viewRect threadTableOffset:(CGFloat)threadTableHeightOffset {
     return CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height - threadTableHeightOffset);
}

- (CGRect)frameForActionToolbar:(CGRect)viewRect noteFrame:(CGRect)noteViewRect toolBarHeight:(CGFloat)height {
    CGFloat tableWidth   = self.view.frame.size.width;
    
    // The - 1 is so we get a black line to separate from the thread table view
    return CGRectMake(viewRect.origin.x, noteViewRect.size.height, tableWidth, height - 1);
}

- (NSArray *)barButtonsForActionToolbar {
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActionSheetForNote:)];
    actionButton.style = UIBarButtonItemStylePlain; 
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *addNoteThreadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayChildThreadWriteViewForActiveNote:)];
    
    EmailApplicationService *emailService = [EmailApplicationService sharedSingleton];
    if (![emailService deviceCanSendEmail])
        actionButton = flexible;
    
    return [NSArray arrayWithObjects:self.editButtonItem,flexible, actionButton, flexible, addNoteThreadButton, nil];
}

- (void)viewForNoteThread {
    self.view.backgroundColor = [self.styleApplicationService blackLinenColor];
    
    NSInteger rowsDisplayed = [self rowsForThreadTableView];
    CGFloat threadTableHeightOffset = ((CGFloat)rowsDisplayed * threadCellRowHeight) + NoteThreadActionToolbarHeight;
    
    CGRect viewRect     = self.view.frame;
    CGRect noteViewRect = [self frameForNoteView:viewRect threadTableOffset:threadTableHeightOffset];
    CGRect tableRect    = [self frameForThreadViewTable:viewRect noteFrame:noteViewRect withRows:rowsDisplayed toolBarHeight:NoteThreadActionToolbarHeight];
    CGRect actionRect   = [self frameForActionToolbar:viewRect noteFrame:noteViewRect toolBarHeight:NoteThreadActionToolbarHeight];

    self.noteTextView.frame = noteViewRect;
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.actionToolbar = [[UIToolbar alloc] initWithFrame:actionRect];
    
    self.threadTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(viewRect.origin.x, tableRect.origin.y, tableRect.size.width, tableRect.size.height)];
    self.threadTableView.tableFooterView.backgroundColor = [self.styleApplicationService colorForTableFooter];
    
    self.noteTextView.font         = [self.styleApplicationService fontNoteView];    
    self.noteTextView.backgroundColor = [self.styleApplicationService paperColor];
    
    self.actionToolbar.tintColor   = [UIColor lightGrayColor];
    self.actionToolbar.translucent = YES;
    
    [self.actionToolbar setItems:[self barButtonsForActionToolbar]];
    [self.view addSubview:self.actionToolbar];
    
    self.actionToolbar.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
    self.threadTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.noteTextView.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
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
    
    cell.contentView.backgroundColor   = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        Note *noteThread = [self.noteThreads objectAtIndex:indexPath.row];
        NSMutableArray *noteThreads = [[self.note.noteThreads array] mutableCopy];
        [noteThreads removeObject:noteThread];
        
        [self.note setNoteThreads:[NSOrderedSet orderedSetWithArray:noteThreads]];
        
        self.noteThreads = [noteThreads copy];

        [self.threadTableView beginUpdates];
        [self.threadTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.threadTableView endUpdates];
                
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            [AlertApplicationService alertViewForCoreDataError:nil];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSUInteger toRow   = destinationIndexPath.row;
    NSUInteger fromRow = sourceIndexPath.row;
    
    NSMutableArray *threadsMutableArray = [self.noteThreads mutableCopy];
    [threadsMutableArray exchangeObjectAtIndex:fromRow withObjectAtIndex:toRow];
    
    self.noteThreads = [threadsMutableArray copy];
    [self.note setNoteThreads:[NSOrderedSet orderedSetWithArray:self.noteThreads]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:nil];
    }
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTNoteViewController *noteViewController = [[NTNoteViewController alloc] init];
    
    Note *selectedNote             = [self.noteThreads objectAtIndex:indexPath.row];
    noteViewController.note        = selectedNote;
    noteViewController.noteThreads = [selectedNote.noteThreads array];
    
    [self.navigationController pushViewController:noteViewController animated:YES];
}


#pragma NTThreadWriteViewDelegate
- (void)displayChildThreadWriteViewForActiveNote:(id)sender {
    [self removeKeyboardNotificationObservers];
    
    NSInteger threadDepthInteger = [self.note.depth integerValue] + 1;
    
    NTWriteViewController *threadWriteViewController = [[NTWriteViewController alloc] initWithThreadDepth:threadDepthInteger parent:self.note];
    
    [self.styleApplicationService modalStyleForThreadWriteView:threadWriteViewController];
    
    [self presentModalViewController:threadWriteViewController animated:YES];    
}

- (IBAction)saveNote:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    self.note.text             = self.noteTextView.text;
    self.note.lastModifiedDate = [NSDate date];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:nil];
    }    
}

#pragma UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self navigationBarForNoteEditing];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.title = [self titleForNote:textView.text];
    
    self.navigationItem.rightBarButtonItem.enabled =  ([textView.text length]) ? YES : NO;
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
