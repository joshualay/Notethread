//
//  NTNoteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>

#import "NTNoteViewController.h"
#import "NTWriteViewController.h"
#import "AlertApplicationService.h"
#import "AppDelegate.h"
#import "UserSettingsConstants.h"
#import "StyleConstants.h"
#import "EmailApplicationService.h"


@interface NTNoteViewController(Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (UIBarButtonItem *)defaultRightBarButtonItem;
- (void)resetNavigationItemFromEditing;
- (NSString *)titleForNote:(NSString *)text;
- (void)willEditNoteTextView:(id)sender;
- (void)navigationBarForNoteEditing;
@end

@interface NTNoteViewController(NoteViewDisplay_and_Actions)
- (void)editingNoteDone:(id)sender;
- (void)editingNoteCancel:(id)sender;

- (NSInteger)rowsForThreadTableView;

- (CGRect)frameForThreadViewTable:(CGRect)viewRect noteFrame:(CGRect)noteViewRect withRows:(NSInteger)rowsDisplayed toolBarHeight:(CGFloat)height;
- (CGRect)frameForNoteView:(CGRect)viewRect threadTableOffset:(CGFloat)threadTableHeightOffset;
- (CGRect)frameForActionToolbar:(CGRect)viewRect noteFrame:(CGRect)noteViewRect toolBarHeight:(CGFloat)height;
- (NSArray *)barButtonsForActionToolbar;
- (void)viewForNoteThread;
@end

@interface NTNoteViewController(ActionSheet)
- (IBAction)presentActionSheetForNote:(id)sender;
- (void)emailNotethread;
- (void)tweetNote;
@end

@interface NTNoteViewController(Keyboard)
- (void)setKeyboardNotificationsObservers;
- (void)removeKeyboardNotificationObservers;
- (void)keyboardWillAppear:(NSNotification *)notification;
- (void)keyboardWillDisappear:(NSNotification *)notification;
- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden;
@end

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteTextView    = _noteTextView;
@synthesize actionToolbar   = _actionToolbar;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;

@synthesize backButton = _backButton;

const CGFloat threadCellRowHeight = 42.0f;


- (id)init {
    self = [super init];
    if (self) {
        self.noteThreads = nil;
    }
    return self;  
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setKeyboardNotificationsObservers];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self.note mergeChanges:YES];
    
    self.noteThreads = nil;
    self.noteThreads = [self.note.noteThreads array];
    [self.threadTableView reloadData];   
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeKeyboardNotificationObservers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return NO;
    
    return YES;
}


#pragma override
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.threadTableView setEditing:editing];
}


#pragma mark - NTNoteViewController(Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.noteThreads objectAtIndex:indexPath.row];
    [self->_styleService configureNoteTableCell:cell note:note];
    
    cell.contentView.backgroundColor   = [UIColor whiteColor];
}

- (UIBarButtonItem *)defaultRightBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Edit Note" style:UIBarButtonItemStylePlain target:self action:@selector(willEditNoteTextView:)];
}

- (void)resetNavigationItemFromEditing {
    self.navigationItem.rightBarButtonItem = [self defaultRightBarButtonItem];
    self.navigationItem.leftBarButtonItem  = self.backButton;
    [self.noteTextView resignFirstResponder];     
}

- (NSString *)titleForNote:(NSString *)text {
    NSRange newLineRange = [text rangeOfString:@"\n"];
    if (newLineRange.location != NSNotFound) {
        NSRange headingRange   = NSMakeRange(0, newLineRange.location);
        
        return [text substringWithRange:headingRange];
    }
    
    return text;
}

- (void)navigationBarForNoteEditing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editingNoteDone:)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingNoteCancel:)];
}

- (void)willEditNoteTextView:(id)sender {
    [self.noteTextView becomeFirstResponder];
    [self navigationBarForNoteEditing];
}


