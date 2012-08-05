//
//  NTTagListDetailViewController.m
//  Notethread
//
//  Created by Joshua Lay on 12/06/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

// For view.layer.*
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
- (UITableViewCell *)cellForSelectedRowForTable:(UITableView *)tableView withNote:(Note *)note;
@end

#define SELECTED_CELL_PADDING 44.0f

@implementation NTTagListDetailViewController

@synthesize managedObjectContext=_managedObjectContext;

- (id)initWithTag:(Tag *)tag managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
    if (self) {
        _managedObjectContext = managedObjectContext;
        
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

    // Reverse order
    NSArray *sortedNotes = [dirtyNotes sortedArrayUsingComparator:^(Note *n1, Note *n2) {
        return [n2.lastModifiedDate compare:n1.lastModifiedDate];
    }];

    if (self->_isFilteredTag) {
        return sortedNotes;
    }

    NSMutableArray *filteredNotes = [[NSMutableArray alloc] init];
    for (Note *note in sortedNotes) {
        if ([self->_tagService doesContainFilteredTagInTagSet:note.tags] == NO) {
            [filteredNotes addObject:note];        
        }
    }
    dirtyNotes = nil;

    return filteredNotes;   
}


- (IBAction)addFilteredTagToNote:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *tagString = button.titleLabel.text;
    
    Note *selectedNote = [self->_notes objectAtIndex:self->_selectedIndexPath.row];
    selectedNote.text = [NSString stringWithFormat:@"%@ %@", selectedNote.text, tagString];
    
    NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:selectedNote.text];
    
    [self->_tagService storeTags:tagsInNote withRelationship:selectedNote inManagedContext:self.managedObjectContext];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
    } 
    
    // Reload the data store
    self->_notes = [self arrayNotesForDataSourceFromTag:self->_tag];
    // nil out so we don't get the previous row selected
    self->_selectedIndexPath = nil;
    [self->_tableView reloadData];
}

- (IBAction)willComposeNewNoteWithTag:(id)sender {       
    NTWriteViewController *writeViewController = [[NTWriteViewController alloc] initWithThreadDepth:0 parent:nil initialText:[NSString stringWithFormat:@" #%@", self->_tag.name] managedObjectContext:self.managedObjectContext];
    
    writeViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    writeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    writeViewController.delegate = self;
    
    [self presentModalViewController:writeViewController animated:YES];
}

- (UITableViewCell *)cellForSelectedRowForTable:(UITableView *)tableView withNote:(Note *)note {
    static NSString *CellIdentifierExpanded = @"CellExpanded";
    
    // As the height of the cell is dynamic I can't reuse the cells
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierExpanded];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    CGSize labelSize = [note.text sizeWithFont:[self->_styleService fontTextLabelPrimary]
                             constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) 
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    // I want to get the height of the font for one character
    CGSize fontSize  = [@"s" sizeWithFont:[self->_styleService fontTextLabelPrimary]
                        constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT)];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, fontSize.height, cell.contentView.frame.size.width - (fontSize.height * 1.5f), labelSize.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines   = 0;
    textLabel.lineBreakMode   = UILineBreakModeWordWrap;
    textLabel.font            = [self->_styleService fontTextLabelPrimary];
    
    textLabel.text = note.text;
    
    UIScrollView *barScrollView = [self->_styleService scrollViewForTagAtPoint:CGPointMake(cell.contentView.frame.origin.x, labelSize.height + SELECTED_CELL_PADDING) width:self.view.frame.size.width];
    
    [self->_buttonScroller addButtonsForContentAreaIn:barScrollView];
    
    CGRect endFrame   = barScrollView.frame;
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(endFrame.origin.x, endFrame.origin.y, endFrame.size.width, 1.0f)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.4f];  
    shadowView.layer.opacity = 0.5f;
    
    [cell.contentView addSubview:textLabel];
    [cell.contentView addSubview:barScrollView];
    [cell.contentView addSubview:shadowView];
    
    return cell;
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
    
    NSIndexPath *selected = self->_selectedIndexPath;
    BOOL isSelectedRow = (selected != nil && (indexPath.row == selected.row));
    
    UITableViewCell *cell = (isSelectedRow) ? nil : [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    Note *note = [self->_notes objectAtIndex:indexPath.row];
    if (isSelectedRow) {        
        cell = [self cellForSelectedRowForTable:tableView withNote:note];
    }
    else {
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = note.text;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
                 
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    NSUInteger index = indexPath.row;
    
    // Delete the managed object for the given index path
    [self.managedObjectContext deleteObject:[self->_notes objectAtIndex:index]];
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        [AlertApplicationService alertViewForCoreDataError:[error localizedDescription]];
    }
    
    NSMutableArray *mutableCopy = [self->_notes mutableCopy];
    self->_notes = nil;
    [mutableCopy removeObjectAtIndex:index];
    self->_notes = [mutableCopy copy];
    mutableCopy = nil;
    
    self->_selectedIndexPath = nil;
    
    [self->_tableView reloadData];
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
    [self.managedObjectContext refreshObject:self->_tag mergeChanges:YES];
    self->_notes = [self arrayNotesForDataSourceFromTag:self->_tag];
    
    [self->_tableView reloadData];    
}

@end
