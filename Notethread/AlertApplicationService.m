//
//  AlertApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 22/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "AlertApplicationService.h"

@implementation AlertApplicationService

#pragma Singleton pattern
+ (AlertApplicationService *)sharedSingleton {
    static AlertApplicationService *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[AlertApplicationService alloc] init];
        
        return sharedSingleton;
    }
}


NSString *defaultErrorMessage = @"To revive please push your iPhone's home button and launch again.";
#pragma AlertApplicationServiceDelegate
+ (void)alertViewForCoreDataError:(NSString *)messageOrNil {
    if (messageOrNil == nil)
        messageOrNil = [NSString stringWithString:defaultErrorMessage];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Noteabase got itself tangled up!" 
                                                    message:messageOrNil
                                                   delegate:nil 
                                          cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

+ (void)alertViewForEmailFailure {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending the email failed!" 
                                                    message:@"The emailers must be on strike. Please try again later."
                                                   delegate:nil 
                                          cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
