//
//  PHPageViewController.h
//  PrepHero
//
//  Created by Xinjiang Shao on 8/19/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHPageViewController : UIViewController

@property (assign, nonatomic) NSInteger index;

- (instancetype)initWithIndex:(NSUInteger)index;

@end
