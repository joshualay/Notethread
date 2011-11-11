//
//  NTWriteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@class NTWriteViewController;

@interface NTWriteViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (assign, nonatomic) NSInteger noteDepth;
@property (strong, nonatomic) Note *parentNote;


- (id)initWithDepth:(NSInteger)noteDepth parent:(Note *)note;

- (IBAction)cancelWriting:(id)sender;
- (IBAction)saveNote:(id)sender;

@end
