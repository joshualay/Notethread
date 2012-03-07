//
//  SettingsViewController.h
//  Notethread
//
//  Created by Joshua Lay on 23/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong) IBOutlet UISlider *threadRowSlider;
@property (strong) UILabel *threadCountLabel;
@property (strong) NSUserDefaults *userDefaults;
@property (strong) NSString *fontFamilyName;
@property (assign) CGFloat fontSize;

- (IBAction)didCancelChangeSettings:(id)sender;
- (IBAction)didSaveSettings:(id)sender;
- (IBAction)didMoveThreadRowSlider:(id)sender;

- (IBAction)didSelectFontSize:(id)sender;

@end
