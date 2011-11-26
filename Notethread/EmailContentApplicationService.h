//
//  EmailContentApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 24/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Note;

@protocol EmailContentApplicationServiceDelegate <NSObject>
- (NSString *)htmlMessageBody:(Note *)note;
@end

@interface EmailContentApplicationService : NSObject <EmailContentApplicationServiceDelegate>

+ (EmailContentApplicationService *)sharedSingleton;

@end
