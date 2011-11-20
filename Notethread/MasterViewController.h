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


@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, NTThreadWriteViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
