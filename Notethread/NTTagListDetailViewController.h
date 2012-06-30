//
//  NTTagListDetailViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StyleApplicationService;
@class Tag;

@interface NTTagListDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    Tag *_tag;
    NSArray *_notes;
    
    StyleApplicationService *_styleService;
    
    // Maintaining selected index path so tableView:cellForRowAtIndexPath: can have this knowledge.
    // indexPathForSelectedRow always resolves to the first row for that method.
    NSIndexPath *_selectedIndexPath;
    
    IBOutlet UITableView *_tableView;
}

- (id)initWithTag:(Tag *)tag;

@end
