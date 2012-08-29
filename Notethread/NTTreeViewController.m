//
//  NTTreeViewController.m
//  Notethread
//
//  Created by Joshua Lay on 27/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NTTreeViewController.h"
#import "Note.h"
#import <objc/runtime.h>

/* 
 So I can assign a Note per button
 
 http://stackoverflow.com/a/5287141
 */
@interface UIButton (NoteModel)
@property (nonatomic, strong) Note *note;
@end

@implementation UIButton (NoteModel)
static char noteKey;

- (void)setNote:(Note *)note {
    objc_setAssociatedObject( self, &noteKey, note, OBJC_ASSOCIATION_RETAIN );
}

- (Note *)note {
    return objc_getAssociatedObject(self, &noteKey);
}
@end



@interface NTTreeViewController ()
- (void)willDismissModalView:(id)sender;
- (void)presentPopTipNote:(UIButton *)sender;
@end

@implementation NTTreeViewController

@synthesize note = _note;
@synthesize scrollView;

- (id)initWithNote:(Note *)note {
    self = [super initWithNibName:@"NTTreeViewController" bundle:nil];
    if (self) {
        self.note = note;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(willDismissModalView:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIButton *start = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [start addTarget:self action:@selector(presentPopTipNote:) forControlEvents:UIControlEventTouchUpInside];
    start.note = self.note;
    [self.scrollView addSubview:start];
    
    UIButton *child = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [child addTarget:self action:@selector(presentPopTipNote:) forControlEvents:UIControlEventTouchUpInside];
    child.note = [self.note.noteThreads firstObject];
    child.frame = CGRectMake(50.0f, 100.0f, 10.0f, 10.0f);
    [self.scrollView addSubview:child];
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



- (void)willDismissModalView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)presentPopTipNote:(UIButton *)sender {
    self.popTipView = [[CMPopTipView alloc] initWithMessage:sender.note.text];
    self.popTipView.delegate = self;
    [self.popTipView presentPointingAtView:sender inView:self.scrollView animated:NO];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [self.popTipView dismissAnimated:NO];
    self.popTipView.delegate = nil;
    self.popTipView = nil;
}

@end
