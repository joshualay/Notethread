//
//  MasterViewController.m
//  Notethread
//
//  Created by Joshua Lay on 7/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "MasterViewController.h"

#import "NTNoteViewController.h"
#import "Note.h"
#import "NTWriteViewController.h"
#import "StyleApplicationService.h"
#import "AlertApplicationService.h"
#import "SettingsViewController.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)displayWriteView;
- (void)displaySettingsView;
- (void)initFilteredListContentArrayCapacity;
- (NSMutableArray *)arrayOfNotesMatchingSearch:(NSString *)search inNote:(Note *)note;
- (BOOL)isSearch:(NSString *)term inString:(NSString *)searchingIn;
@end

@implementation MasterViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext     = __managedObjectContext;
@synthesize styleApplicationService  = _styleApplicationService;

@synthesize filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;

const NSInteger rootDepthInteger   = 0;
const NSInteger threadDepthInteger = 1;
const CGFloat   cellHeight         = 51.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Notethread", @"Notethread");
        self.styleApplicationService = [StyleApplicationService sharedSingleton];       

        [self initFilteredListContentArrayCapacity];
        // restore search settings if they were saved in didReceiveMemoryWarning.
        if (self.savedSearchTerm)
        {
            [self.searchDisplayController setActive:self.searchWasActive];
            //[self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
            self.searchDisplayController.searchBar.scopeButtonTitles = nil;
            [self.searchDisplayController.searchBar setText:savedSearchTerm];
            
            self.savedSearchTerm = nil;
        }
    }
    return self;
}
							

- (void)displaySettingsView {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:settingsViewController animated:YES];
}

- (void)initFilteredListContentArrayCapacity {
    self.filteredListContent = [[NSMutableArray alloc] init]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(displaySettingsView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];


    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayWriteView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableView.tableFooterView.backgroundColor = [self.styleApplicationService colorForTableFooter];
    self.tableView.backgroundColor = [self.styleApplicationService paperColor];    
    
    [self.tableView setContentOffset:CGPointMake(0,self.searchDisplayController.searchBar.frame.size.height)];    
}

- (void)viewDidUnload {
    self.filteredListContent = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.filteredListContent count];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTNoteViewController *noteViewController = [[NTNoteViewController alloc] init];
    
    Note *selectedNote = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        selectedNote = [self.filteredListContent objectAtIndex:indexPath.row];
    else
        selectedNote = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    noteViewController.note        = selectedNote;
    noteViewController.noteThreads = [selectedNote.noteThreads array];
    
    [self.navigationController pushViewController:noteViewController animated:YES];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self configureCell:cell atIndexPath:indexPath inTableView:tableView];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            [AlertApplicationService alertViewForCoreDataError:nil];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"depth == %@", [NSNumber numberWithInteger:rootDepthInteger]];
    
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Notethread"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        [AlertApplicationService alertViewForCoreDataError:nil];
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self initFilteredListContentArrayCapacity];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath inTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{     
    Note *note = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        note = [self.filteredListContent objectAtIndex:indexPath.row];
    else 
        note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.styleApplicationService configureNoteTableCell:cell note:note];
}

// Top level note: UIModalTransitionStyleCoverVertical
- (void)displayWriteView {
    NTWriteViewController *writeViewController = [[NTWriteViewController alloc] initWithDepth:0 parent:nil];
    
    writeViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    writeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:writeViewController animated:YES];
}


#pragma MasterViewControllerDelegate

// Any thread created: UIModalTransitionStyleCoverVertical
// Reason we use this is the partial curl does not trigger -(void)viewDidAppear; so we cannot reload the data
- (void)displayChildThreadWriteViewForActiveNote:(UITapGestureRecognizer *)sender {
    NSInteger indexRow     = [[sender view] tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    
    Note *activeNote = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NTWriteViewController *threadWriteViewController = [[NTWriteViewController alloc] initWithThreadDepth:threadDepthInteger parent:activeNote];

    [self.styleApplicationService modalStyleForThreadWriteView:threadWriteViewController];
    
    [self presentModalViewController:threadWriteViewController animated:YES];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
    NSArray *listContent = [self.fetchedResultsController fetchedObjects];
	for (Note *note in listContent)
	{
        NSMutableArray *result = [self arrayOfNotesMatchingSearch:searchText inNote:note];
        if ([result count])
            [self.filteredListContent addObjectsFromArray:result];
	}
}

- (NSMutableArray *)arrayOfNotesMatchingSearch:(NSString *)search inNote:(Note *)note {
    NSMutableArray *matchResults = [[NSMutableArray alloc] init];
    if ([self isSearch:search inString:note.text])
        [matchResults addObject:note];
    
    if ([note.noteThreads count]) {
        for (Note *childNote in note.noteThreads) {
            NSMutableArray *childResult = [self arrayOfNotesMatchingSearch:search inNote:childNote];
            if ([childResult count])
                [matchResults addObjectsFromArray:childResult];
        }
    }
    
    return matchResults;
}

- (BOOL)isSearch:(NSString *)term inString:(NSString *)searchingIn {
    NSRange result = [searchingIn rangeOfString:term options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
    return result.location != NSNotFound;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
