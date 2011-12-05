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
    return [UIFont fontWithName:@"Georgia" size:18.0f];
}

#pragma StyleApplicationServiceDelegate
- (UIFont *)fontNoteWrite {
    return [self fontDefault];
}

- (UIFont *)fontNoteView {
    return [self fontDefault];
}

- (UIFont *)fontTextLabelPrimary {
    return [UIFont fontWithName:@"Georgia" size:16.0f];
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

- (NSString *)cssForEmail {
    return @"<style>body { font-family: Georgia, 'Times New Roman', serif; }</style>";
}

- (UIToolbar *)inputAccessoryViewForTextView:(UITextView *)textView {
    /*UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, textView.frame.origin.y, textView.frame.size.width, InputAccessoryViewForTextViewHeight)];
    
    toolbar.tintColor   = [UIColor lightGrayColor];*/
    //toolbar.translucent = YES;

    /*
    UIBarButtonItem *addTagButton = [[UIBarButtonItem alloc] initWithTitle:@"tag note" style:UIBarButtonItemStyleBordered target:self action:@selector(willTagNote:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:addTagButton, flexibleSpace , nil]];
    */
    //FIXME -- remove when ready for tags
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

@end
