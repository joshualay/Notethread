# Notethread v1.6 Journal 

The goal of this release is give more power to #tags. I want to be able to create a list function that displays all notes under a certain tag as list items. 

As you may have a certain tag in different notes this will just show them all in the one list; making it easy to have a quick overview.

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