//
//  UIImage+Helper.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/16/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//
// Source from FlatUIKit https://github.com/Grouper/FlatUIKit/
#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *) buttonImageWithColor:(UIColor *)color
                      cornerRadius:(CGFloat)cornerRadius
                       shadowColor:(UIColor *)shadowColor
                      shadowInsets:(UIEdgeInsets)shadowInsets;
@end
