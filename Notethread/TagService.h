//
//  TagService.h
//  Notethread
//
//  Created by Joshua Lay on 24/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag;
@class Note;

@interface TagService : NSObject {
    
}

- (Tag *)tagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (bool)doesTagExist:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (Tag *)loadTagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (NSRegularExpression *)regularExpressionForTag;
- (NSArray *)arrayExistingTagsIn:(NSManagedObjectContext *)managedObjectContext;
- (UIFont *)fontTag;
- (void)storeTags:(NSArray *)tags withRelationship:(Note *)note inManagedContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)arrayOfTagsInText:(NSString *)text;
- (NSArray *)arrayOfMatchingTags:(NSString *)term inArray:(NSArray *)existingTags;

@end
