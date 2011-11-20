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

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteLabel       = _noteLabel;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;


- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        _noteThreads = nil;
    }
    return self;  
}

// Not used
- (id)initWithNote:(Note *)note {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        _note = note;
    }
    return self;  
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title          = self.note.text;
    self.noteLabel.text = self.note.text;
    
    //self.noteLabel.frame = self.view.frame;
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    
    [self.noteLabel sizeToFit];
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    self.noteLabel.font = [styleApplicationService fontNoteView];
    
    CGRect noteLabelRect = self.noteLabel.frame;
    CGFloat tableHeight  = self.view.frame.size.height - noteLabelRect.size.height;
    CGFloat tableWidth   = self.view.frame.size.width;
    CGRect tableRect     = CGRectMake(0, noteLabelRect.size.height + 44.0f, tableWidth, tableHeight);
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    
    self.threadTableView.delegate   = self;
    self.threadTableView.dataSource = self;
        
    [self.view addSubview:self.threadTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(displayChildThreadWriteViewForActiveNote:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self.note mergeChanges:YES];
    
    [self.threadTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self.note mergeChanges:YES];
    
    self.noteThreads = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:FALSE];
    self.noteThreads = [[self.note.noteThreads allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.threadTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noteThreads == nil)
        return 0;
    
    return [self.noteThreads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Note *note = [self.noteThreads objectAtIndex:indexPath.row];
    
    cell.textLabel.text = note.text;
    
    return cell;    
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
    
    threadWriteViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    threadWriteViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:threadWriteViewController animated:YES];    
}

@end
