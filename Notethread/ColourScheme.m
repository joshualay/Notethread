//
//  ColourScheme.m
//  Notethread
//
//  Created by Joshua Lay on 25/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import "ColourScheme.h"

@interface ColourScheme()
- (NSDictionary *)loadColourSettings;
- (NSDictionary *)loadSetting:(ColourSchemeName)name;

- (NSDictionary *)dictionaryDefaultColourSettings;
- (NSDictionary *)dictionaryEveningColourSettings;
@end

@implementation ColourScheme

@synthesize settings;

- (id)initWithColourSchemeName:(ColourSchemeName)name {
    self = [super init];
    if (self) {
        _colourSettings = [self loadColourSettings];
        settings = [self loadSetting:name];
    }
    return self;
}

- (NSDictionary *)dictionaryDefaultColourSettings {
    return [[NSDictionary alloc] init];
}

- (NSDictionary *)dictionaryEveningColourSettings {
    return [[NSDictionary alloc] init];    
}

- (NSDictionary *)loadColourSettings {
    return [[NSDictionary alloc]
            initWithObjects:[NSArray arrayWithObjects:[self dictionaryDefaultColourSettings], [self dictionaryEveningColourSettings], nil]
            forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInt:ColourSchemeNameDefault], [NSNumber numberWithInt:ColourSchemeNameEvening], nil]];
}

- (NSDictionary *)loadSetting:(ColourSchemeName)name {
    return [self->_colourSettings objectForKey:[NSNumber numberWithInt:name]];
}

@end
