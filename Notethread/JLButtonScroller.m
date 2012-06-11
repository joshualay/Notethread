//
//  JLButtonScroller.m
//
//  Created by Joshua Lay on 7/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//

#import "JLButtonScroller.h"
#import "StyleConstants.h"

@implementation JLButtonScroller

@synthesize delegate;

- (void)addButtonsForContentAreaIn:(UIScrollView *)scrollView {
    scrollView.delegate = nil;
    scrollView.delegate = self;
    
    scrollView.showsVerticalScrollIndicator = NO;
        
    NSInteger maxButtons = [delegate numberOfButtons];
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]])
            [view removeFromSuperview];
        
        if ([view isKindOfClass:[UILabel class]])
            [view setHidden:(maxButtons) ? YES : NO];
    }
    
    if (!maxButtons) {
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                animated:YES];
        return;
    }
    
    UIFont *font = [delegate fontForButton];
    
    NSInteger buttonOffset = 10.0f;
    if ([delegate respondsToSelector:@selector(paddingForButton)]) {
        buttonOffset = [delegate paddingForButton];
    }
    
    
    NSUInteger xBuffer = 4.0f;
    NSInteger xOffset = 5.0f;
    for (int i = 0; i < maxButtons; i++) {
        UIButton *button = [delegate buttonForIndex:i];
        button.titleLabel.font = font;
        
        NSString *text = [delegate stringForIndex:i];
        CGSize stringSize = [text sizeWithFont:font];
        CGFloat stringWidth = stringSize.width + buttonOffset;

        CGFloat heightForButton = stringSize.height;
        if ([delegate respondsToSelector:@selector(heightForButton)])
            heightForButton = [delegate heightForButton];
        
        button.frame = CGRectMake(xOffset, 4.0f, stringWidth, heightForButton);
        
        [button setTitle:text forState:UIControlStateNormal];
        [button setTitle:text forState:UIControlStateHighlighted];
        [button setTitle:text forState:UIControlStateSelected];
        [button setTitle:text forState:UIControlStateDisabled];
        
        if ([delegate respondsToSelector:@selector(setTitleForStateNormalFor:atIndex:)])
            [delegate setTitleForStateNormalFor:button atIndex:i];
        
        if ([delegate respondsToSelector:@selector(setTitleForStateSelectedFor:atIndex:)])
            [delegate setTitleForStateSelectedFor:button atIndex:i];
        
        if ([delegate respondsToSelector:@selector(setTitleForStateHighlightedFor:atIndex:)])
            [delegate setTitleForStateHighlightedFor:button atIndex:i];
        
        if ([delegate respondsToSelector:@selector(setTitleForStateDisabledFor:atIndex:)])
            [delegate setTitleForStateDisabledFor:button atIndex:i];
        
        [scrollView addSubview:button];
        
        xOffset += stringWidth + xBuffer;
    }
    
    [scrollView setContentSize:CGSizeMake(xOffset, [delegate heightForScrollView])];
}

#pragma mark - UIScrollViewDelegate 
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [aScrollView setContentOffset: CGPointMake(aScrollView.contentOffset.x, 0)];
}

@end
