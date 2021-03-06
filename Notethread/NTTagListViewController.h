//
//  NTTagListViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StyleApplicationService;
@class TagService;

@interface NTTagListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *__fetchedResultsController;
    NSManagedObjectContext *__managedObjectContext;
    
    StyleApplicationService *_styleService;
    TagService *_tagService;
    
    IBOutlet UITableView *_tableView;
    
    /*
     I cannot use a NSSortDescriptor on the relationship Tag.notes. In order to get around this I have this ivar. 
     When init is called the Tag's are fetched and the the results are sorted by notes count. 
     */
    NSArray *_tags;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
