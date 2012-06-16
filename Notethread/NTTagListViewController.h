//
//  NTTagListViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StyleApplicationService;

@interface NTTagListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *__fetchedResultsController;
    NSManagedObjectContext *__managedObjectContext;
    
    StyleApplicationService *_styleService;
}

@end
