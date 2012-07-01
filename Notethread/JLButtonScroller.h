//
//  JLButtonScroller.h

//  Created by Joshua Lay on 7/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//
//  Simple class to allow you to add a set of buttons to a UIScrollView

#import <Foundation/Foundation.h>

@protocol JLButtonScrollerDelegate <NSObject>
@required
- (UIFont *)fontForButton;
- (NSInteger)numberOfButtons;
- (UIButton *)buttonForIndex:(NSInteger)position;
- (NSString *)stringForIndex:(NSInteger)position;

@optional
- (void)setTitleForStateNormalFor:(UIButton *)button atIndex:(NSInteger)position;
- (void)setTitleForStateHighlightedFor:(UIButton *)button atIndex:(NSInteger)position;
- (void)setTitleForStateSelectedFor:(UIButton *)button atIndex:(NSInteger)position;
- (void)setTitleForStateDisabledFor:(UIButton *)button atIndex:(NSInteger)position;
- (CGFloat)paddingForButton;
- (CGFloat)heightForButton;
- (CGFloat)heightForScrollView;
@end

@interface JLButtonScroller : NSObject <UIScrollViewDelegate> {
}

@property (nonatomic, assign) id<JLButtonScrollerDelegate> delegate;

- (void)addButtonsForContentAreaIn:(UIScrollView *)scrollView;

@end
