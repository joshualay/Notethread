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

#import "NTNoteController.h"

#import "Note.h"
#import "NTThreadWriteViewDelegate.h"

@class NTWriteViewController;

@interface NTNoteViewController : NTNoteController 
                                                    < 
                                                     UITableViewDelegate,
                                                     UITableViewDataSource, 
                                                     NTThreadWriteViewDelegate,
                                                     UITextViewDelegate,
                                                     MFMailComposeViewControllerDelegate,
                                                     UIActionSheetDelegate
                                                     > 


@property (strong, nonatomic) Note *note;

@property (strong, nonatomic) UIToolbar *actionToolbar;
@property (strong, nonatomic) UITableView *threadTableView;
@property (strong, nonatomic) NSArray *noteThreads;

@property (strong, nonatomic) UIBarButtonItem *backButton;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
