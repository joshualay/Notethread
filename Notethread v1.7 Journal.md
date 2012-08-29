# Notethread v1.7 Journal 

Goals:

* Colour schemes - for evening
* Tree list view for your notes

---

## 25/08/2012

Possible settings overrides:
 * Navigation
 * Toolbox
 * Table view background
 * Note view background
 * Settings page
 * Font colour
 * Action bar colour
 * Tag scroll view background
 * Tag scroll view button colour
 * Tag scroll view font colour

I'll have to do some refactoring in order to customise it better.

I don't want to have to look up a dictionary each time though to get the colour value as it may be expensive?

## 27/08/2012

I'm leaving the colour scheme things on the way-side for the moment. Getting a tree view is more intruiging to me.

One way of implementing this I've been considering is adding a pull from top to reveal additional view options.
The UI to me is already a little busy; a tree is secondary to writing notes so I think hiding it away may be better.

The issue becomes how do I implement this without breaking everything? 

I could nest it in a scrollview and change the offset. Actually I can just add it as an action! That's easy.

For the notetree I'm thinking of using the button scroll view:


[top level note]

----------------

[sub note] [sub note] [sub note]

----------------

[2nd tier note] [2nd tier note]

----------------

When the button is tapped it will open up the note in a dialogue.