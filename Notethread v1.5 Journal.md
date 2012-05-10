# Notethread v1.5 Journal 

The goal of this release is to attempt to get tags into play.

## 10/05/2012

Get the sizing correct for the note text view when the tag scroll view is displayed. I'm thinking it may be worthwhile to display always. I'll see how that flows first.

### Work log

Starting to display the scroll view always - play around with that.

Since I have my mega hacks (™) in here for the sizing I'm offsetting the note text view with the height of the scroll view. 

Now I noticed that not only can i scroll horizontally; I can scroll vertically as well for the tag scroll view. I don't think that works at all. In order to fix this:

[Stackoverflow answer](http://stackoverflow.com/a/5095989/626078)

I'll do it in JLButtonScroller:

**JLButtonScroller.h**

	@interface JLButtonScroller : NSObject <UIScrollViewDelegate> {

**JLButtonScroller.m**

	- (void)addButtonsForContentAreaIn:(UIScrollView *)scrollView {
		scrollView.delegate = self;
		//...
	}
	
	#pragma mark - UIScrollViewDelegate 
	- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	    [aScrollView setContentOffset: CGPointMake(aScrollView.contentOffset.x, 0)];
	}

That fixes the issue!

When deleting text in a tag - it doesn't seem to keep track that we're still in a tag :(

Just tidying up a few things before I call it a night.



## 08/05/2012

Just mucking around with the tag button

### Work log

Creating a gradient PNG to use as the background image for the tag buttons.

	    [tagButton setBackgroundImage:[UIImage imageNamed:@"button_normal_gradient.png"] forState:UIControlStateNormal];

Now the result of this is that the buttons are stuck up right next to each other. I'll need to create a buffer.

Had to modify JLButtonScroller to put an off set between the buttons. 

After much mucking around. I'm going to get rid of the images.

Going for the ever classic "gray" look:

    self->_tagButtonScrollView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.5f];

In order to change the background colour when selected from awesome bright blue:

	[tagButton setTintColor:[UIColor lightTextColor]];
	[tagButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];

When selecting a tag via the button I've added a space after and reset the tag buttons. Reason being is that if you tap the button you want that tag and are ready to carry on typing. No need to leave the tag buttons up there.

**Just noticed that I need to adjust the text view when the tag scroll view is displayed. Bugger.**

**Need to add tag saving for the NTNoteViewController - and then the rest of the tag functionality**

## 05/05/2012

Making the tag buttons work. 

### Work log

As a guess I'm going to try and add a gesture recogniser to the button

	- (UIButton *)buttonForIndex:(NSInteger)position {
		UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		UIGestureRecognizer *tap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(addButtonTagNameToText:)];
		[tagButton addGestureRecognizer:tap];
		
		return tagButton;
	}

That didn't work. I need to add a target and control type

#### Code snippet - Adding a touch up inside event to a UIButton

	[tagButton addTarget:self action:@selector(addButtonTagNameToText:) forControlEvents:UIControlEventTouchUpInside];

Now to get the text of the button to push into the UITextView. 

The signature of the @selector looks like this

	- (void)addButtonTagNameToText:(id)sender;

This means that **sender** will be the UIButton that was touched. The method body can 
now access the button's text.

#### Code snippet - (id)sender to (UIButton)

    UIButton *button = (UIButton *)sender;
    NSString *tag = button.titleLabel.text;
    
First issue. The user will have already entered in characters from the tag. What has to
happen is determining what they've currently entered and fill in the rest. 

I'm thinking that from the current selected location I can work backwards to get the 
text. 

That wasn't too hard. Re-used a method from my TagService and just did some simple
string replacement. 

#### Code snippet - Completing the tag text in the text view

	- (void)addButtonTagNameToText:(id)sender {
		UIButton *button = (UIButton *)sender;
		
		NSString *tagString = button.titleLabel.text;
		NSUInteger insertionLocation = self.noteTextView.selectedRange.location;
			
		NSMutableString *noteText = [self.noteTextView.text mutableCopy];
		
		NSString *prevTag = [self->_tagService stringTagPreviousWordInText:noteText fromLocation:insertionLocation];
		NSUInteger enteredLength = [prevTag length];
		NSUInteger tagStartLocation = insertionLocation - enteredLength;
		NSRange range = NSMakeRange(tagStartLocation, enteredLength);
		
		[noteText replaceCharactersInRange:range withString:tagString];
		
		self.noteTextView.text = noteText;
	}
	
