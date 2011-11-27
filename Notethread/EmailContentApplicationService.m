//
//  EmailContentApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 24/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "EmailContentApplicationService.h"
#import "Note.h"
#import "StyleApplicationService.h"

@interface EmailContentApplicationService() 
- (NSString *)htmlNoteThread:(Note *)note currentHtml:(NSString *)currentHtml;
@end

@implementation EmailContentApplicationService

#pragma Singleton pattern
+ (EmailContentApplicationService *)sharedSingleton {
    static EmailContentApplicationService *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[EmailContentApplicationService alloc] init];
        
        return sharedSingleton;
    }
}

- (NSString *)htmlMessageBody:(Note *)note {
    StyleApplicationService *styleService = [StyleApplicationService sharedSingleton];
    NSString *css  = [styleService cssForEmail];
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>", css];
       
    html = [NSString stringWithFormat:@"%@<p>%@</p>", html, note.text];
    html = [self htmlNoteThread:note currentHtml:html];
    
    html = [NSString stringWithFormat:@"%@</body></html>", html];
    
    return html;
}

- (NSString *)htmlNoteThread:(Note *)note currentHtml:(NSString *)currentHtml {   
    NSString *html = [NSString stringWithString:currentHtml];
    
    html = [NSString stringWithFormat:@"%@<ul>", html];
    for (Note *threadNote in note.noteThreads) {
        html = [NSString stringWithFormat:@"%@<li>%@", html, threadNote.text];
        if ([threadNote.noteThreads count]) {
            html = [NSString stringWithFormat:@"%@<ul>", html];
            html = [self htmlNoteThread:threadNote currentHtml:html];
            html = [NSString stringWithFormat:@"%@</ul>", html];
        }
        html = [NSString stringWithFormat:@"%@</li>", html];
    }
    html = [NSString stringWithFormat:@"%@</ul>", html];
    
    return html;
}

@end