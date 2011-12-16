//
//  NTNoteListViewController.h
//  Notethread
//
//  Created by Joshua Lay on 16/12/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTNoteViewController;
@class StyleApplicationService;

#import "Note.h"
#import "NTThreadWriteViewDelegate.h"
#import <CoreData/CoreData.h>

@interface NTNoteListViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource,
UISearchDisplayDelegate, UISearchBarDelegate,
NSFetchedResultsControllerDelegate, NTThreadWriteViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

@property (nonatomic, retain) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end
