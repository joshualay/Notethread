//
//  NTNoteViewController.h
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Note.h"
#import "NTThreadWriteViewDelegate.h"
#import "NTThreadViewDelegate.h"
#import "JLButtonScroller.h"

@class NTWriteViewController;
@class StyleApplicationService;
@class TagService;
@class TagTracker;

@interface NTNoteViewController : UIViewController 
                                                    <UITableViewDelegate, UITableViewDataSource, 
                                                     NTThreadWriteViewDelegate, NTThreadViewDelegate,
                                                     UITextViewDelegate,
                                                     MFMailComposeViewControllerDelegate,
                                                     UIActionSheetDelegate,
                                                     JLButtonScrollerDelegate> 
{
    TagService *_tagService;
    TagTracker *_tagTracker;
    NSArray *_matchedTags;
    JLButtonScroller *_buttonScroller;
    NSArray *_existingTags;
    UIScrollView *_tagButtonScrollView;
}

@property (strong, nonatomic) Note *note;

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) UIToolbar *actionToolbar;
@property (strong, nonatomic) UITableView *threadTableView;
@property (strong, nonatomic) NSArray *noteThreads;

@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

@property (strong, nonatomic) UIBarButtonItem *backButton;

@end
