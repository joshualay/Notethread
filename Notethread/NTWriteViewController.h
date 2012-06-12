//
//  NTWriteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTNoteController.h"

@class Note;

@interface NTWriteViewController : NTNoteController 

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (assign, nonatomic) NSInteger noteDepth;
@property (strong, nonatomic) Note *parentNote;

- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note;

- (IBAction)cancelWriting:(id)sender;
- (IBAction)saveNote:(id)sender;

@end
