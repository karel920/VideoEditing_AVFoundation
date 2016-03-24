//
//  UIColor+Helper.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/12/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Helper)

+ (UIColor *) colorFromHexCode:(NSString *)hexString;
+ (UIColor *) prepHeroYellowColor;
+ (UIColor *) prepHeroBlueColor;
+ (UIColor *) deepPurpleColor;
+ (UIColor *) facebookButtonBackgroundColor;
+ (UIColor *) twitterButtonBackgroundColor;
+ (UIColor *) prepheroGrayColor;
+ (UIColor *) prepheroRedColor;
+ (UIColor *) prepheroGreenColor;

@end
