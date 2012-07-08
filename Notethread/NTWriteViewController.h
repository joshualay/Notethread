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

@protocol NTWriteViewDelegate <NSObject>
@optional
- (void)willSaveNote;
- (void)didSaveNote;
@end

@interface NTWriteViewController : NTNoteController {
    NSString *_initialNoteText;
}

@property (nonatomic, assign) id<NTWriteViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (assign, nonatomic) NSInteger noteDepth;
@property (strong, nonatomic) Note *parentNote;

/*
 
 Note structure
 --------------
 
 Note: (depth 0)
    noteThreads:
        Note: (depth 1)
            noteThreads:
                Note: (depth 2)

 parent:
    The note that is currently open on screen. 
 
 threadDepth:
    This indicates what the new note's depth will be. In all cases this is going to be
    a simple + 1 to parent.depth. 
 
 TODO: Investigate and determine if threadDepth is required and replace with dynamic solution.
 
 */
- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note;

- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note initialText:(NSString *)text;

- (IBAction)cancelWriting:(id)sender;
- (IBAction)saveNote:(id)sender;

@end
