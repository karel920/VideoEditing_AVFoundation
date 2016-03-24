//
//  PHUtil.h
//  PrepHero
//
//  Created by Xinjiang Shao on 7/17/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIColor+Helper.h"
#import "UIImage+Helper.h"
#import "UIVIew+Helper.h"
#import <NSString+FontAwesome.h>
#import <UIFont+FontAwesome.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IOS7_OR_LESS (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
#define IS_IOS8 (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_3 && floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)
#define IS_IOS9 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_3)

@interface PHUtil : NSObject

+ (instancetype)sharedInstance;

- (NSManagedObjectContext *)managedObjectContext;

- (NSString *)getVersion;

@end
