//
//  NTNoteViewController.m
//  Notethread
//
//  Created by Joshua Lay on 13/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "NTNoteViewController.h"
#import "StyleApplicationService.h"

@implementation NTNoteViewController

@synthesize note      = _note;
@synthesize noteLabel = _noteLabel;

/* TODO
 Label 
 
 
 Size the label to the correct height of the text. I believe this can be done with an existing method.
 Check aporter.
 */

- (id)init {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        
    }
    return self;  
}

// Not used
- (id)initWithNote:(Note *)note {
    self = [super initWithNibName:@"NTNoteViewController" bundle:nil];
    if (self) {
        _note = note;
    }
    return self;  
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noteLabel.text = self.note.text;
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    
    [self.noteLabel sizeToFit];
    
    StyleApplicationService *styleApplicationService = [StyleApplicationService sharedSingleton];
    self.noteLabel.font = [styleApplicationService fontNoteView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
