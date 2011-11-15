//
//  NTNoteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTNoteViewController.h"
#import "StyleApplicationService.h"

@implementation NTNoteViewController

@synthesize note            = _note;
@synthesize noteLabel       = _noteLabel;
@synthesize threadTableView = _threadTableView;
@synthesize noteThreads     = _noteThreads;


- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        _noteThreads = nil;
    }
    return self;  
}

// Not used
- (id)initWithNote:(Note *)note {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        _note = note;
    }
    return self;  
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noteLabel.text = self.note.text;
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    
    [self.noteLabel sizeToFit];
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    self.noteLabel.font = [styleApplicationService fontNoteView];
    
    CGRect noteLabelRect = self.noteLabel.frame;
    CGFloat tableHeight  = self.view.frame.size.height - noteLabelRect.size.height;
    CGRect tableRect     = CGRectMake(noteLabelRect.origin.x, noteLabelRect.size.height, noteLabelRect.size.width, tableHeight);
    
    self.threadTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    
    self.threadTableView.delegate   = self;
    self.threadTableView.dataSource = self;
    
    [self.threadTableView reloadData];
    
    [self.view addSubview:self.threadTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noteThreads == nil)
        return 0;
    
    return [self.noteThreads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Note *note = [self.noteThreads objectAtIndex:indexPath.row];
    
    cell.textLabel.text = note.text;
    
    return cell;    
}

@end
