//
//  NTTagListDetailViewController.h
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tag;

@interface NTTagListDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    Tag *_tag;
    NSArray *_notes;
}

- (id)initWithTag:(Tag *)tag;

@end
