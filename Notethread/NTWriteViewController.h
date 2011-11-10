//
//  NTWriteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTWriteViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) UITextView *noteTextView;

@end
