//
//  NTTagListDetailViewController.m
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NTTagListDetailViewController.h"
#import "Tag.h"
#import "Note.h"
#import "StyleApplicationService.h"

@interface NTTagListDetailViewController (Private)

@end

@implementation NTTagListDetailViewController

- (id)initWithTag:(Tag *)tag {
    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
    if (self) {
        _tag = tag;
        _notes = [tag.notes allObjects];
        _styleService = [StyleApplicationService sharedSingleton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self->_tag.name;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self->_notes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row == [tableView indexPathForSelectedRow].row) {
        return 100.0f;
    }
    
    return 42.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    Note *note = [self->_notes objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
    
    cell.textLabel.numberOfLines = 2;
    
    cell.textLabel.text = note.text;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView beginUpdates];
    [tableView endUpdates];
}

@end
