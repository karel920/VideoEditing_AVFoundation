//
//  PHVideoSegmentsViewController.h
//  PrepHero
//
//  Created by Xinjiang Shao on 12/15/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHMainTabBarController.h"
#import <DZNSegmentedControl.h>


@interface PHVideoSegmentsViewController : UIViewController

@property (nonatomic, strong) PHMainTabBarController *mainTabBar;
@property (nonatomic, strong) DZNSegmentedControl *control;


- (void) getVideoList;
- (void) setSegmentAtIndex:(NSInteger) index;

@end
