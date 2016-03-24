//
//  PHForcedOrientationNavController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/22/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "PHForcedOrientationNavController.h"
#import "UINavigationController+StatusBarStyle.h"

@interface PHForcedOrientationNavController ()

@end

@implementation PHForcedOrientationNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate;
{
    BOOL shouldAutorotate;
    if ([self.topViewController respondsToSelector:@selector(shouldAutorotate)])
    {
        shouldAutorotate = [self.topViewController shouldAutorotate];
    }
    else {
        shouldAutorotate = [super shouldAutorotate];
    }
    return shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask supportedOrientations;
    if ([[self topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        supportedOrientations = [[self topViewController] supportedInterfaceOrientations];
    }
    else {
        supportedOrientations = [super supportedInterfaceOrientations];
    }
    return supportedOrientations;
}


@end
