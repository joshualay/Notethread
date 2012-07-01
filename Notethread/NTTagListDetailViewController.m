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
#import "AppDelegate.h"
#import "AlertApplicationService.h"
#import "TagService.h"

@interface NTTagListDetailViewController (Private)
- (NSArray *)arrayNotesForDataSourceFromTag:(Tag *)tag;
- (IBAction)addFilteredTagToNote:(id)sender;
- (BOOL)hasTagFromSet:(NSSet *)tags inFilter:(NSArray *)filter;
@end

#define SELECTED_CELL_PADDING 44.0f

@implementation NTTagListDetailViewController

- (id)initWithTag:(Tag *)tag {
    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
    if (self) {
        _tag = tag;
        _notes = [self arrayNotesForDataSourceFromTag:_tag];
        _styleService = [StyleApplicationService sharedSingleton];
        _selectedIndexPath = nil;
        _buttonScroller = [[JLButtonScroller alloc] init];
        _buttonScroller.delegate = self;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _filteredTags = [userDefaults arrayForKey:KeywordTagsKey];
        
        _tagService = [[TagService alloc] init];                        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self->_tag.name;
    
    self->_tableView.backgroundColor = [self->_styleService paperColor];
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

- (BOOL)hasTagFromSet:(NSSet *)tags inFilter:(NSArray *)filter {
    for (Tag *tag in tags) {
        if ([filter containsObject:tag.name]) {
            return YES;
        }
    }    
    return NO;
}

- (NSArray *)arrayNotesForDataSourceFromTag:(Tag *)tag {        
    NSMutableArray *dirtyNotes = [[tag.notes allObjects] mutableCopy];
    NSMutableArray *filteredNotes = [[NSMutableArray alloc] initWithCapacity:[dirtyNotes count]];
    
    // TODO - check if this tag is a filtered tag - then we don't do anything
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *filtered = [userDefaults arrayForKey:KeywordTagsKey];
    
    for (Note *dirtyNote in dirtyNotes) {
        if ([self hasTagFromSet:dirtyNote.tags inFilter:filtered] == NO) {
            [filteredNotes addObject:dirtyNote];        
        }
    }
    
    dirtyNotes = nil;

    return [filteredNotes copy];   
}


- (IBAction)addFilteredTagToNote:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *tagString = button.titleLabel.text;
    
    Note *selectedNote = [self->_notes objectAtIndex:self->_selectedIndexPath.row];
    selectedNote.text = [NSString stringWithFormat:@"%@ %@", selectedNote.text, tagString];
    
    NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:selectedNote.text];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    [self->_tagService storeTags:tagsInNote withRelationship:selectedNote inManagedContext:managedObjectContext];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
    } 
    
    // Reload the data store
    self->_notes = [self arrayNotesForDataSourceFromTag:self->_tag];
    [self->_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self->_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    // nil out so we don't get the previous row selected
    self->_selectedIndexPath = nil;
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
    if (self->_selectedIndexPath != nil && ([indexPath compare:self->_selectedIndexPath] == NSOrderedSame)) {
        Note *note = [self->_notes objectAtIndex:indexPath.row];
        CGSize labelSize = [note.text sizeWithFont:[self->_styleService  fontTextLabelPrimary]
                                     constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) 
                                         lineBreakMode:UILineBreakModeWordWrap];

        return labelSize.height + SELECTED_CELL_PADDING + NoteThreadActionToolbarHeight;
    }
    
    return DefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierExpanded = @"CellExpanded";
    
    NSIndexPath *selected = self->_selectedIndexPath;
    BOOL isSelectedRow = (selected != nil && (indexPath.row == selected.row));
    
    UITableViewCell *cell = (isSelectedRow) ? [tableView dequeueReusableCellWithIdentifier:CellIdentifierExpanded] :
                                              [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    Note *note = [self->_notes objectAtIndex:indexPath.row];

    if (isSelectedRow) {        
        // As the height of the cell is dynamic I can't reuse the cells
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierExpanded];
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;

        CGSize labelSize = [note.text sizeWithFont:[self->_styleService fontTextLabelPrimary]
                            constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) 
                                lineBreakMode:UILineBreakModeWordWrap];
        
        UIScrollView *barScrollView = [self->_styleService scrollViewForTagAtPoint:CGPointMake(cell.contentView.frame.origin.x, labelSize.height + SELECTED_CELL_PADDING) width:self.view.frame.size.width];
        
        [self->_buttonScroller addButtonsForContentAreaIn:barScrollView];
        
        [cell addSubview:barScrollView];
    }
    else {
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:2];

    [tableView beginUpdates];

    [indexPaths addObject:newSelectedIndexPath];
    
    if ([newSelectedIndexPath compare:self->_selectedIndexPath] == NSOrderedSame) {
        self->_selectedIndexPath = nil;
    }
    else {
        if (self->_selectedIndexPath != nil) {
            [indexPaths addObject:self->_selectedIndexPath];
        }
        
        self->_selectedIndexPath = [tableView indexPathForSelectedRow];
    }

    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}


#pragma mark - JLButtonScrollerDelegate

- (UIFont *)fontForButton {
    return [self->_styleService fontTagButton];
}

- (NSInteger)numberOfButtons {
    return [self->_filteredTags count];
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    UIButton *tagButton = [self->_styleService customUIButtonStyle];
    [tagButton addTarget:self action:@selector(addFilteredTagToNote:) forControlEvents:UIControlEventTouchUpInside];
    return tagButton;
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [NSString stringWithFormat:@"#%@", [self->_filteredTags objectAtIndex:position]];
}

@end