Just playing around with the look of the tag bar and buttons.

**Need to change the search to add tags as a classifier**

> possible feature: When double tapping the action bar in the view it drops down to the 
> bottom so you can view the note full screen until you tap it

Doing up a simple texture for the tag scroll view. Keeping it a darker colour. I don't
feel it should be the same as the action bar seen when you view the note. As this is
dynamically generated only when a tag is entered. 

This makes me think... since that tag scroll view is single featured I will hide it until
there's actually a matching tag.

Might make a sliding animation for it.

	typedef enum {
    	NTDirectionUp,
    	NTDirectionDown
	} NTDirection;
	
	- (void)slideToggleDirection:(NTDirection)direction;

Actually no. That's too frivolous. 

Having trouble trying to change the background colour of a UIButton. If I change the
text's background it's still leaving white around and I can't seem to access that layer.

**josh;**

## 02/05/2012

Quick refactoring of the resetting tag/hash tracking code.

### Work log

#### Code snippet - reset tag tracking method

	#pragma mark - (Private)
	- (void)resetTagTracking:(BOOL)isTracking withTermOrNil:(NSString *)term {
		if (term == nil)
			term = @"";
		
		self->_isEnteringTag = isTracking;
		self->_matchedTags = nil;
		self->_currentTagSearch = term;
	}

Now I need to work out how to detect the cursor position when the user taps in the text
view. I don't think any of the delegate methods from UITextViewDelegate allow this. 

#### Code snippet - UITextViewDelegate methods

	- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
	- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
	
	- (void)textViewDidBeginEditing:(UITextView *)textView;
	- (void)textViewDidEndEditing:(UITextView *)textView;
	
	- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
	- (void)textViewDidChange:(UITextView *)textView;
	
	- (void)textViewDidChangeSelection:(UITextView *)textView;

Come to think of it; there's only one method which provides a range. The rest just 
pass in the text view itself. _textView:shouldChangeTextInRange:replacementText_ is the 
only one and that doesn't update upon touch. 

It's likely I'll have to override UITextView to steal that touch event to get more
information.

