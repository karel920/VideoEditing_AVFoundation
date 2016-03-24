//
//  PHTutorialViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/19/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHTutorialViewController.h"
#import "PHPageViewController.h"
#import "UIColor+Helper.h"

@interface PHTutorialViewController ()

@end

@implementation PHTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                      navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                    options:nil];
    _pageController.dataSource = self;
    _pageController.view.frame = [[self view] bounds];
    
    PHPageViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:YES
                             completion:nil];
    self.view.backgroundColor = [UIColor prepHeroBlueColor];
    [self addChildViewController:_pageController];
    
    [self.view addSubview:_pageController.view];
    [_pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHPageViewController *)viewControllerAtIndex:(NSUInteger)index {
    PHPageViewController *childViewController = [[PHPageViewController alloc] initWithIndex:index];
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PHPageViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PHPageViewController *)viewController index];
    
    index++;
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
