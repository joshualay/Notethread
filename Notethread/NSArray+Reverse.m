//
//  NSArray+Reverse.m
//  Notethread
//
//  Created by Joshua Lay on 22/05/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reverseArray {
    NSMutableArray *array =
    [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end