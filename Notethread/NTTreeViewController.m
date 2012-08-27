//
//  NTTreeViewController.m
//  Notethread
//
//  Created by Joshua Lay on 27/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NTTreeViewController.h"
#import "Note.h"

@interface NTTreeViewController ()

@end

@implementation NTTreeViewController

@synthesize note = _note;

- (id)initWithNote:(Note *)note {
    self = [super initWithNibName:@"NTTreeViewController" bundle:nil];
    if (self) {
        self.note = note;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