#pragma mark - NTNoteViewController(Keyboard)
- (void)setKeyboardNotificationsObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moveTextViewForKeyboard:(NSNotification *)aNotification keyboardHidden:(BOOL)keyboardHidden {    
    float opacity = 0.0f;
    if (keyboardHidden) {
        self.actionToolbar.hidden = NO;
        self.threadTableView.hidden = NO;
        opacity = 1.0f;
    }
    else {
        self.actionToolbar.hidden = YES;
        self.threadTableView.hidden = YES;
    }
    
    [UIView animateWithDuration:0.7f animations:^{
        self.actionToolbar.layer.opacity = opacity;
        self.threadTableView.layer.opacity = opacity;
    }];
    
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.noteTextView.frame;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    CGFloat kbOriginY      = keyboardEndFrame.origin.y;
    if (keyboardHidden) {
        newFrame.size.height = self.actionToolbar.frame.origin.y;
    }
    else if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
        CGFloat noteViewHeight = self->_tagButtonScrollView.frame.origin.y - newFrame.origin.y;
        CGFloat offset = (self->_tagButtonScrollView.frame.size.height * 1.15) + self.actionToolbar.frame.size.height;
        if (noteViewHeight < kbOriginY) {
            CGFloat diff = kbOriginY - noteViewHeight;
            noteViewHeight += (diff - offset);
        }
        else {
            CGFloat diff = noteViewHeight - kbOriginY;
            noteViewHeight -= (diff + offset);
        }
        newFrame.size.height = noteViewHeight;
    }
    else {
        CGFloat landscapeHeight = 0.33 * screenSize.width;
        newFrame.size   = CGSizeMake(screenSize.height, landscapeHeight - self.noteTextView.inputAccessoryView.frame.size.height);
    }
        
    self.noteTextView.frame = newFrame;
    [UIView commitAnimations];  
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification keyboardHidden:NO];       
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification keyboardHidden:YES];
}


#pragma mark - NTNoteViewController(ActionSheet)
- (IBAction)presentActionSheetForNote:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:@"Email", @"Tweet note", nil];
    
    [actionSheet showInView:self.view];
}

- (void)emailNotethread {
    EmailApplicationService *emailService = [EmailApplicationService sharedSingleton];
    [emailService presentMailComposeViewWithNote:self.note forObject:self];
}

- (void)tweetNote {
    TWTweetComposeViewController *composer = [[TWTweetComposeViewController alloc] init];
    [composer setInitialText:self.note.text];
    [self presentModalViewController:composer animated:YES];
}

#pragma mark - NTNoteViewController(NoteViewDisplay_and_Actions)
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
    self.view.backgroundColor = [self->_styleService blackLinenColor];
    
    NSInteger rowsDisplayed = [self rowsForThreadTableView];
    CGFloat threadTableHeightOffset = ((CGFloat)rowsDisplayed * threadCellRowHeight) + NoteThreadActionToolbarHeight;
    
    CGRect viewRect     = self.view.frame;
    CGRect noteViewRect = [self frameForNoteView:viewRect threadTableOffset:threadTableHeightOffset];
    CGRect tableRect    = [self frameForThreadViewTable:viewRect noteFrame:noteViewRect withRows:rowsDisplayed toolBarHeight:NoteThreadActionToolbarHeight];
    CGRect actionRect   = [self frameForActionToolbar:viewRect noteFrame:noteViewRect toolBarHeight:NoteThreadActionToolbarHeight];

    self.noteTextView.frame = noteViewRect;
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.actionToolbar = [[UIToolbar alloc] initWithFrame:actionRect];
    
    self.noteTextView.font         = [self->_styleService fontNoteView];    
    self.noteTextView.backgroundColor = [self->_styleService paperColor];
    
    self.actionToolbar.tintColor   = [UIColor lightGrayColor];
    self.actionToolbar.translucent = YES;
    
    [self.actionToolbar setItems:[self barButtonsForActionToolbar]];
    [self.view addSubview:self.actionToolbar];
    
    self.actionToolbar.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
    self.threadTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.noteTextView.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
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
    NSInteger threadDepthInteger = [self.note.depth integerValue] + 1;
    
    [self removeKeyboardNotificationObservers];
    NTWriteViewController *threadWriteViewController = [[NTWriteViewController alloc] initWithThreadDepth:threadDepthInteger parent:self.note];
    
    [self->_styleService modalStyleForThreadWriteView:threadWriteViewController];
    
    [self presentModalViewController:threadWriteViewController animated:YES];    
}

- (IBAction)saveNote:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    self.note.text             = self.noteTextView.text;
    self.note.lastModifiedDate = [NSDate date];
    
    NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:self.note.text];
    
    [self->_tagService storeTags:tagsInNote withRelationship:self.note inManagedContext:managedObjectContext];
    
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [super textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (range.location == 0 && [text isEqualToString:@""]) {
        self.title = [self titleForNote:textView.text];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }   
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.title = [self titleForNote:textView.text];
    self.navigationItem.rightBarButtonItem.enabled =  ([textView.text length]) ? YES : NO;
}

#pragma mark @selector
- (void)addButtonTagNameToText:(id)sender {
    [super addButtonTagNameToText:sender];
    [self setTitle:self.noteTextView.text];
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
    switch (buttonIndex) {
        case 0:
            [self emailNotethread];
            break;
        case 1:
            [self tweetNote];
            break;
        default:
            break;
    }
}



@end
