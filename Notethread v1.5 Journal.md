# Notethread v1.5 Journal 

The goal of this release is to attempt to get tags into play.

## 29/04/2012

Goal of this session is just to get the # detection working. So when the # character is
entered it will then compare the word following that with existing tags.

### Work log

Just fixed up a small issue with the title updating when deleting characters. When you 
delete the last one the title remains the same until you delete again. Simple fix.

#### Code snippet - from NTWriteViewController

	- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
		self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@%@", textView.text, text];
    	self.saveButton.enabled = ([textView.text length]) ? YES : NO;
    
    	if (range.location == 0 && [text isEqualToString:@""]) {
        	self.navigationBar.topItem.title = @"";
        	self.saveButton.enabled = NO;
    	}
    
    	return YES;
	}

I already had this method which is from **UITextViewDelegate**. When it hits that 
conditional statement; clear the title as well. Tested and it's much nicer. A minor 
nitpick I know. 

Okay onto the goal.

I'll have to stay in this method. Lets do some simple detection and see where that goes.

The important part of the delegate method from above is replacementText. In the case
the user enters a # then text will equal "#". 

#### Code snippet - string matching the #
	if ([text isEqualToString:@"#"]) {
		// Do something
	}

In order to display a dynamic list I'll have to maintain an array with all possible
matches. To start off with I'll update Do something to reset my matching tags array.

#### Code snippet - matching tag array
	// Going to use the count of all the tags as my capacity to bound it
    if ([text isEqualToString:@"#"]) {
        self->_matchedTags = nil;
        self->_matchedTags = [[NSMutableArray alloc] initWithCapacity:[self->_existingTags count]];
    }
    
This isn't good enough. I need to store what the user is entering in after the #, plus
have a flag to tell the code that the user is entering in a tag. 

#### Code snippet - adding the required ivars
	@interface NTWriteViewController : UIViewController <UITextViewDelegate, JLButtonScrollerDelegate> {
		// ...
		NSMutableArray *_matchedTags;
		NSString *_currentTagSearch;
		BOOL _isEnteringTag;
	}

I think this will suffice for now. 

Trying to implement this I ran into a problem. I had no method exposed in the 
TagService to get me an array of matching tags to the whatever the value of
_currentTagSearch. 

#### Code snippet - changes for actually making it work
	// TagService.h
	- (NSArray *)arrayOfMatchingTags:(NSString *)term inManagedContext:(NSManagedObjectContext *)managedObjectContext;
	
	// NTWriteViewController.h
	@interface NTWriteViewController ... {
		// ...
		NSArray *_matchedTags
	}
	
All this cruft now leaves me with a pretty ugly method.

#### Code snippet - shouldChangeTextInRange in NTWriteViewController
    if ([text isEqualToString:@"#"]) {
        self->_matchedTags = nil;        
        self->_currentTagSearch = @"";
        self->_isEnteringTag = YES;
        
        return YES;
    }
    
    if (self->_isEnteringTag) {
        if ([text isEqualToString:@" "]) {
            self->_isEnteringTag = NO;
            self->_matchedTags = nil;
            self->_currentTagSearch = @"";
            
            return YES;
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        self->_currentTagSearch = [NSString stringWithFormat:@"%@%@", self->_currentTagSearch, text];
        self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inManagedContext:managedObjectContext];
    }
	
Ran it and it didn't crash. However I need to update the JLButtonScrollerDelegate 
methods to use self->_matchedTags.

Well that was a pain in the arse. 

JLButtonScroller only runs once via the processing method addButtonsForContentAreaIn. 
What this means is I had to make it an ivar, along with the scroll view so I can access
them elsewhere and to generate the buttons for the newly matched tags. 

Ran it and it doesn't seem to be matching. First check is to see the _currentTagSearch
value by logging it.

That looks fine. This means the issue is in the method I created in TagService. There
must be an issue with how I'm searching. I'm going to look at another project to see
what I did there.

Updated the tag service to just searching within the existing tags.

#### Code snippet - TagService updated tag search method
	- (NSArray *)arrayOfMatchingTags:(NSString *)term inArray:(NSArray *)existingTags {
		
		NSMutableArray *matchedExistingTags = [[NSMutableArray alloc] initWithCapacity:[existingTags count]];
		for (Tag *tag in existingTags) {
			NSComparisonResult result = [tag.name compare:term options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [term length])];
			if (result == NSOrderedSame)
			{
				[matchedExistingTags addObject:tag];
			}
		}
		
		return matchedExistingTags;
	}
	
All well in good... *but* I have the issue of me adding button subviews on top of each
other. I need to just clear out the subviews from the scroll view. I can do that in 
JLButtonScroller.

#### Code snippet - JLButtonScroller remove subviews
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }

Looks like I have best case scenario stuff going. I want to check it fully functional,
then I can play the refactor game. 

I'm keen on checking out the performance as well. Notethread is pretty light and fast,
but it'd be good to keep it down.

**josh;**

## 26/04/2012

A late night coding spurt after a long day of... coding... plus some training to boot. 
I'm tired but I have the urge to create something new.

To recap for myself. I've got the tags loading and displaying; with the major issue being
I have no tags stored yet. So the aim right now is to provide a mechanism to add tags to 
a note. 

My thoughts are that I'll rely on the # button and detecting it in the users input. 

**Adding hashes the easy way**

I think this is best done by using the new Twitter keyboard.

### Work log

