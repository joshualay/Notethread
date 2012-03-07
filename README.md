# Notethread

> Joshua Lay _me@joshualay.net_

## About
This is the most current version of my Notethread app that is available on the AppStore.Please learn and improve what I have done. Create your own app from this source code if possible, or at least see how to, or how not to do things :)


## The code

### Protocol's

I created two protocol's so I could at least make it consistent on what viewing and writing a Notethread should be.

* NTThreadViewDelegate
* NTThreadWriteViewDelegate

### Application Services

These are singleton classes to just provide common information between all the view controllers. I wanted to centralise certain information and considered this design pattern more appropriate for it.

### App flow

The main view controller is - **NTNoteListViewController**. It has a unique view as it only displays our top level Notethreads. 

#### View notes

Each Notethread you tap on will open a **NTNoteViewController**. 

This displays:
> *your note*
> -----------
> **toolbar**
> -----------
> * note thread
> * note thread

Tapping on any notethread will open another **NTNoteViewController**. 

#### Editing notes

The note area can be tapped on to start editing, or the edit button can be used.

#### Creating notes

From **NTNoteListViewController** tapping the compose button will open a **NTWriteViewController** for you to write your new Notethread.





## License
The MIT License (MIT)

Copyright (c) 2012 Joshua Lay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
