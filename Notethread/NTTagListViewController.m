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
#import "StyleApplicationService.h"

@interface NTTagListViewController (CoreData)
- (NSFetchedResultsController *)fetchedResultsController;
- (NSManagedObjectContext *)managedObjectContext;
@end

@interface NTTagListViewController (Selectors)
- (IBAction)dismissView:(id)sender;
@end

@implementation NTTagListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _styleService = [StyleApplicationService sharedSingleton];
        NSMutableArray *tmpTags = [[[self fetchedResultsController] fetchedObjects] mutableCopy];
        [tmpTags sortUsingComparator:^(id tag1, id tag2) {
            Tag *tagOne = (Tag *)tag1;
            Tag *tagTwo = (Tag *)tag2;
            
            if ([tagOne.notes count] < [tagTwo.notes count])
                return (NSComparisonResult)NSOrderedDescending;
            
            if ([tagOne.notes count] > [tagTwo.notes count])
                return (NSComparisonResult)NSOrderedAscending;
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        _tags = [tmpTags copy];
        tmpTags = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"tag list";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
    
    Tag *tag = [self->_tags objectAtIndex:[indexPath row]];
    cell.textLabel.text = tag.name;
    
    // Using the note count as frequency denotes how often the tag is used for all time
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Count: %i", [tag.notes count]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTTagListDetailViewController *detailViewController = [[NTTagListDetailViewController alloc] initWithTag:[self->_tags objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - UITagListViewController(Selectors)
- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


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
        [AlertApplicationService alertViewForCoreDataError:nil];
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
