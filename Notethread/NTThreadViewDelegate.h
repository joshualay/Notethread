//
//  NTThreadViewDelegate.h
//  Notethread
//
//  Created by Joshua Lay on 27/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTThreadViewDelegate
- (void)editingNoteDone:(id)sender;
- (void)editingNoteCancel:(id)sender;
- (void)viewForNoteThread;

- (void)emailNotethread;
- (IBAction)presentActionSheetForNote:(id)sender;
@end
