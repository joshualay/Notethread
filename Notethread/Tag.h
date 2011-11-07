//
//  Tag.h
//  Notethread
//
//  Created by Joshua Lay on 7/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSSet *pages;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addNotesObject:(NSManagedObject *)value;
- (void)removeNotesObject:(NSManagedObject *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addPagesObject:(NSManagedObject *)value;
- (void)removePagesObject:(NSManagedObject *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
