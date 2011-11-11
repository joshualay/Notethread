//
//  NTWriteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol NTWriteDelegate

@required
- (void)saveNoteAtDepth:(NSInteger)depth withParentNote:(Note *)parentNote;
@end

@interface NTWriteViewController : UIViewController <UITextViewDelegate, NTWriteDelegate>

@property (weak, nonatomic) id <NTWriteDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (assign, nonatomic) NSInteger noteDepth;
@property (strong, nonatomic) Note *parentNote;


- (id)initWithDepth:(NSInteger)noteDepth parent:(Note *)note;

- (IBAction)cancelWriting:(id)sender;
- (IBAction)saveNote:(id)sender;

@end
