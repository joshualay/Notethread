//
//  ColourScheme.h
//  Notethread
//
//  Created by Joshua Lay on 25/08/12.
//  Copyright (c) 2012 Joshua Lay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ColourSchemeNameDefault,
    ColourSchemeNameEvening
} ColourSchemeName;

@interface ColourScheme : NSObject {
    NSDictionary *_colourSettings;
}

@property (nonatomic, strong) NSDictionary *settings;

- (id)initWithColourSchemeName:(ColourSchemeName)name;

@end
