//
//  StyleApplicationService.h
//  Notethread
//
//  Created by Joshua Lay on 14/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTWriteViewController;
@class Note;

@interface StyleApplicationService : NSObject 

@property (nonatomic, strong) NSUserDefaults *userDefaults;

+ (StyleApplicationService *)sharedSingleton;

- (UIFont *)fontNoteWrite;
- (UIFont *)fontNoteView;
- (UIFont *)fontTextLabelPrimary;
- (UIFont *)fontDetailTextLabelPrimary;

- (void)modalStyleForThreadWriteView:(NTWriteViewController *)threadWriteViewController;
- (void)configureNoteTableCell:(UITableViewCell *)cell note:(Note *)note;

- (UIToolbar *)inputAccessoryViewForTextView:(UITextView *)textView;

- (UIColor *)colorForTableFooter;
- (UIColor *)paperColor;
- (UIColor *)blackLinenColor;

- (UILabel *)labelForTagScrollBarWithFrame:(CGRect)frame;
- (UIScrollView *)scrollViewForTagAtPoint:(CGPoint)point width:(CGFloat)width;
- (UIFont *)fontTagButton;
- (UIButton *)customUIButtonStyle;

@end
