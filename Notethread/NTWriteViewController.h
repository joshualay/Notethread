//
//  NTWriteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 9/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "JLButtonScroller.h"

@class NTWriteViewController;
@class TagService;
@class StyleApplicationService;
@class TagTracker;

@interface NTWriteViewController : UIViewController <UITextViewDelegate, JLButtonScrollerDelegate> {
    TagTracker *_tagTracker;
    TagService *_tagService;
    NSArray *_existingTags;
    NSArray *_matchedTags;
    JLButtonScroller *_buttonScroller;
    UIScrollView *_tagButtonScrollView;
}

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (assign, nonatomic) NSInteger noteDepth;
@property (strong, nonatomic) Note *parentNote;

@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

- (id)initWithThreadDepth:(NSInteger)threadDepth parent:(Note *)note;

- (IBAction)cancelWriting:(id)sender;
- (IBAction)saveNote:(id)sender;

@end