#### Code snippet - Lets change the keyboard type for the UITextView.
	self.noteTextView.keyboardType = UIKeyboardTypeTwitter;

Simple!

Rather than do anything complex just yet; I'll just make it scan for any tags in the note
and save it if it finds anything.

#### Code snippet - Changes to be made in here:
	- (IBAction)saveNote:(id)sender
	
#### Code snippet - TagService methods to use:
	- (NSArray *)arrayOfTagsInText:(NSString *)text;
	- (void)storeTags:(NSArray *)tags withRelationship:(Note *)note inManagedContext:(NSManagedObjectContext *)managedObjectContext;

	NSArray *tagsInNote = [self->_tagService arrayOfTagsInText:newNote.text];
	[self->_tagService storeTags:tagsInNote withRelationship:newNote inManagedContext:managedObjectContext];

Doesn't look like it's saving. Time to debug; 
 * Log the size of the array from _arrayOfTagsInText_

It looks like it's definitely storing tags. Lets see if it's loading the tags correctly.

#### Code snippet - Logging existing
	NSLog(@"existingTags - %i", [self->_existingTags count]);

Okay I can code - so it is loading existing tags. Now why aren't there tag buttons?

Well scratch that. I can't code. Turns out that I wasn't providing a string in my
JLButtonScroller method. I was just trying to return a Tag object. The last silly thing
was that I was processing the button scroller before I had loaded the existing tags. 
Hence nothing!

Awesome. Fixing that up displays the existing tags as buttons.

I want it to dynamically display tags based on their current # input. To achieve this I'll
need:
 * A list of all the existing tags
 * A list of current matching tags to a search term
 
But I need to include the keyboard in this.
 1. # character detected
 2. In tag matching state
 3. In keyboard input maintain the characters entered after the #
 4. Match these characters against the names of tags in _existingTags
 5. Store those matches in _matchingTags

This may be fiddly. I'll leave it to a time where I'm not falling asleep. Time to commit.

**josh;**

## 25/04/2012

There are a few major decisions I need to make.

* How will a user add tags in?
* What are the purpose of tags?

**How will a user add tags in?**

I'm considering that I can utilise the twitter keyboard layout. It has the hash key
built in. The major hurdle after that is getting a keyboard event to load existing 
hashes appropriately. This is something I have struggled with in the past. 

**What are the purpose of tags?**

To me they're a way for fast categorisation of notes. You make notes disparately in 
various threads. Tags are a way of linking them together. This has spawned the notion
of making tags into lists. 

I could present another option in the bottom toolbar for users to access lists. This is
dynamically generated by loading up all the tags. Then they will just be presented in a
table view. Nothing special on that front.

It seems to me that people may want to use Notethread in different ways. I don't want to
force it to be a TODO app; nor do I want to restrict that functionality either... 

The intention of the app was to create better organised notes. 

Tags add another dimension without sacrificing the core functionality. There is no break
in how the app works. Perhaps a bad decision? Who knows; but it's the direction I think
it should go. Plus the source code is out there for anyone to change.

### Work log

Updating the version and removing Release-Goals. I don't update it anymore so it's a bit
useless having it there. Adding this development journal instead.

	commit
	push

**NTWriteViewController** - uncommenting some code I had in there before that displayed
a placeholder tag bar. Not sure if this is how I really want to represent tags. Taking a 
look at Tweetbot to see how it handles tags. It looks (albeit so much better) like what 
I'm after. 

First step I think is to actually load up the tags. So I need a managed object. Going to 
have to refer to another project since my mind is drawing a blank.

Awesome. I found some existing code where I used tags as well. Just dragging it in the 
project. Probably going to have to change it a bit though.

#### Code snippet - AppDelegate
	(YourAppDelegateName *)[[UIApplication sharedApplication] delegate];
	
In my previous app I abstracted out into an Application Service layer how to handle Tags. 
This perfectly drops in to Notethread's design. 
The reason I have an Application Service layer is to remove a lot of the pleb worker
logic out of the view controllers. Perhaps it's not really necessary; but it's a choice I
made early on so I'll stick to it. I don't think it's detrimental and serves its purpose.

#### Code snippet - Getting the Tag's from a managed object
	- (Tag *)tagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity =
		[NSEntityDescription entityForName:@"Tag"
					inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@"name == %@", name];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		
		if (array != nil) {
			NSUInteger count = [array count]; // May be 0 if the object has been deleted.
			if (count != 0) {
				return [array lastObject];
			}
		} 
		
		return nil;
	}

I haven't really used ivar's in this project. I'll make the tag service an ivar so it's 
not accessible to anything besides the controller. 

#### Code snippet - ivar access
	self->_tagService
	
Needing something to store the loaded tags as well. 

#### Code snippet - setting up the tag service
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObject = [appDelegate managedObjectContext];
    self->_existingTags = nil;
    self->_existingTags = [self->_tagService arrayExistingTagsIn:managedObject];

I can now use _existingTags in my JLButtonScroller delegate method.

Next step now is to play around with the keyboard and saving tags when saving the note.
This should be relatively simple as the TagService has a method for this.

#### Code snippet - finding tags method signature & saving
	- (NSArray *)arrayOfTagsInText:(NSString *)text
	- (void)storeTags:(NSArray *)tags withRelationship:(Note *)note inManagedContext:(NSManagedObjectContext *)managedObjectContext
	
I'm no longer thinking and I'm hungry so signing off for tonight.

**josh;**


