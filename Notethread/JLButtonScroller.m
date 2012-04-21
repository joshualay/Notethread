//
//  JLButtonScroller.m
//  aporterapp
//
//  Created by Joshua Lay on 7/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//

#import "JLButtonScroller.h"


@implementation JLButtonScroller

@synthesize delegate;

- (void)addButtonsForContentAreaIn:(UIScrollView *)scrollView {
    UIFont *font = [delegate fontForButton];
    
    NSInteger buttonOffset = 10.0f;
    if ([delegate respondsToSelector:@selector(paddingForButton)]) {
        buttonOffset = [delegate paddingForButton];
    }
    
    NSInteger maxButtons = [delegate numberOfButtons];
    
    NSInteger xOffset = 0;
    for (int i = 0; i < maxButtons; i++) {
        UIButton *button = [delegate buttonForIndex:i];
        button.titleLabel.font = font;
        
        NSString *text = [delegate stringForIndex:i];
        CGSize stringSize = [text sizeWithFont:font];
        CGFloat stringWidth = stringSize.width + buttonOffset;

        CGFloat heightForButton = stringSize.height;
        if ([delegate respondsToSelector:@selector(heightForButton)])
            heightForButton = [delegate heightForButton];
        
        button.frame = CGRectMake(xOffset, 0, stringWidth, heightForButton);
        
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
        
        xOffset += stringWidth;
    }
    
    [scrollView setContentSize:CGSizeMake(xOffset, [delegate heightForScrollView])];
}


@end
