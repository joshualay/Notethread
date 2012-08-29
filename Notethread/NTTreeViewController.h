//
//  NTTreeViewController.h
//  Notethread
//
//  Created by Joshua Lay on 27/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@class Note;

@interface NTTreeViewController : UIViewController <UIScrollViewDelegate, CMPopTipViewDelegate>

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) CMPopTipView *popTipView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (id)initWithNote:(Note *)note;

@end
