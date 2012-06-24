# Notethread v1.6 Journal 

The goal of this release is give more power to #tags. I want to be able to create a list function that displays all notes under a certain tag as list items. 

As you may have a certain tag in different notes this will just show them all in the one list; making it easy to have a quick overview.

## 24/06/2012

* Add button to #archive
* Add #tag keyword filter

### Worklog

NTTagListViewController - ignore keywords in sorting so they'll be last… hopefully.

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSArray *filtered = [userDefaults arrayForKey:KeywordTagsKey];
        if (filtered == nil) {
            filtered = [[NSArray alloc] initWithObjects:@"archive", nil];
            [userDefaults setObject:filtered forKey:KeywordTagsKey];
        }
        
        NSMutableArray *tmpTags = [[[self fetchedResultsController] fetchedObjects] mutableCopy];
        [tmpTags sortUsingComparator:^(id tag1, id tag2) {
            Tag *tagOne = (Tag *)tag1;
            Tag *tagTwo = (Tag *)tag2;
            
            /* Tag keyword filtering */
            if ([filtered containsObject:tagOne.name])
                return (NSComparisonResult)NSOrderedDescending;
            
            if ([filtered containsObject:tagTwo.name])
                return (NSComparisonResult)NSOrderedAscending;
                
This has done the trick on displaying #archive in last position. However this doesn't really solve the issue of removing the notes with #archive from the tag list.

Going to do the filtering on the detail view. Do it so it works then see what can be done better.


## 19/06/2012

A functionality journey where I add buttons on the tag list detail cells and make them resize properly to the note in them somehow. These buttons add the special keyword #tag to the notes which I can then filter out. 

Really depends if this is going to turn into a todo list or not. I think not. I'd rather have a generic #archived tag to filter things out. Probably need to make that show at the bottom as it will have the largest count in the end :/ … **TODO**

Implementation details to consider:

* What if I want people to use something besides #archived to filter notes?
	* I'd need a user setting for that -- create now; future functionality possible
* What if I want people to have multiple filter #tags?
* What if I want people to have a "priority tag inbox (ala gMail)"?
	* All tags
	* Priority mode - select what tags are displayed here only; display filter
	* Star a tag?
	* Potential hook into Reminders?
	
Lots of food for thought. Going to try one way; use it; and then go again.

### Worklog

I'm using the inbuilt styles currently. I really want something that will expand to the size of the text. I'll play around with that first. 

Firstly though. I need the actual text. Since I've stored my notes in an ivar I can look that up quite easily.

Ahhh it's so obvious when you find [the solution](http://stackoverflow.com/a/4732135/626078)

	Note *note = [self->_notes objectAtIndex:indexPath.row];
	NSString *text = note.text;
	
	CGSize labelSize = [text sizeWithFont:[self->_styleService  fontTextLabelPrimary]
	                             constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) 
	                                 lineBreakMode:UILineBreakModeWordWrap];
	return labelSize.height + 20.0f;

Now the text is still on one line. So I better change that.

    switch (isSelectedRow) {
        case YES:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            break;
            
Key things here is setting numberOfLines to 0.

Now if I want a Toolbox I need to add it as a subview in the cell. I'll need to make the height of that bar a constant so I can add it as my buffer when working out the height of the selected cell.

But, I want to make a selected cell a different colour at least to make it easier to work with.

I'm having issues with getting the textLabel's background being clear. It remains white.

## 18/06/2012

Fix up the tag list detail cell resizing. Doesn't work for the first row.

### Worklog

I'm using the selected index and have a check if it's nil or not to somewhat toggle the state. 

Fixed it: 

* Set _selectedIndexPath to nil on init. 
* Used the method compare: to test if the index paths were equal

Previously I was using indexPath.row @property.

NTTagListViewController - since I'm doing a custom sort there's no point in adding an NSSortDescriptor when fetching from Core Data.

Well aren't I silly. You require sort descriptors :)

Trying to be a bit more clever on how I reload the table data in TagListDetail. If the selected row has changed there will be two rows that require animation. If the selected row is tapped again; only one. 

I'm going back to only wanting to update what is required in this.

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


## 17/06/2012

Play around with how the TagDetailViewController will look like. Considering adding an add new note button there where the tag is automatically added on creation. 

### Worklog

In order to get the cell resizing I was using:

	[tableView beginUpdate]
	[tableView endUpdate]
	
I'm not sure if that's really required. I'm indicating that the entire table is being updated. Where in reality it's only a single row (the selected row). I haven't seen any real performance hits though; but it's worth making this part smarter.

	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{    
	    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[tableView indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationNone];
	}

Now I'm just doing the selected row.

I want a different style cell so I can add the extra buttons. Reloading that row will force it to be redrawn. What I need to do is work out if this is the currently selected row; if it is then use a different cell type.

Hmmm. My assumptions of just reloading the selected row are wrong. The previous cell style will remain. I'm going back to the update block as before.

That didn't fix it. The first selected cell has remained exactly the same. It should be redrawing the cell.

Doesn't look like the selected row is updating at all in cellForRowAtIndexPath, however it is for heightForRowAtIndexPath. In wondering if it's because the table view is reloading it has nothing selected.

I'm going to add an ivar to maintain the knowledge of selectedIndexRow.

## 16/06/2012

Few bug fixes for issues I've noticed:

* \# button insertion will write over the next character with a space
* Not being smart and using UIAutoResizingMask; may be better than UIScreen dimensions

Documentation.

Crafting the detail view for the tag list.

**I want to consider adding a proper help section. I can just section off the settings page. Just change button or the like.**


## Worklog

How to be smart about the # insertion?

Ahh!! My mistake is I've created an NSRange of length 1. This meant it was going to write over any character following the start location. 

	NSUInteger enteredLength = 0;

Fixed.

Autoresizing. I'm not sure if this is really required. I'm getting the view bound already. I can't just change around the height only. I'll leave this for now. It's working so I'm not going to break it.

I have a constant that defines the Y origin of the note's UITextView. Going to remove that and use the height of the navigationBar instead.

Thinking of just having text instead of an icon for the tag list.

Currently I have the tag list cells displaying the tag name and count. I think that's enough. I need a style service in the view controller to match the settings.

    cell.textLabel.font       = [self->_styleService fontTextLabelPrimary];
    cell.detailTextLabel.font = [self->_styleService fontDetailTextLabelPrimary];
    
Now it will look the same.

The tag list doesn't look right. It doesn't seem to be really sorted by count at all.

Ahhh of course. I'm sorting by frequency; which is not decremented when a note is deleted. So this is wrong:

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
**Need to check documentation to see if I can sort by relationships**

NSSortDescriptor

I think I can use this: 

	+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)cmptr
	
Bonedd! I want to sort by a property that I have to dynamically resolve. It doesn't want to work. Will have to use frequency. 

Actually. I can attempt to do the sorting post retrieval. Though this may be expensive. 

Trying out an instance var to store the tags. I'll utilise the fetch controller results to store on init and then sort with a comparision on notes count.

        NSMutableArray *tmpTags = [[[self fetchedResultsController] fetchedObjects] mutableCopy];
        [tmpTags sortUsingComparator:^(id tag1, id tag2) {
            Tag *tagOne = (Tag *)tag1;
            Tag *tagTwo = (Tag *)tag2;
            
            if ([tagOne.notes count] < [tagTwo.notes count])
                return (NSComparisonResult)NSOrderedDescending;
            
            if ([tagOne.notes count] > [tagTwo.notes count])
                return (NSComparisonResult)NSOrderedAscending;
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        _tags = [tmpTags copy];
        tmpTags = nil;
        
That looks like it has worked! 

For the sake of consistency I'm updating all (Private) categories; instead of just empty braces.

Documentation has been neglected. Just updating that now.

Adding a view for NTTagListDetailViewController.

Now the issue I had with my tinkering is that I had no self.navigationViewController. To work around this when I first init NTTagListViewController I create a UINavigationViewController as well.

	- (IBAction)displayTagListView:(id)sender {
	    NTTagListViewController *tagListViewController = [[NTTagListViewController alloc] initWithNibName:@"NTTagListViewController" bundle:nil];
	    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagListViewController];
	    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	    [self presentModalViewController:navController animated:YES];
	}

Now we can drill down the tags.

Since NTTagListDetailViewController needs to know about the Tag selected I'll make a constructor for it. Rather than assigning a property. I feel it makes it more obvious on what dependencies this class has.

	- (id)initWithTag:(Tag *)tag {
	    self = [super initWithNibName:@"NTTagListDetailViewController" bundle:nil];
	    if (self) {
	        _tag = [tag copy];
	    }
	    return self;
	}

I'm thinking of allocating some keywords for this tagging system to work nicely. Each note opened up from this tag list will display the note and then on selection event drop down a new row for actions on the cell OR just display always and make the row bigger. 

E.g.

    ------------------------
	| NoteText             |
	|                      |
	------------------------
    |[delete]       [#done]|
    ------------------------

Without having to add any features; tags can express the state of the notes. 

First things first however. Time to fix up the tag note listing view. 

Thought: If I'm using tags to express a category of note - should I keep it in the note? It depends on how people will use it. But best not mess with the contents of the notes just yet. I would consider stripping out the tag from the note as you've already opened it up based on that tag.

When selecting a tag and going back the selection remains. I can't remember why this is happening nor what I've done to fix it in the past.

Needed access to the UITableView. Created an ivar and linked to via I.B. Then added the following:

	- (void)viewDidDisappear:(BOOL)animated {
	    [self->_tableView deselectRowAtIndexPath:[self->_tableView indexPathForSelectedRow] animated:YES];
	    [super viewDidDisappear:animated];
	}

Just playing around withe expanding the cell height on selection.

Used [this as a reference](http://locassa.com/animate-uitableview-cell-height-change/)

	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	    if ( indexPath.row == [tableView indexPathForSelectedRow].row) {
	        return 100.0f;
	    }
	    
	    return 42.0f;
	}
	
	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{    
	    [tableView beginUpdates];
	    [tableView endUpdates];
	}


## 13/06/2012

Playing around with getting the NTTagListViewController displaying something.

### Worklog

Decided I may as well have a xib instead of doing everything programatically. Probably not required; but it matches the current style for the view controllers anyhow.

Adding a button to the NTNoteListViewController to bring up this new tag list view. In order to keep behaviour consistent I will make it do the UIModalTransitionStyleFlipHorizontal transition.

	- (IBAction)displayTagListView:(id)sender {
	    NTTagListViewController *tagListViewController = [[NTTagListViewController alloc] initWithNibName:@"NTTagListViewController" bundle:nil];
	    tagListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	    [self presentModalViewController:tagListViewController animated:YES];
	}

Well that's daft. I don't have a way of exiting the NTTagListViewController view do I.

Adding a Navigation Bar in IB. 

Adding a @selector to dimiss the Tag List view.

Now to work out how to grab all the Tag objects to load this jazz up. 

Going to copy over a few methods from NTNoteListViewController for gathering the data.

Now to fetch the data. I think this NSPredicate will work:

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notes.@count > 0"];

And that worked. All the tags are now displaying in the table view.

## 12/06/2012

You know what. Lets add a Twitter share button. I want to play with the API. 

### Worklog

Sharing is only in the NoteViewController.

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Tweet", nil];
    
Realised I'm not using @delegates properly for the old stuff. Taking out the methods from NTThreadViewDelegate and putting them as private methods inside the controller. Will refactor the controller later by breaking it into separate categories.

[TWTweetComposeViewController Class Reference](https://developer.apple.com/library/ios/#documentation/Twitter/Reference/TWTweetSheetViewControllerClassRef/Reference/Reference.html#//apple_ref/doc/uid/TP40010943)

Hmmm. I have the ability to check if the user can send tweets or not. However when creating the actionsheet you don't have the ability to pass an array into otherButtonTitles. That's crap.

I'll have to use [this solution](http://stackoverflow.com/a/2384638/626078).

To get twitter in you'll have to link the binary to the library **Twitter.framework**. The header to import is:

	#import <Twitter/Twitter.h>

Hmmm. Well the dynamic view is a bit arse. Back to the old way and let the tweet option be there.

MUCH BETTER.

It's quite easy to compose a tweet.

    TWTweetComposeViewController *composer = [[TWTweetComposeViewController alloc] init];
    [composer setInitialText:self.note.text];
    [self presentModalViewController:composer animated:YES];
    
Now to refactor. I want an @interface for the different parts of NTNoteViewController.

 * NTNoteViewController() -- concerning the view controller
 * NTNoteViewController(NoteViewDisplay_and_Actions)
 * NTNoteViewController(ActionSheet)
 * NTNoteViewController(Keyboard)

Now to break out these into different files.

Hmm. Doesn't seem to be work. I'll leave it for now as it's side tracking.

But because I'm pedantic I've created the methods according to the category definitions.

So then. What is required for the list view!

* Button
* New view controller

Lets go with **NTTagListViewController**:

**NTTagListViewController**

* Read in tags
* Sort by how many notes a tag has a relationship to
* Load the main table view with the tags as rows
* Strip out the #tag from the note text when displaying it in the row
* Selecting the row will load all the notes in another table view?
* Tapping on the note in there will load it up in NTNoteViewController

		NTTagViewController
		- (void)didSelect
			NTTagDetailViewController

Something like that. 