//
//  NTTagListViewController.m
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NTTagListViewController.h"
#import "NTTagListDetailViewController.h"
#import "AlertApplicationService.h"
#import "AppDelegate.h"
#import "Tag.h"
#import "Note.h"
#import "StyleApplicationService.h"
#import "TagService.h"
#import "StyleConstants.h"
#import "UserSettingsConstants.h"

@interface NTTagListViewController (CoreData)
- (NSFetchedResultsController *)fetchedResultsController;
- (NSManagedObjectContext *)managedObjectContext;
@end

@interface NTTagListViewController (Selectors)
- (IBAction)dismissView:(id)sender;
@end

@interface NTTagListViewController (Private)
- (void)loadTagDataStore;
- (NSArray *)arraySortTagList:(NSArray *)tags withFilter:(NSArray *)filterTagNames;
- (NSArray *)arrayFilterTagList:(NSArray *)tags withRemovalFilter:(NSArray *)filterTagNames;
@end

@implementation NTTagListViewController

@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super initWithNibName:@"NTTagListViewController" bundle:nil];
    if (self) {
        _styleService = [StyleApplicationService sharedSingleton];
        _tagService = [[TagService alloc] init];
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Taglist", @"Taglist");

    self->_tableView.backgroundColor = [self->_styleService paperColor];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notethread" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    // TODO
    //UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIButton buttonWithType:UIButtonTypeInfoLight]];
    //self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
    
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTagDataStore];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self->_tableView deselectRowAtIndexPath:[self->_tableView indexPathForSelectedRow] animated:YES];
    [super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NTTagListViewController (Private)
- (NSArray *)arraySortTagList:(NSArray *)tags withFilter:(NSArray *)filterTagNames {
    NSMutableArray *mutableCopy = [tags mutableCopy];
    [mutableCopy sortUsingComparator:^(id tag1, id tag2) {
        Tag *tagOne = (Tag *)tag1;
        Tag *tagTwo = (Tag *)tag2;
        
        /* Tag keyword filtering */
        if ([filterTagNames containsObject:tagOne.name])
            return (NSComparisonResult)NSOrderedDescending;
        
        if ([filterTagNames containsObject:tagTwo.name])
            return (NSComparisonResult)NSOrderedAscending;
        
        
        /* Normal sorting by count */
        if ([tagOne.notes count] < [tagTwo.notes count])
            return (NSComparisonResult)NSOrderedDescending;
        
        if ([tagOne.notes count] > [tagTwo.notes count])
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return mutableCopy;
}

- (NSArray *)arrayFilterTagList:(NSArray *)tags withRemovalFilter:(NSArray *)filterTagNames {
    NSMutableArray *filteredTags = [[NSMutableArray alloc] initWithCapacity:[tags count]];
    
    for (Tag *tag in tags) {  
        if ([filterTagNames containsObject:tag.name]) {
            [filteredTags addObject:tag];
            continue;
        }
        
        NSUInteger filterMatches = 0;
        NSUInteger tagNoteCount = [tag.notes count];
        
        for (NSString *filterTag in filterTagNames) {
            for (Note *tagNote in tag.notes) {
                for (Tag *noteTag in tagNote.tags) {
                    if ([filterTag isEqualToString:noteTag.name]) {
                        filterMatches += 1;
                        break;
                    }
                }
            }
        }
        
        if (filterMatches != tagNoteCount) {
            [filteredTags addObject:tag];
        }
    }   
    
    return filteredTags;
}

- (void)loadTagDataStore {
    NSArray *tagNameFilters = self->_tagService.filteredTags;
    NSArray *fetchedTags = [[self fetchedResultsController] fetchedObjects];
    NSArray *sortedTags = [self arraySortTagList:fetchedTags withFilter:tagNameFilters];    
    fetchedTags = nil;
    
    _tags = [[self arrayFilterTagList:sortedTags withRemovalFilter:tagNameFilters] copy];
    sortedTags = nil;
    
    [self->_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self->_tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
    
    Tag *tag = [self->_tags objectAtIndex:[indexPath row]];
    cell.textLabel.text = tag.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DefaultCellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = [self->_tags objectAtIndex:indexPath.row];
    NTTagListDetailViewController *detailViewController = [[NTTagListDetailViewController alloc] initWithTag:tag managedObjectContext:[self managedObjectContext]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - NTTagListViewController (Selectors)
- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma markt - NTTagListViewController (CoreData)
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];// Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notes.@count > 0"];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:@"NotethreadTags"];
    aFetchedResultsController.delegate = self;
    __fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
	}
    
    return __fetchedResultsController;
}    

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil)
        return __managedObjectContext;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __managedObjectContext = [appDelegate managedObjectContext];
    
    return __managedObjectContext;
}


@end
