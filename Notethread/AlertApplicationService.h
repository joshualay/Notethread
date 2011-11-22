//
//  AlertApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 22/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AlertApplicationServiceDelegate <NSObject>

+ (void)alertViewForCoreDataError:(NSString *)messageOrNil;

@end

@interface AlertApplicationService : NSObject <AlertApplicationServiceDelegate>

+ (AlertApplicationService *)sharedSingleton;

@end
