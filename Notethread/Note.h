//
//  Note.h
//  Notethread
//
//  Created by Joshua Lay on 7/11/11.
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
@property (nonatomic, retain) NSSet *noteThreads;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Note *parentNote;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addNoteThreadsObject:(Note *)value;
- (void)removeNoteThreadsObject:(Note *)value;
- (void)addNoteThreads:(NSSet *)values;
- (void)removeNoteThreads:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
