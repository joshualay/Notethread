//
//  Note.h
//  Notethread
//
//  Created by Joshua Lay on 30/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note, Tag;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSOrderedSet *noteThreads;
@property (nonatomic, retain) Note *parentNote;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)insertObject:(Note *)value inNoteThreadsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNoteThreadsAtIndex:(NSUInteger)idx;
- (void)insertNoteThreads:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNoteThreadsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNoteThreadsAtIndex:(NSUInteger)idx withObject:(Note *)value;
- (void)replaceNoteThreadsAtIndexes:(NSIndexSet *)indexes withNoteThreads:(NSArray *)values;
- (void)addNoteThreadsObject:(Note *)value;
- (void)removeNoteThreadsObject:(Note *)value;
- (void)addNoteThreads:(NSOrderedSet *)values;
- (void)removeNoteThreads:(NSOrderedSet *)values;
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
