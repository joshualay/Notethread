//
//  StyleApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StyleApplicationService.h"
#import "UserSettingsConstants.h"
#import "StyleConstants.h"
#import "NTWriteViewController.h"
#import "Note.h"

@interface StyleApplicationService(Private)
- (UIFont *)fontDefault;
@end

@implementation StyleApplicationService

@synthesize userDefaults = _userDefaults;

#pragma Singleton pattern
+ (StyleApplicationService *)sharedSingleton {
    static StyleApplicationService *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[StyleApplicationService alloc] init];
        
        return sharedSingleton;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        if (![[self.userDefaults stringForKey:FontFamilyNameDefaultKey] length])
            [self.userDefaults setValue:FontFamilyNameDefault forKey:FontFamilyNameDefaultKey];

        if (![self.userDefaults floatForKey:FontWritingSizeKey])
            [self.userDefaults setFloat:FontWritingSizeDefault forKey:FontWritingSizeKey];
    }
    return self;
}

- (UIFont *)fontDefault {
    return [UIFont fontWithName:[self.userDefaults stringForKey:FontFamilyNameDefaultKey] 
                           size:[self.userDefaults floatForKey:FontWritingSizeKey]];
}

#pragma StyleApplicationServiceDelegate
- (UIFont *)fontNoteWrite {
    return [self fontDefault];
}

- (UIFont *)fontNoteView {
    return [self fontDefault];
}

- (UIFont *)fontTextLabelPrimary {
    return [UIFont fontWithName:[self.userDefaults stringForKey:FontFamilyNameDefaultKey] 
                           size:FontLabelSizeDefault];
}

- (UIFont *)fontDetailTextLabelPrimary {
    return [UIFont systemFontOfSize:11.0f];
}


- (void)modalStyleForThreadWriteView:(NTWriteViewController *)threadWriteViewController {
    threadWriteViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    threadWriteViewController.modalPresentationStyle = UIModalPresentationFormSheet;
}

- (void)configureNoteTableCell:(UITableViewCell *)cell note:(Note *)note {   
    cell.textLabel.text       = nil;
    cell.detailTextLabel.text = nil;
       
    NSString *headingText = note.text;
    NSString *detailText  = @"";
    
    NSRange newLineRange = [note.text rangeOfString:@"\n"];
    if (newLineRange.location != NSNotFound) {
        NSRange headingRange   = NSMakeRange(0, newLineRange.location);
        headingText            = [headingText substringWithRange:headingRange];
        
        NSInteger detailLength = [note.text length] - newLineRange.location;
        NSRange detailRange    = NSMakeRange(newLineRange.location, detailLength);
        detailText             = [note.text substringWithRange:detailRange];
    }
    
    cell.textLabel.text       = headingText;
    cell.detailTextLabel.text = detailText;
    
    cell.textLabel.font       = [self fontTextLabelPrimary];
    cell.textLabel.textColor  = [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.detailTextLabel.font      = [self fontDetailTextLabelPrimary];    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (UIToolbar *)inputAccessoryViewForTextView:(UITextView *)textView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    return toolbar;
}

- (UIColor *)colorForTableFooter {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper.png"]];
}

- (UIColor *)paperColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric_1.png"]];
}

- (UIColor *)blackLinenColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-Linen.png"]];
}

- (UILabel *)labelForTagScrollBarWithFrame:(CGRect)frame {
    UILabel *tagInfoLabel = [[UILabel alloc] initWithFrame:frame];
    //tagInfoLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    //tagInfoLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    tagInfoLabel.backgroundColor = [UIColor clearColor];
    //tagInfoLabel.text = NSLocalizedString(@"Type # to save a tag in your note", @"Adding tag");  
    
    return tagInfoLabel;
}

- (UIScrollView *)scrollViewForTagAtPoint:(CGPoint)point width:(CGFloat)width {
    CGRect tagButtonScrollFrame = CGRectMake(point.x, point.y, width, NoteThreadActionToolbarHeight);
    UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:tagButtonScrollFrame];
    tagScrollView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];  
    return tagScrollView;
}

- (UIFont *)fontTagButton {
    return [UIFont systemFontOfSize:14.0f];
}


- (UIButton *)customUIButtonStyle {
    if (self->_customUIButton == nil) {
        self->_customUIButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self->_customUIButton setTintColor:[UIColor lightTextColor]];
        
        [self->_customUIButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self->_customUIButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        
        [self->_customUIButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self->_customUIButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        self->_customUIButton.backgroundColor = [UIColor darkGrayColor];
        self->_customUIButton.layer.borderColor = [UIColor grayColor].CGColor;
        self->_customUIButton.layer.borderWidth = 0.8f;
        self->_customUIButton.layer.cornerRadius = 3.0f;
    }
    return [self->_customUIButton copy];
}

@end
