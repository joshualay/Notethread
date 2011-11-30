//
//  NTThreadWriteViewDelegate.h
//  Notethread
//
//  Created by Joshua Lay on 16/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTThreadWriteViewDelegate
- (void)displayChildThreadWriteViewForActiveNote:(id)sender;

@optional
- (IBAction)saveNote:(id)sender;
@end
