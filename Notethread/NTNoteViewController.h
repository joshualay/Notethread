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

@interface NTNoteViewController : UIViewController 
                                                    <UITableViewDelegate, 
                                                     UITableViewDataSource, 
                                                     NTThreadWriteViewDelegate, 
                                                     UITextViewDelegate,
                                                     MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Note *note;

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIButton   *emailNoteButton;

@property (strong, nonatomic) UITableView *threadTableView;
@property (strong, nonatomic) NSArray *noteThreads;

@property (strong, nonatomic) StyleApplicationService *styleApplicationService;

@property (strong, nonatomic) UIBarButtonItem *backButton;

- (IBAction)emailNotethread:(id)sender;

@end
