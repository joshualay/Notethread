//
//  NTNoteController.h
//  Notethread
//
//  Created by Joshua Lay on 29/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
/*
 
    Originally I only had NTWriteViewController & NTNoteViewController. 
 
    Since there was common functionality I decided to create this super class to 
    contain a lot of the common methods. 
 
    Key components in here:
        * Creating the boilerplate for the view
        * Tracking tags
        * Displaying tag buttons and the actions
 */

#import <UIKit/UIKit.h>

#import "JLButtonScroller.h"
#import "TagService.h"
#import "TagTracker.h"
#import "StyleApplicationService.h"

@interface NTNoteController : UIViewController <UITextViewDelegate, JLButtonScrollerDelegate> {
    // Tags
    TagTracker *_tagTracker;
    TagService *_tagService;
    NSArray *_existingTags;
    NSArray *_matchedTags;
    JLButtonScroller *_buttonScroller;
    UIScrollView *_tagButtonScrollView;
    
    // Style Service
    StyleApplicationService *_styleService;
}

@property (strong, nonatomic) IBOutlet UITextView *noteTextView;

- (void)addButtonTagNameToText:(id)sender;


@end
