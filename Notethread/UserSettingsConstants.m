//
//  UserSettingsConstants.m
//  Notethread
//
//  Created by Joshua Lay on 23/11/11.
//  Copyright (c) 2011 Joshua Lay. All rights reserved.
//

#import "UserSettingsConstants.h"

NSString * const ThreadRowsDisplayedKey = @"ThreadRowsDisplayed";
NSInteger const ThreadRowsDisplayedDefault = 5;
NSInteger const ThreadRowsDisplayedMaxRows = 8;

NSString *const FontFamilyNameDefaultKey = @"FontFamily";
NSString *const FontFamilySerif = @"Georgia";
NSString *const FontFamilySerifAlt = @"Marion-Regular";
NSString *const FontFamilySansSerif = @"Helvetica";
NSString *const FontFamilySansSerifAlt = @"GillSans";

NSString *const FontFamilyNameDefault = @"Helvetica";

NSString *const  FontWritingSizeKey = @"FontWritingSize";
CGFloat const    FontWritingSizeDefault = 18.0f;

CGFloat const    FontLabelSizeDefault = 16.0f;

CGFloat const    FontNoteSizeSmall = 16.0f;
CGFloat const    FontNoteSizeNormal = 18.0f;
CGFloat const    FontNoteSizeLarge = 20.0f;

NSString *const KeywordTagsKey = @"KeywordTags";