//
//  StyleApplicationService.m
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "StyleApplicationService.h"
#import <QuartzCore/QuartzCore.h>

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
    return [UIFont fontWithName:@"Georgia" size:17.0f];
}

#pragma StyleApplicationServiceDelegate
- (UIFont *)fontNoteWrite {
    return [self fontDefault];
}

- (UIFont *)fontNoteView {
    return [self fontDefault];
}

- (UIFont *)fontTextLabelPrimary {
    return [UIFont systemFontOfSize:15.0f];
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
    
    cell.detailTextLabel.font      = [self fontDetailTextLabelPrimary];    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    cell.textLabel.layer.shadowOffset  = CGSizeMake(1.0f, 1.0f);
    cell.textLabel.layer.shadowColor   = [[UIColor whiteColor] CGColor];
    cell.textLabel.layer.shadowOpacity = 1.0f;
    cell.textLabel.layer.shadowRadius  = 1.0f;
    
    cell.detailTextLabel.layer.shadowOffset  = CGSizeMake(1.0f, 1.0f);
    cell.detailTextLabel.layer.shadowColor   = [[UIColor blackColor] CGColor];
    cell.detailTextLabel.layer.shadowOpacity = 1.0f;
    cell.detailTextLabel.layer.shadowRadius  = 1.0f;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

@end
