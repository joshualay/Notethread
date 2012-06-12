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
@synthesize fontSize         = _fontSize;

const NSInteger lastSection = 2;

#pragma mark - selectors
- (IBAction)didCancelChangeSettings:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didSaveSettings:(id)sender {
    NSInteger threadRows = (NSInteger)self.threadRowSlider.value;
    [self.userDefaults setInteger:threadRows forKey:ThreadRowsDisplayedKey];
    [self.userDefaults setValue:self.fontFamilyName forKey:FontFamilyNameDefaultKey];
    [self.userDefaults setFloat:self.fontSize forKey:FontWritingSizeKey];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didMoveThreadRowSlider:(id)sender {
    self.threadCountLabel.text = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
}

- (IBAction)didSelectFontSize:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
        
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
            self.fontSize = FontNoteSizeSmall;
            break;
        case 1:
            self.fontSize = FontNoteSizeNormal;
            break;
        case 2:
            self.fontSize = FontNoteSizeLarge;
            break;
    }    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    if (![self.userDefaults integerForKey:ThreadRowsDisplayedKey])
        [self.userDefaults setInteger:ThreadRowsDisplayedDefault forKey:ThreadRowsDisplayedKey];
    
    NSNumber *threadRows = [NSNumber numberWithInteger:[self.userDefaults integerForKey:ThreadRowsDisplayedKey]];
    self.threadRowSlider.maximumValue = ThreadRowsDisplayedMaxRows;
    [self.threadRowSlider setValue:[threadRows floatValue]];
    
    self.fontFamilyName = [self.userDefaults stringForKey:FontFamilyNameDefaultKey];
    
    if (![self.userDefaults floatForKey:FontWritingSizeKey])
        [self.userDefaults setFloat:FontNoteSizeNormal forKey:FontWritingSizeKey];
    
    self.fontSize = [self.userDefaults floatForKey:FontWritingSizeKey];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    else if (indexPath.section == 2) {
        UISegmentedControl *fontSizeSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Small", @"Normal", @"Large", nil]];
        
        [fontSizeSegmentControl addTarget:self action:@selector(didSelectFontSize:) forControlEvents:UIControlEventValueChanged];
        
        fontSizeSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
        fontSizeSegmentControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                
        CGRect cellContentFrame      = cell.contentView.frame;
        CGRect contentSegmentFrame   = CGRectMake(cellContentFrame.origin.x + 10.0f, cellContentFrame.origin.y, cellContentFrame.size.width * 0.94, cellContentFrame.size.height);
        fontSizeSegmentControl.frame = contentSegmentFrame;
        
        [cell.contentView addSubview:fontSizeSegmentControl];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor             = [UIColor clearColor];
        
        CGFloat userFontSize = [self.userDefaults floatForKey:FontWritingSizeKey];
        if (userFontSize == FontNoteSizeSmall)
            fontSizeSegmentControl.selectedSegmentIndex = 0;
        else if (userFontSize == FontNoteSizeNormal)
            fontSizeSegmentControl.selectedSegmentIndex = 1;
        else 
            fontSizeSegmentControl.selectedSegmentIndex = 2;
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
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Threads displayed";
            break;
        case 1:
            return @"Font used";
            break;
        case 2:
            return @"Note font size";
            break;
        default:
            break;
    }
    
    return @"";
}

#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == lastSection) {
        AboutMeViewController *aboutMeViewController = [[AboutMeViewController alloc] initWithNibName:@"AboutMeViewController" bundle:nil];
        return aboutMeViewController.view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == lastSection)
        return 30.0f;
    
    return 10.0f;
}



@end
