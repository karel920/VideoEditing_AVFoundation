//
//  UIVIew+Helper.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/13/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "UIVIew+Helper.h"


@implementation UIView (AutoLayout)

+(id)autolayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

@end
