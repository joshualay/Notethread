//
//  SettingsViewController.m
//  Notethread
//
//  Created by Joshua Lay on 23/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutMeViewController.h"
#import "UserSettingsConstants.h"

@implementation SettingsViewController

@synthesize threadRowSlider  = _threadRowSlider;
@synthesize userDefaults     = _userDefaults;
@synthesize threadCountLabel = _threadCountLabel;

#pragma mark - selectors
- (IBAction)didCancelChangeSettings:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didSaveSettings:(id)sender {
    NSInteger threadRows = (NSInteger)self.threadRowSlider.value;
    [self.userDefaults setInteger:threadRows forKey:ThreadRowsDisplayedKey];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didMoveThreadRowSlider:(id)sender {
    self.threadCountLabel.text = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    if (![self.userDefaults integerForKey:ThreadRowsDisplayedKey])
        [self.userDefaults setInteger:ThreadRowsDisplayedDefault forKey:ThreadRowsDisplayedKey];
    
    [self.threadRowSlider setValue:(float)[self.userDefaults integerForKey:ThreadRowsDisplayedKey]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    self.threadRowSlider.frame = CGRectMake(60.0f, 12.0f, 220.0f, 20.0f);
    [cell.contentView addSubview:self.threadRowSlider];
    
    self.threadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 20.0f, 20.0f)];
    
    self.threadCountLabel.backgroundColor = [UIColor clearColor];
    self.threadCountLabel.font            = [UIFont systemFontOfSize:22.0f];
    self.threadCountLabel.text            = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
    
    [cell.contentView addSubview:self.threadCountLabel];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Threads displayed";
}

#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    AboutMeViewController *aboutMeViewController = [[AboutMeViewController alloc] initWithNibName:@"AboutMeViewController" bundle:nil];
    return aboutMeViewController.view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}



@end
