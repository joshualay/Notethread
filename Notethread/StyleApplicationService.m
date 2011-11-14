//
//  StyleApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "StyleApplicationService.h"

@interface StyleApplicationService()
- (UIFont *)fontDefault;
@end

@implementation StyleApplicationService

#pragma Singleton pattern
+ (StyleApplicationService *)sharedSingleton {
    static StyleApplicationService *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[StyleApplicationService alloc] init];
        
        return sharedSingleton;
    }
}

- (UIFont *)fontDefault {
    return [UIFont fontWithName:@"Georgia" size:17.0f];
}

#pragma StyleApplicationServiceDelegate
- (UIFont *)fontNoteWrite {
    return [self fontDefault];
}

- (UIFont *)fontNoteView {
    return [self fontDefault];
}

- (UIFont *)fontTextLabelPrimary {
    return [UIFont systemFontOfSize:14.0f];
}

- (UIFont *)fontDetailTextLabelPrimary {
    return [UIFont systemFontOfSize:9.0f];
}


@end
