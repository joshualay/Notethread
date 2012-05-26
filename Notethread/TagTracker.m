//
//  TagTracker.m
//  Notethread
//
//  Created by Joshua Lay on 26/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "TagTracker.h"
#import "TagService.h"

@implementation TagTracker

@synthesize tagService=_tagService;
@synthesize currentTagSearch=_currentTagSearch;
@synthesize isTracking=_isTracking;

- (id)initWithTagService:(TagService *)tagService {
    self = [super init];
    if (self) {
        _tagService = tagService;
        _isTracking = NO;
        _currentTagSearch = @"";
    }
    return self;
}

- (NSArray *)arrayOfMatchedTagsInEnteredText:(NSString *)text inTextView:(UITextView *)textView inRange:(NSRange)range withExistingTags:(NSArray *)existingTags {    
    // Back to the start
    if (range.location == 0 && [text isEqualToString:@""]) {
        [self setIsTracking:NO withTermOrNil:nil];        
        return nil;
    }
    
    // deleting
    if (range.length == 1)
        return [self arrayOfMatchedTagsWhenPreviousWordIsTagInText:textView.text fromLocation:range.location withExistingTags:existingTags];
    
    // Entering a #tag
    if ([text isEqualToString:@"#"]) {
        [self setIsTracking:YES withTermOrNil:nil];
        return nil;
    }
    
    // Currently entering a #tag
    if (self.isTracking) {
        if ([text isEqualToString:@" "]) {
            [self setIsTracking:NO withTermOrNil:nil];
            return nil;
        }
        
        self->_currentTagSearch = [NSString stringWithFormat:@"%@%@", self->_currentTagSearch, text];
        return [self.tagService arrayOfMatchingTags:self.currentTagSearch inArray:existingTags];
    }
    
    return nil;
}

- (NSArray *)arrayOfMatchedTagsWhenPreviousWordIsTagInText:(NSString *)text fromLocation:(NSUInteger)location withExistingTags:(NSArray *)existingTags {
    NSString *prevTag = [self.tagService stringTagPreviousWordInText:text fromLocation:location];
    BOOL isTracking = (prevTag == nil) ? NO : YES;
    [self setIsTracking:isTracking withTermOrNil:prevTag];
    
    if (prevTag != nil)
        return [self.tagService arrayOfMatchingTags:self->_currentTagSearch inArray:existingTags];
    
    return nil;
}

- (void)setIsTracking:(BOOL)isTracking withTermOrNil:(NSString *)term {
    _isTracking = isTracking;
    if (term == nil)
        term = @"";
    
    _currentTagSearch = term;
}

@end
