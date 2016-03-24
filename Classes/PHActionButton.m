//
//  PHActionButton.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/23/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "PHActionButton.h"
@interface PHActionButton ()

- (instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
@end
@implementation PHActionButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

- (instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    return [super initWithCoder:decoder];
}

- (instancetype)initWithBackgroundImageColor:(UIColor *)color {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    
    [self setBackgroundImage:[UIImage imageWithColor:color cornerRadius:10.0f] forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.imageEdgeInsets = UIEdgeInsetsZero;
    self.contentEdgeInsets = UIEdgeInsetsZero;
    return self;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (CGSize)sizeThatFits:(CGSize)boundingSize {
    CGSize size = CGSizeZero;
    size.width = boundingSize.width;
    size.height = MIN(30.0f, boundingSize.height);
    return size;
}



@end
