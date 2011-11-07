//
//  Note.h
//  Notethread
//
//  Created by Joshua Lay on 7/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSManagedObject *page;
@property (nonatomic, retain) NSSet *noteThreads;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addNoteThreadsObject:(Note *)value;
- (void)removeNoteThreadsObject:(Note *)value;
- (void)addNoteThreads:(NSSet *)values;
- (void)removeNoteThreads:(NSSet *)values;

@end
