//
//  EmailApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 24/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "EmailApplicationService.h"
#import "EmailContentApplicationService.h"

@implementation EmailApplicationService

+ (EmailApplicationService *)sharedSingleton {
    static EmailApplicationService *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[EmailApplicationService alloc] init];
        
        return sharedSingleton;
    }
}

- (void)presentMailComposeViewWithNote:(Note *)note forObject:(id)sender {   
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        
        mailController.mailComposeDelegate = sender;
        
        [mailController setSubject:@"From Notethread"];
        
        EmailContentApplicationService *emailContentService = [EmailContentApplicationService sharedSingleton];
        NSString *message = [emailContentService htmlMessageBody:note];
        [mailController setMessageBody:message isHTML:YES];
        
        [sender presentModalViewController:mailController animated:YES];
    }
    else {
        NSLog(@"Error");
    }
}

@end
