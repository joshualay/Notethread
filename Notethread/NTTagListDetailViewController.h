//
//  NTTagListDetailViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLButtonScroller.h"
#import "NTWriteViewController.h"

@class StyleApplicationService;
@class Tag;
@class TagService;

@interface NTTagListDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JLButtonScrollerDelegate, NTWriteViewDelegate> {
    Tag *_tag;
    NSArray *_notes;
    
    StyleApplicationService *_styleService;
    
    // Maintaining selected index path so tableView:cellForRowAtIndexPath: can have this knowledge.
    // indexPathForSelectedRow always resolves to the first row for that method.
    NSIndexPath *_selectedIndexPath;
    
    IBOutlet UITableView *_tableView;
    
    // For the bar that appears when a cell is selected
    JLButtonScroller *_buttonScroller;
    TagService *_tagService;
    
    // State var to track if this Tag this has been init'd with is a filtered tag or not
    BOOL _isFilteredTag;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Use this - a Tag is required and I've enforced it via the constructor
- (id)initWithTag:(Tag *)tag managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
