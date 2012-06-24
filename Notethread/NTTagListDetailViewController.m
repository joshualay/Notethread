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
#import "StyleConstants.h"
#import "UserSettingsConstants.h"

@interface NTTagListDetailViewController (Private)
- (NSArray *)arrayNotesForDataSourceFromTag:(Tag *)tag;
@end

@implementation NTTagListDetailViewController

- (id)initWithTag:(Tag *)tag {
    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
    if (self) {
        _tag = tag;
        _notes = [self arrayNotesForDataSourceFromTag:_tag];
        _styleService = [StyleApplicationService sharedSingleton];
        _selectedIndexPath = nil;
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
    return YES;
}



#pragma mark - NTTagListDetailViewController (Private)
- (NSArray *)arrayNotesForDataSourceFromTag:(Tag *)tag {    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *filtered = [userDefaults arrayForKey:KeywordTagsKey];
    
    NSMutableArray *dirtyNotes = [[tag.notes allObjects] mutableCopy];
    NSMutableArray *filteredNotes = [[NSMutableArray alloc] initWithCapacity:[dirtyNotes count]];
    
    BOOL shouldFilter = NO;
    for (Note *dirtyNote in dirtyNotes) {
        for (Tag *tag in dirtyNote.tags) {
            if ([filtered containsObject:tag.name]) {
                shouldFilter = YES;
                break;
            }
        }
        
        if (!shouldFilter)
            [filteredNotes addObject:dirtyNote];
        
        shouldFilter = NO;
    }
    
    dirtyNotes = nil;

    return [filteredNotes copy];   
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
    if (self->_selectedIndexPath != nil) {
        if ([indexPath compare:self->_selectedIndexPath] == NSOrderedSame) {
            Note *note = [self->_notes objectAtIndex:indexPath.row];
            NSString *text = note.text;
            
            CGSize labelSize = [text sizeWithFont:[self->_styleService  fontTextLabelPrimary]
                                         constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) 
                                             lineBreakMode:UILineBreakModeWordWrap];
            
            // TODO change to cell toolbar height
            return labelSize.height + 20.0f;
        }
    }
    
    return DefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierExpanded = @"CellExpanded";
    
    NSIndexPath *selected = self->_selectedIndexPath;
    BOOL isSelectedRow = NO;
    if (selected != nil) 
        isSelectedRow = (indexPath.row == selected.row);
            
    UITableViewCell *cell = (isSelectedRow) ? [tableView dequeueReusableCellWithIdentifier:CellIdentifierExpanded] :
                                              [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (isSelectedRow) {
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [self->_styleService blackLinenColor];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    else {
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    Note *note = [self->_notes objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
        
    cell.textLabel.text = note.text;
         
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSIndexPath *newSelectedIndexPath = [tableView indexPathForSelectedRow];
    
    [tableView beginUpdates];

    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:2];
    [indexPaths addObject:newSelectedIndexPath];

    if ([newSelectedIndexPath compare:self->_selectedIndexPath] == NSOrderedSame) {
        self->_selectedIndexPath = nil;
    }
    else {
        if (self->_selectedIndexPath != nil)
            [indexPaths addObject:self->_selectedIndexPath];
        
        self->_selectedIndexPath = [tableView indexPathForSelectedRow];
    }

    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

@end
