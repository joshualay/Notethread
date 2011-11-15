//
//  NTNoteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Note.h"

@interface NTNoteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Note *note;
@property (strong, nonatomic) IBOutlet UILabel *noteLabel;
@property (strong, nonatomic) UITableView *threadTableView;
@property (strong, nonatomic) NSArray *noteThreads;

- (id)initWithNote:(Note *)note;

@end
