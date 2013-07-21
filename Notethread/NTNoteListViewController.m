//
//  NTNoteListViewController.m
//  Notethread
//
//  Created by Joshua Lay on 16/12/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTNoteListViewController.h"

#import "NTNoteViewController.h"
#import "Note.h"
#import "Tag.h"
#import "NTWriteViewController.h"
#import "StyleApplicationService.h"
#import "AlertApplicationService.h"
#import "SettingsViewController.h"
#import "NTTagListViewController.h"
#import "StyleConstants.h"


@interface NTNoteListViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)displayWriteView;
@end

// Buttons on the toolbar of the page - see NTNoteListViewController.xib
@interface NTNoteListViewController (Selectors)
- (IBAction)displaySettingsView;
- (IBAction)displayTagListView:(id)sender;
@end

// Search looks like it's a bit more complex than it really is. Since I'm searching just notes and also tags
// 
// I require different ways to:
//  * Search for the entered text
//  * Retrieving the notes to present
@interface NTNoteListViewController (SearchBar)
- (void)initFilteredListContentArrayCapacity;
- (NSMutableArray *)arrayOfNotesMatchingSearch:(NSString *)search inNote:(Note *)note;
- (NSMutableArray *)arrayOfNotesThatHaveTag:(NSString *)search inNote:(Note *)note;
- (BOOL)isSearch:(NSString *)term inString:(NSString *)searchingIn;
- (BOOL)isSearch:(NSString *)term matchesFromStartString:(NSString *)searchingIn;
- (BOOL)tagsInNote:(Note *)note haveSearchTerm:(NSString *)search;
- (NSArray *)arrayOfNotesTagMatchingInChildNotesOf:(Note *)note haveSearchTerm:(NSString *)search;
- (NSArray *)arrayOfNotesTextMatchingInChildNotesOf:(Note *)note haveSearchTerm:(NSString *)search;
@end

@implementation NTNoteListViewController

@synthesize tableView = _tableView;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext     = __managedObjectContext;
@synthesize styleApplicationService  = _styleApplicationService;

@synthesize filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;

// Core data has a flat object model. If I look for all Notes I will get top level and all of the 
// children as well. This value is to specify that I only care about top level notes.
const NSInteger rootDepthInteger   = 0;
// Used by NTWriteViewController, all notes at depth 0 will have child notes at depth 1. 
// When the user taps on a row, any new childthreads created are going to be at this depth.
const NSInteger threadDepthInteger = 1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Notethread", @"Notethread");
        self.styleApplicationService = [StyleApplicationService sharedSingleton];   
        
        [self initFilteredListContentArrayCapacity];
    }
    return self;
}

