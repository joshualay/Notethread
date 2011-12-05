//
//  MasterViewController.h
//  Notethread
//
//  Created by Joshua Lay on 7/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTNoteViewController;
@class StyleApplicationService;

#import "Note.h"
#import "NTThreadWriteViewDelegate.h"
#import <CoreData/CoreData.h>


@interface MasterViewController : UITableViewController 
<NSFetchedResultsControllerDelegate, NTThreadWriteViewDelegate,UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

@property (nonatomic, retain) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end
