//
//  NTTagListDetailViewController.m
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
- (IBAction)willComposeNewNoteWithTag:(id)sender;
@end

#define SELECTED_CELL_PADDING 44.0f

@implementation NTTagListDetailViewController

- (id)initWithTag:(Tag *)tag {
    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
    if (self) {
        _styleService = [StyleApplicationService sharedSingleton];
        _tagService = [[TagService alloc] init];                        
        
        _selectedIndexPath = nil;
        _buttonScroller = [[JLButtonScroller alloc] init];
        _buttonScroller.delegate = self;
        
        _tag = tag;
        _isFilteredTag = ([_tagService.filteredTags containsObject:_tag.name]);
        _notes = [self arrayNotesForDataSourceFromTag:_tag];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self->_tag.name;
    
    self->_tableView.backgroundColor = [self->_styleService paperColor];
    
    UIBarButtonItem *composeTagButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(willComposeNewNoteWithTag:)];
    self.navigationItem.rightBarButtonItem = composeTagButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - NTTagListDetailViewController (Private)

- (NSArray *)arrayNotesForDataSourceFromTag:(Tag *)tag {        
    NSMutableArray *dirtyNotes = [[tag.notes allObjects] mutableCopy];
    if (self->_isFilteredTag) {
        return dirtyNotes;
    }
    
    NSMutableArray *filteredNotes = [[NSMutableArray alloc] initWithCapacity:[dirtyNotes count]];

    for (Note *dirtyNote in dirtyNotes) {
        if ([self->_tagService doesContainFilteredTagInTagSet:dirtyNote.tags] == NO) {
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
    // nil out so we don't get the previous row selected
    self->_selectedIndexPath = nil;
    [self->_tableView reloadData];
}

- (IBAction)willComposeNewNoteWithTag:(id)sender {       
    NTWriteViewController *writeViewController = [[NTWriteViewController alloc] initWithThreadDepth:0 parent:nil initialText:[NSString stringWithFormat:@" #%@", self->_tag.name]];
    
    writeViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    writeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    writeViewController.delegate = self;
    
    [self presentModalViewController:writeViewController animated:YES];
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
        
        CGRect endFrame   = barScrollView.frame;
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(endFrame.origin.x, endFrame.origin.y, endFrame.size.width, 1.0f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.4f];  
        shadowView.layer.opacity = 0.5f;

        [cell addSubview:barScrollView];
        [cell addSubview:shadowView];  
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
    return [_tagService.filteredTags count];
}

- (UIButton *)buttonForIndex:(NSInteger)position {
    UIButton *tagButton = [self->_styleService customUIButtonStyle];
    [tagButton addTarget:self action:@selector(addFilteredTagToNote:) forControlEvents:UIControlEventTouchUpInside];
    return tagButton;
}

- (NSString *)stringForIndex:(NSInteger)position {
    return [NSString stringWithFormat:@"#%@", [self->_tagService.filteredTags objectAtIndex:position]];
}


#pragma mark = NTWriteViewDelegate 

- (void)didSaveNote {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    [managedObjectContext refreshObject:self->_tag mergeChanges:YES];
    self->_notes = [self arrayNotesForDataSourceFromTag:self->_tag];
    
    [self->_tableView reloadData];    
}

@end
