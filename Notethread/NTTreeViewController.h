//
//  NTTreeViewController.h
//  Notethread
//
//  Created by Joshua Lay on 27/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface NTTreeViewController : UIViewController

@property (nonatomic, strong) Note *note;

- (id)initWithNote:(Note *)note;

@end
