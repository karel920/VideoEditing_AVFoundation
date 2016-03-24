//
//  UIColor+Helper.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/12/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "UIColor+Helper.h"

@implementation UIColor (Helper)

// Thanks to http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor
+ (UIColor *) colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) prepHeroBlueColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"1A3767"];
    });
    
    return color;
}

+ (UIColor *) prepHeroYellowColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"EAAA12"];
    });
    
    return color;
}
+ (UIColor *) deepPurpleColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"673AB7"];
    });
    
    return color;
}


+ (UIColor *)facebookButtonBackgroundColor {
    
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorWithRed:58.0f/255.0f
                                green:89.0f/255.0f
                                 blue:152.0f/255.0f
                                alpha:1.0f];
    });
    
    return color;
}

+ (UIColor *)twitterButtonBackgroundColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorWithRed:45.0f/255.0f
                                green:170.0f/255.0f
                                 blue:1.0f
                                alpha:1.0f];
    });
    
    return color;
}

+ (UIColor *) prepheroGrayColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"ecf0f1"];
    });
    
    return color;
}

+ (UIColor *) prepheroRedColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"e74c3c"];
    });
    
    return color;
}

+ (UIColor *) prepheroGreenColor {
    static UIColor *color = nil;
    static dispatch_once_t dispatchToken;
    
    dispatch_once(&dispatchToken, ^{
        color = [UIColor colorFromHexCode:@"2ecc71"];
    });
    
    return color;
}

@end
