//
//  StyleApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "StyleApplicationService.h"
#import "UserSettingsConstants.h"
#import "StyleConstants.h"
#import "NTWriteViewController.h"
#import "Note.h"

@interface StyleApplicationService()
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
    tagInfoLabel.font = [UIFont systemFontOfSize:12.0f];
    tagInfoLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    tagInfoLabel.backgroundColor = [UIColor clearColor];
    tagInfoLabel.text = NSLocalizedString(@"# to start adding a tag", @"Adding tag");  
    
    return tagInfoLabel;
}

- (UIScrollView *)scrollViewForTagAtPoint:(CGPoint)point width:(CGFloat)width {
    CGRect tagButtonScrollFrame = CGRectMake(point.x, point.y, width, 26.0f);
    UIScrollView *tagScrollView = [[UIScrollView alloc] initWithFrame:tagButtonScrollFrame];
    tagScrollView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];  
    return tagScrollView;
}

- (UIFont *)fontTagButton {
    return [UIFont systemFontOfSize:12.0f];
}

- (UIButton *)buttonForTagScrollView {
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [tagButton setTintColor:[UIColor lightTextColor]];
    [tagButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    [tagButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [tagButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return tagButton;
}

@end
