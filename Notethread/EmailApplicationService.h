//
//  EmailApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 24/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@class Note;

@protocol EmailApplicationServiceDelegate <NSObject>

- (void)presentMailComposeViewWithNote:(Note *)note forObject:(id)sender;

@end


@interface EmailApplicationService : NSObject <EmailApplicationServiceDelegate>

+ (EmailApplicationService *)sharedSingleton;

@end
