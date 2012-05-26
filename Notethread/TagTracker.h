//
//  TagTracker.h
//  Notethread
//
//  Created by Joshua Lay on 26/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TagService;

@interface TagTracker : NSObject

@property (nonatomic, strong) TagService *tagService;
@property (nonatomic, strong) NSString *currentTagSearch;
@property (nonatomic, readonly) BOOL isTracking; 

- (id)initWithTagService:(TagService *)tagService;


- (NSArray *)arrayOfMatchedTagsInEnteredText:(NSString *)text inTextView:(UITextView *)textView inRange:(NSRange)range withExistingTags:(NSArray *)existingTags;
- (NSArray *)arrayOfMatchedTagsWhenPreviousWordIsTagInText:(NSString *)text fromLocation:(NSUInteger)location withExistingTags:(NSArray *)existingTags;
- (void)setIsTracking:(BOOL)isTracking withTermOrNil:(NSString *)term;

@end