#pragma mark - NTNoteListViewController(Selectors)
- (IBAction)displaySettingsView {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)displayTagListView:(id)sender {
    NTTagListViewController *tagListViewController = [[NTTagListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagListViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navController animated:YES];
}


- (void)initFilteredListContentArrayCapacity {
    self.filteredListContent = [[NSMutableArray alloc] init]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIExtendedEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayWriteView)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.tableView.backgroundColor = [self.styleApplicationService paperColor];
    self.searchDisplayController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"All", @"All"), NSLocalizedString(@"Tags", @"Tags")];
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
    NTNoteViewController *noteViewController = [[NTNoteViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
    noteViewController.edgesForExtendedLayout = UIExtendedEdgeNone;
    
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
            [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DefaultCellHeight;
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
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Notethread"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
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
    NTWriteViewController *writeViewController = [[NTWriteViewController alloc] initWithThreadDepth:0 parent:nil managedObjectContext:self.managedObjectContext];
    
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
    NTWriteViewController *threadWriteViewController = [[NTWriteViewController alloc] initWithThreadDepth:threadDepthInteger parent:activeNote managedObjectContext:self.managedObjectContext];
    
    [self.styleApplicationService modalStyleForThreadWriteView:threadWriteViewController];
    
    [self presentModalViewController:threadWriteViewController animated:YES];
}

#pragma mark - NTNoteListViewController (SearchBar)
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
    NSArray *listContent = [self.fetchedResultsController fetchedObjects];
	for (Note *note in listContent)
	{
        NSMutableArray *result = nil;
        if ([[scope lowercaseString] isEqualToString:@"tags"])
            result = [self arrayOfNotesThatHaveTag:searchText inNote:note];
        else
            result = [self arrayOfNotesMatchingSearch:searchText inNote:note];
        
        if ([result count])
            [self.filteredListContent addObjectsFromArray:result];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self filterContentForSearchText:searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}

- (NSMutableArray *)arrayOfNotesMatchingSearch:(NSString *)search inNote:(Note *)note {
    NSMutableArray *matchResults = [[NSMutableArray alloc] init];
    if ([self isSearch:search inString:note.text])
        [matchResults addObject:note];
    
    [matchResults addObjectsFromArray:[self arrayOfNotesTextMatchingInChildNotesOf:note haveSearchTerm:search]];
    
    return matchResults;
}

- (NSMutableArray *)arrayOfNotesThatHaveTag:(NSString *)search inNote:(Note *)note {
    NSMutableArray *matchResults = [[NSMutableArray alloc] init];
    if ([note.tags count] && [self tagsInNote:note haveSearchTerm:search]) {
        [matchResults addObject:note];
    }
    
    [matchResults addObjectsFromArray:[self arrayOfNotesTagMatchingInChildNotesOf:note haveSearchTerm:search]];
    
    return matchResults;    
}

/* 
 For the search methods there's a little complexity incurred due to the relationships
 
 Note: (depth 0)
    noteThreads:
        Note: (depth 1)
            noteThreads:
                Note: (depth 2)
        Note: (depth 1)
            noteThreads:
                Note: (depth 2)
                    noteThreads:
                        Note: (depth 3)
 
 I have a list of Notes at depth 0. In order to search for text in all notes I have to traverse down the tree. 
 The same concept works with tags as well.
 
 */
- (NSArray *)arrayOfNotesTextMatchingInChildNotesOf:(Note *)note haveSearchTerm:(NSString *)search {
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    if ([note.noteThreads count]) {
        for (Note *childNote in note.noteThreads) {
            if ([self isSearch:search inString:childNote.text])
                [matches addObject:childNote];
                        
            NSArray *otherMatches = [self arrayOfNotesTextMatchingInChildNotesOf:childNote haveSearchTerm:search];
            if ([otherMatches count])
                [matches addObjectsFromArray:otherMatches];
            
            otherMatches = nil;
        }
        return matches;
    }
    return matches;
}

- (NSArray *)arrayOfNotesTagMatchingInChildNotesOf:(Note *)note haveSearchTerm:(NSString *)search {
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    if ([note.noteThreads count]) {
        for (Note *childNote in note.noteThreads) {
            if ([self tagsInNote:childNote haveSearchTerm:search])
                [matches addObject:childNote];
            
            NSArray *otherMatches = [self arrayOfNotesTagMatchingInChildNotesOf:childNote haveSearchTerm:search];
            if ([otherMatches count])
                [matches addObjectsFromArray:otherMatches];
            
            otherMatches = nil;
        }
        return matches;
    }
    return matches;
}

- (BOOL)tagsInNote:(Note *)note haveSearchTerm:(NSString *)search {
    if (![search length])
        return NO;
    
    // In case the user wants to include the # symbol. Remove it.
    search = [[search substringWithRange:NSMakeRange(0, [search length])] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    for (Tag *tag in note.tags) {
        if ([self isSearch:search matchesFromStartString:tag.name])
            return YES;
    }    
    
    return NO;
}

- (BOOL)isSearch:(NSString *)term inString:(NSString *)searchingIn {
    NSRange result = [searchingIn rangeOfString:term options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
    return result.location != NSNotFound;
}

- (BOOL)isSearch:(NSString *)term matchesFromStartString:(NSString *)searchingIn {
    NSRange result = [searchingIn rangeOfString:term options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
    return result.location == 0;
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

// To override the behaviour of self.editButtonItem
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing];
}

@end
