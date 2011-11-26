//
//  StyleApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTWriteViewController.h"

@protocol StyleApplicationServiceDelegate <NSObject>
- (UIFont *)fontNoteWrite;
- (UIFont *)fontNoteView;
- (UIFont *)fontTextLabelPrimary;
- (UIFont *)fontDetailTextLabelPrimary;

- (void)modalStyleForThreadWriteView:(NTWriteViewController *)threadWriteViewController;
- (void)configureNoteTableCell:(UITableViewCell *)cell note:(Note *)note;

- (NSString *)cssForEmail;
@end

@interface StyleApplicationService : NSObject <StyleApplicationServiceDelegate>

+ (StyleApplicationService *)sharedSingleton;

@end
