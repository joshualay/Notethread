//
//  TagService.h
//  Notethread
//
//  Created by Joshua Lay on 24/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//
/* 
    This class understands:
        * How to retrieve tags
        * How to save tags
        * What a tag looks like
 */

#import <Foundation/Foundation.h>

@class Tag;
@class Note;

@interface TagService : NSObject {

}

// From user settings - tags we don't want to display in the tag list
@property (nonatomic, strong) NSArray *filteredTags;

// Fetch a tag from Core Data matching the name: Name is supplied without a #
- (Tag *)tagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
// Simple check to determine if a tag should be created or not
- (bool)doesTagExist:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (Tag *)loadTagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
// The rule for what makes up a tag
- (NSRegularExpression *)regularExpressionForTag;
// Fetches out all tags from the managed object context
- (NSArray *)arrayExistingTagsIn:(NSManagedObjectContext *)managedObjectContext;
// Tags are displaying in multiple places; putting what it should look like in this service
- (UIFont *)fontTag;
// Understands the relationships between notes and tags to make it easier to save
- (void)storeTags:(NSArray *)tags withRelationship:(Note *)note inManagedContext:(NSManagedObjectContext *)managedObjectContext;
// Filter through an NSString to find any word that matches regularExpressionForTag
- (NSArray *)arrayOfTagsInText:(NSString *)text;
// For a collection of Tags - existingTags = new Tag[] - see if any match term
- (NSArray *)arrayOfMatchingTagsForTerm:(NSString *)term inExistingTags:(NSArray *)existingTags;
// Fetch the previous word from a location, determine if it's a tag and pass back it's name if so
- (NSString *)tagNameOrNilOfPreviousWordInText:(NSString *)text fromLocation:(NSUInteger)location;
// For filtering out our reserved #tag's from user settings
- (BOOL)doesContainFilteredTagInTagSet:(NSSet *)tags;

@end
