# Notethread v1.6 Journal 

The goal of this release is give more power to #tags. I want to be able to create a list function that displays all notes under a certain tag as list items. 

As you may have a certain tag in different notes this will just show them all in the one list; making it easy to have a quick overview.


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