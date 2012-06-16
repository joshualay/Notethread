//
//  TagService.m
//  Notethread
//
//  Created by Joshua Lay on 24/09/11.
//  Copyright 2011 Joshua Lay. All rights reserved.
//

#import "TagService.h"
#import "Tag.h"
#import "Note.h"
#include "NSArray+Reverse.h"

@interface TagService (Private)
- (NSString *)stringWordTillPreviousSpaceInText:(NSString *)text fromLocation:(NSUInteger)location;
@end

@implementation TagService

- (Tag *)tagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Tag"
                inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"name == %@", name];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array != nil) {
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            return [array lastObject];
        }
    } 
    
    return nil;
}

- (NSArray *)arrayOfMatchingTagsForTerm:(NSString *)term inExistingTags:(NSArray *)existingTags {
    
    NSMutableArray *matchedExistingTags = [[NSMutableArray alloc] initWithCapacity:[existingTags count]];
    for (Tag *tag in existingTags) {
        NSComparisonResult result = [tag.name compare:term options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [term length])];
        if (result == NSOrderedSame)
        {
            [matchedExistingTags addObject:tag];
        }
    }
    
    return matchedExistingTags;
}

- (bool)doesTagExist:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext {
    if ([self tagWithName:name inManagedContext:managedObjectContext] != nil) {
        return TRUE;
    }
    return FALSE;
}

- (Tag *)loadTagWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)managedObjectContext {
    return [self tagWithName:name inManagedContext:managedObjectContext];
}

- (NSArray *)arrayExistingTagsIn:(NSManagedObjectContext *)managedObjectContext {
    //TODO sort tags by frequency?
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
        
    NSError *error;
	return [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (UIFont *)fontTag {
    return [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.0];
}

- (NSRegularExpression *)regularExpressionForTag {
    NSError *error = NULL;
    return [[NSRegularExpression alloc] initWithPattern:@"#(\\w+)" options:NSRegularExpressionCaseInsensitive error:&error];
}

- (void)storeTags:(NSArray *)tags withRelationship:(Note *)note inManagedContext:(NSManagedObjectContext *)managedObjectContext {
    if (![tags count])
        return;
    
    for (NSString *tag in tags) {
        if ([self doesTagExist:tag inManagedContext:managedObjectContext]) {
            Tag *tagObject = [self loadTagWithName:tag inManagedContext:managedObjectContext];
            int frequency = [tagObject.frequency intValue] + 1;
            tagObject.frequency = [NSNumber numberWithInt:frequency];
            [tagObject addNotesObject:note];
            [note addTagsObject:tagObject];
        }
        else {
            Tag *tagObject = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:managedObjectContext];
            tagObject.name = [tag copy];
            tagObject.frequency = [NSNumber numberWithInt:1];
            [tagObject addNotesObject:note];
            [note addTagsObject:tagObject];
        }
    }
}

- (NSArray *)arrayOfTagsInText:(NSString *)text {
    NSMutableArray *outfitTags = [[NSMutableArray alloc] init];
    NSRegularExpression *tagRegEx = [self regularExpressionForTag];
    [tagRegEx enumerateMatchesInString:text 
                               options:0 
                                 range:NSMakeRange(0, [text length]) 
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
                                NSString *tagToAdd = [[text substringWithRange:result.range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
                                [outfitTags addObject:tagToAdd];
                            }];
    return outfitTags;
}

- (NSString *)stringTagPreviousWordInText:(NSString *)text fromLocation:(NSUInteger)location {
    NSString *prevWord = [self stringWordTillPreviousSpaceInText:text fromLocation:location];
    
    NSArray *tags = [self arrayOfTagsInText:prevWord];
    if ([tags count])
        return [tags objectAtIndex:0];
    
    return nil;
}

- (NSString *)stringTagCurrentWordInText:(NSString *)text fromLocation:(NSUInteger)location {
    NSString *prevWord = [self stringWordTillPreviousSpaceInText:text fromLocation:location];
    NSArray *matched = [self arrayOfTagsInText:prevWord];
    
    if ([matched count])
        return [matched lastObject];
    
    return nil;
}


#pragma mark - Private
- (NSString *)stringWordTillPreviousSpaceInText:(NSString *)text fromLocation:(NSUInteger)location {
    BOOL isSpaceCharacter = NO;
    
    NSMutableArray *foundCharacters = [[NSMutableArray alloc] init];
    
    // Start after
    location = location - 1;
    while (!isSpaceCharacter) {
        unichar prevChar = [text characterAtIndex:location];
        NSString *prevCharStr = [NSString stringWithFormat:@"%C", prevChar];
        
        if ([prevCharStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
            isSpaceCharacter = YES;
            break;
        }
        
        [foundCharacters addObject:prevCharStr];
        location--;
    }
    
    NSArray *orderedFoundCharacters = [foundCharacters reverseArray];
    NSMutableString *prevWord = [[NSMutableString alloc] initWithCapacity:[orderedFoundCharacters count]];
    for (NSString *str in orderedFoundCharacters) {
        [prevWord appendString:str];
    }
    
    return prevWord;
}

@end
