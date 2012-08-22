//
//  TagTracker.h
//  Notethread
//
//  Created by Joshua Lay on 26/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//
/*
    This class was created to push out knowledge on how tag tracking is done in a UITextView.
 
    When the user is typing I want to know:
        * When a # has been typed so I can start tracking
        * When the #tag has finished and another word is being typed
        * When deleting text if the end of a #tag has been hit
        * When selecting text to know if it's a tag
 
    This class works in tandem with TagService and is used in conjuction with JLButtonScrollerDelegate
    method implementations.
 */

#import <Foundation/Foundation.h>

@class TagService;

@interface TagTracker : NSObject

@property (nonatomic, strong) TagService *tagService;
@property (nonatomic, strong) NSString *currentTagSearch;
@property (nonatomic, readonly) BOOL isTracking; 

- (id)initWithTagService:(TagService *)tagService;

- (NSArray *)arrayOfMatchedTagsWhenCurrentWordIsTagInText:(NSString *)text fromLocation:(NSUInteger)location withExistingTags:(NSArray *)existingTags;
- (NSArray *)arrayOfMatchedTagsInEnteredText:(NSString *)text inTextView:(UITextView *)textView inRange:(NSRange)range withExistingTags:(NSArray *)existingTags;
- (NSArray *)arrayOfMatchedTagsWhenPreviousWordIsTagInText:(NSString *)text fromLocation:(NSUInteger)location withExistingTags:(NSArray *)existingTags;
- (void)setIsTracking:(BOOL)isTracking withTermOrNil:(NSString *)term;

@end
