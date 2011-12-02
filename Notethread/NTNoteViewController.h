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

@class NTWriteViewController;
@class StyleApplicationService;

#import "Note.h"
#import "NTThreadWriteViewDelegate.h"
#import "NTThreadViewDelegate.h"

@interface NTNoteViewController : UIViewController 
                                                    <UITableViewDelegate, 
                                                     UITableViewDataSource, 
                                                     NTThreadWriteViewDelegate, 
                                                     UITextViewDelegate,
                                                     MFMailComposeViewControllerDelegate,
                                                     NTThreadViewDelegate,
                                                     UIActionSheetDelegate>

@property (strong, nonatomic) Note *note;

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) UIToolbar *actionToolbar;
@property (strong, nonatomic) UITableView *threadTableView;
@property (strong, nonatomic) NSArray *noteThreads;

@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

@property (strong, nonatomic) UIBarButtonItem *backButton;

@property (assign) BOOL keyboardIsDisplayed;

@end
