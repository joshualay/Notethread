//
//  StyleApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StyleApplicationServiceDelegate <NSObject>
- (UIFont *)fontNoteWrite;
- (UIFont *)fontNoteView;
- (UIFont *)fontTextLabelPrimary;
- (UIFont *)fontDetailTextLabelPrimary;
@end

@interface StyleApplicationService : NSObject <StyleApplicationServiceDelegate>

+ (StyleApplicationService *)sharedSingleton;

@end
