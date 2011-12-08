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
@synthesize fontFamilyName   = _fontFamilyName;

#pragma mark - selectors
- (IBAction)didCancelChangeSettings:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didSaveSettings:(id)sender {
    NSInteger threadRows = (NSInteger)self.threadRowSlider.value;
    [self.userDefaults setInteger:threadRows forKey:ThreadRowsDisplayedKey];
    [self.userDefaults setValue:self.fontFamilyName forKey:FontFamilyNameDefaultKey];
    
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"Saving");
    NSLog(@"Thread rows: %i", threadRows);
    NSLog(@"Font used: %@", self.fontFamilyName);
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
    
    NSNumber *threadRows = [NSNumber numberWithInteger:[self.userDefaults integerForKey:ThreadRowsDisplayedKey]];
    NSLog(@"viewDidLoad: threadRows: %f", [threadRows floatValue]);
    self.threadRowSlider.maximumValue = ThreadRowsDisplayedMaxRows;
    [self.threadRowSlider setValue:[threadRows floatValue]];
    
    self.fontFamilyName = [self.userDefaults stringForKey:FontFamilyNameDefaultKey];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        self.threadRowSlider.frame = CGRectMake(60.0f, 12.0f, 220.0f, 20.0f);
        self.threadRowSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:self.threadRowSlider];
        
        self.threadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 30.0f, 20.0f)];
        
        self.threadCountLabel.backgroundColor = [UIColor clearColor];
        self.threadCountLabel.font            = [UIFont systemFontOfSize:22.0f];
        self.threadCountLabel.text            = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
                
        [cell.contentView addSubview:self.threadCountLabel];
    }
    else if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
        NSString *format = @"%@ is the font you want";
        if (indexPath.row == 0) {
            if ([self.fontFamilyName isEqualToString:FontFamilySerif]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySerif];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySerif size:17.0f];
        }
        else {
            if ([self.fontFamilyName isEqualToString:FontFamilySansSerif]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySansSerif];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySansSerif size:17.0f];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                self.fontFamilyName = FontFamilySerif;
                break;
            case 1:
                self.fontFamilyName = FontFamilySansSerif;
                break;
        }
        
        [tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Threads displayed";
            break;
        case 1:
            return @"Font used";
        default:
            break;
    }
    
    return @"";
}

#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        AboutMeViewController *aboutMeViewController = [[AboutMeViewController alloc] initWithNibName:@"AboutMeViewController" bundle:nil];
        return aboutMeViewController.view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}



@end
