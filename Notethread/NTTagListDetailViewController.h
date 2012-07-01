//
//  NTTagListDetailViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLButtonScroller.h"

@class StyleApplicationService;
@class Tag;
@class TagService;

@interface NTTagListDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JLButtonScrollerDelegate> {
    Tag *_tag;
    NSArray *_notes;
    
    StyleApplicationService *_styleService;
    
    // Maintaining selected index path so tableView:cellForRowAtIndexPath: can have this knowledge.
    // indexPathForSelectedRow always resolves to the first row for that method.
    NSIndexPath *_selectedIndexPath;
    
    IBOutlet UITableView *_tableView;
    
    // For the bar that appears when a cell is selected
    JLButtonScroller *_buttonScroller;
    NSArray *_filteredTags;
    TagService *_tagService;
}

- (id)initWithTag:(Tag *)tag;

@end
