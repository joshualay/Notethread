//
//  SettingsViewController.m
//  Notethread
//
//  Created by Joshua Lay on 23/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserSettingsConstants.h"

@interface SettingsViewController()
- (void)configureCellThreadsDisplayed:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellFontUsed:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellFontSize:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SettingsViewController

@synthesize threadRowSlider  = _threadRowSlider;
@synthesize userDefaults     = _userDefaults;
@synthesize threadCountLabel = _threadCountLabel;
@synthesize fontFamilyName   = _fontFamilyName;
@synthesize fontSize         = _fontSize;

const NSInteger lastSection = 2;
const NSInteger sections = 3;
const NSInteger fontsAvailable = 4;

#pragma mark - selectors
- (void)didCancelChangeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSaveSettings:(id)sender {
    NSInteger threadRows = (NSInteger)self.threadRowSlider.value;
    [self.userDefaults setInteger:threadRows forKey:ThreadRowsDisplayedKey];
    [self.userDefaults setValue:self.fontFamilyName forKey:FontFamilyNameDefaultKey];
    [self.userDefaults setFloat:self.fontSize forKey:FontWritingSizeKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didMoveThreadRowSlider:(id)sender {
    self.threadCountLabel.text = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
}

- (IBAction)didSelectFontSize:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
        
    switch (segmentControl.selectedSegmentIndex) {
        case FontSizeSliderSmall:
            self.fontSize = FontNoteSizeSmall;
            break;
            
        case FontSizeSliderNormal:
            self.fontSize = FontNoteSizeNormal;
            break;
            
        case FontSizeSliderLarge:
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
    
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGFloat appHeight = appFrame.size.height;
    CGFloat maxRows = ThreadRowsDisplayedMaxRows;
    
    //JL: This is hack but I can't think of a nicer way
    if (appHeight > 460.0f)
        maxRows = 10.0f;
    
    self.threadRowSlider.maximumValue = maxRows;
    [self.threadRowSlider setValue:[threadRows floatValue]];
    
    self.fontFamilyName = [self.userDefaults stringForKey:FontFamilyNameDefaultKey];
    
    if (![self.userDefaults floatForKey:FontWritingSizeKey])
        [self.userDefaults setFloat:FontNoteSizeNormal forKey:FontWritingSizeKey];
    
    self.fontSize = [self.userDefaults floatForKey:FontWritingSizeKey];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancelChangeSettings:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(didSaveSettings:)];
    
    self.title = NSLocalizedString(@"Settings", @"Settings");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SettingsSectionsFontUsed)
        return fontsAvailable;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case SettingsSectionsThreadsDisplayed:
            [self configureCellThreadsDisplayed:cell cellForRowAtIndexPath:indexPath];
            break;
            
        case SettingsSectionsFontUsed:
            [self configureCellFontUsed:cell cellForRowAtIndexPath:indexPath];
            break;
            
        case SettingsSectionsFontSize:
            [self configureCellFontSize:cell cellForRowAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)configureCellThreadsDisplayed:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.threadRowSlider.frame = CGRectMake(60.0f, 12.0f, 220.0f, 20.0f);
    self.threadRowSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:self.threadRowSlider];
    
    self.threadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 30.0f, 20.0f)];
    
    self.threadCountLabel.backgroundColor = [UIColor clearColor];
    self.threadCountLabel.font            = [UIFont systemFontOfSize:22.0f];
    self.threadCountLabel.text            = [NSString stringWithFormat:@"%i", (NSInteger)self.threadRowSlider.value];
    
    [cell.contentView addSubview:self.threadCountLabel];    
}

- (void)configureCellFontUsed:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    NSString *format = @"%@ is the font you want";
    switch (indexPath.row) {
        case FontFamilyRowSerif:
            if ([self.fontFamilyName isEqualToString:FontFamilySerif]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySerif];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySerif size:17.0f];
            break;
            
        case FontFamilyRowSansSerif:
            if ([self.fontFamilyName isEqualToString:FontFamilySansSerif]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySansSerif];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySansSerif size:17.0f];
            break;
            
        case FontFamilyRowSerifAlt:
            if ([self.fontFamilyName isEqualToString:FontFamilySerifAlt]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySerifAlt];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySerifAlt size:17.0f];
            break;
        
        case FontFamilyRowSansSerifAlt:
            if ([self.fontFamilyName isEqualToString:FontFamilySansSerifAlt]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            cell.textLabel.text = [NSString stringWithFormat:format, FontFamilySansSerifAlt];
            cell.textLabel.font = [UIFont fontWithName:FontFamilySansSerifAlt size:17.0f];
            break;
    }    
}

- (void)configureCellFontSize:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UISegmentedControl *fontSizeSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Small", @"Normal", @"Large", nil]];
    
    [fontSizeSegmentControl addTarget:self action:@selector(didSelectFontSize:) forControlEvents:UIControlEventValueChanged];
    
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
    if (userFontSize == FontNoteSizeSmall) {
        fontSizeSegmentControl.selectedSegmentIndex = FontSizeSliderSmall;
    }
    else if (userFontSize == FontNoteSizeNormal) {
        fontSizeSegmentControl.selectedSegmentIndex = FontSizeSliderNormal;
    }
    else {
        fontSizeSegmentControl.selectedSegmentIndex = FontSizeSliderLarge;   
    }
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
            case 2:
                self.fontFamilyName = FontFamilySerifAlt;
                break;
            case 3:
                self.fontFamilyName = FontFamilySansSerifAlt;
                break;
        }        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SettingsSectionsThreadsDisplayed:
            return @"Threads displayed";
            break;
            
        case SettingsSectionsFontUsed:
            return @"Font used";
            break;
            
        case SettingsSectionsFontSize:
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
        UIImage *twitterLogo = [UIImage imageNamed:@"twitter_logo"];
        CGFloat halfLogo = twitterLogo.size.width / 2.0f;
        
        UIImageView *twitterImageView = [[UIImageView alloc] initWithImage:twitterLogo];
        
        CGFloat imageX = (tableView.frame.size.width / 2.0f) - halfLogo;
        twitterImageView.frame = CGRectMake(imageX, 10.0f, twitterLogo.size.width, twitterLogo.size.height);
        UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44.0f)];
        [twitterButton addSubview:twitterImageView];
        [twitterButton addTarget:self action:@selector(launchTwitter:) forControlEvents:UIControlEventTouchUpInside];
        return twitterButton;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == lastSection)
        return 55.0f;
    
    return 10.0f;
}

- (IBAction)launchBlog:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://joshualay.net/blog/"];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to launch browser");
    }
}

- (IBAction)launchTwitter:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/_joshlay"];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to launch browser");
    }    
}

@end