[Looks like there are some hints here](http://stackoverflow.com/questions/618759/getting-cursor-position-in-a-uitextview-on-the-iphone)

Going to check out the documentation: [UITextView](http://developer.apple.com/library/ios/#documentation/uikit/reference/UITextView_Class/Reference/UITextView.html)

Okay so I was wrong about no delegate methods being useful:

	- (void)textViewDidChangeSelection:(UITextView *)textView;
	
When the user taps elsewhere in the view this is going to get called. Now I combine
it with this:

	// UITextView
	@property(nonatomic) NSRange selectedRange

To confirm:

	- (void)textViewDidChangeSelection:(UITextView *)textView {
    	NSLog(@"textViewDidChangeSelection: range = %i", textView.selectedRange.location);
	}

Okay wicked that works. 

**Refactor the code to check if the previous word is a #tag to update the tag scroll view**

I've refactored out this previous word checking code to the TagService. 

Now to get this working for the **textViewDidChangeSelection** scenario. 

Wooo crash! I'm guessing I'm doing something silly.

	2012-05-02 21:30:17.737 Notethread[15682:15203] *** Terminating app due to uncaught exception 'NSRangeException', reason: '-[__NSCFString characterAtIndex:]: Range or index out of bounds'


	- (void)textViewDidChangeSelection:(UITextView *)textView {
		NSUInteger location = textView.selectedRange.location;
		if (location == 0)
			return;
		
		NSString *prevTag = [self->_tagService stringTagPreviousWordInText:textView.text fromLocation:location];
		BOOL isTracking = (prevTag == nil) ? NO : YES;
		[self resetTagTracking:isTracking withTermOrNil:prevTag];
		
		if (prevTag != nil)
			self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
		
		[self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
	}

It looks like when the view first loads this delegate method is called. So from 
debugging I can see:
	
	textView.selectedRange.location == 2147483647

Time for a sanity check in there. Just need to make sure the textView.text is not zero.

	if (location == 0 || ![textView.text length])

This has solved the problem! It looks like the #tag detection is working okay. I still
have a few edge cases; but this is good progress.

Refactored it once again. 

Next step is making those tag buttons work and add the tag after the current cursor 
position.

**josh;**

## 01/05/2012

This session is yet again working on # detection. 

There's also an issue when editing - the tag's don't show up. I'm guessing it's because
I need to implement it another class. I'm going to tackle this first as it may require
some refactoring.

### Work log

Having a look around in NTNoteViewController and it looks like it does create a 
NTWriteViewController. This means it should show in the view. 

As a note; the current implementation of a @protocol is poor. This was due to my lack of
understanding. However they serve their purpose and the app works. I wouldn't 
recommend what I've done though :)

Ah my bad. When I'm creating a child note then it's okay. It's when I'm editing which is
the issue. This may be a hassle. I'll have to refactor a few things. In order to not
halt progress I'm going to scratch fixing this now. 

On to making the detection work properly. 

Issues:

* When deleting characters it will not clear if the tag is the first item
* Pretty much deleting anywhere it doesn't clear
* When the cursor is on a #tag it doesn't realise this

How can I fix this?

First step is to start logging what's going on:

#### Code snippet - Logging UITextViewDelegate

	#pragma UITextViewDelegate
	- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
		NSLog(@"range.location = %i, range.length = %i, replacementText = %@", range.location, range.length, text);

Interesting points to note:

* Entering any character gives **range.length == 0**
* Deleting any character gives **range.length == 1**

My issue is that if I'm deleting characters and I hit a word... how do I know that? 

	- (NSArray *)componentsSeparatedByString:(NSString *)separator
	
Offers a solution of giving me an array of strings; but it's missing useful information
such as their location. 

I'm thinking of working backwards from my current location to detect if the character
before the location is the end of a word. 

#### Code snippet - converting unichar to NSString

[via Stackoverflow](http://stackoverflow.com/a/1354413/626078)

        unichar prevChar = [textView.text characterAtIndex:(range.location - 1)];
        NSString *prevCharStr = [NSString stringWithFormat:@"%C", prevChar];

Using that method I've got something workable.

#### Code snippet - Grabbing the previous word and detecting if it's a tag

	// For reverseArray method
	@implementation NSArray (reverse)
	- (NSArray *)reverseArray {
		NSMutableArray *array =
		[NSMutableArray arrayWithCapacity:[self count]];
		NSEnumerator *enumerator = [self reverseObjectEnumerator];
		for (id element in enumerator) {
			[array addObject:element];
		}
		return array;
	}
	@end

	// deleting
    if (range.length == 1) {
        BOOL isSpaceCharacter = NO;
        
        NSMutableArray *foundCharacters = [[NSMutableArray alloc] init];
        NSUInteger location = range.location - 1;
        while (!isSpaceCharacter) {
            unichar prevChar = [textView.text characterAtIndex:location];
            NSString *prevCharStr = [NSString stringWithFormat:@"%C", prevChar];
            
            if ([prevCharStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
                isSpaceCharacter = YES;
                break;
            }
            
            [foundCharacters addObject:prevCharStr];
            location--;
        }
        
        NSArray *orderedFoundCharacters = [foundCharacters reverseArray];
        NSMutableString *prevWord = [[NSMutableString alloc] initWithCapacity:[orderedFoundCharacters count]];
        for (NSString *str in orderedFoundCharacters) {
            [prevWord appendString:str];
        }
        
        NSArray *tags = [self->_tagService arrayOfTagsInText:prevWord];
        if ([tags count]) {
            NSString *prevTag = [tags objectAtIndex:0];
                        
            self->_isEnteringTag = YES;
            self->_currentTagSearch = prevTag;
            self->_matchedTags = nil;
            self->_matchedTags = [self->_tagService arrayOfMatchingTags:self->_currentTagSearch inArray:self->_existingTags];
            [self->_buttonScroller addButtonsForContentAreaIn:self->_tagButtonScrollView];
        }

Next is to do this kind of thing when the user changes where the cursor is with their 
fingers.

**josh;**

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



