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

- (NSInteger)rowsForThreadTableView;
- (CGRect)frameForThreadViewTable:(CGRect)viewRect noteFrame:(CGRect)noteViewRect withRows:(NSInteger)rowsDisplayed toolBarHeight:(CGFloat)height;
- (CGRect)frameForNoteView:(CGRect)viewRect threadTableOffset:(CGFloat)threadTableHeightOffset;
- (CGRect)frameForActionToolbar:(CGRect)viewRect noteFrame:(CGRect)noteViewRect toolBarHeight:(CGFloat)height;
- (NSArray *)barButtonsForActionToolbar;
- (void)viewForNoteThread;

- (void)emailNotethread;
@end
