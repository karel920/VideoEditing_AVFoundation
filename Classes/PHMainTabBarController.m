//
//  PHMainTabBarController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/29/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHMainTabBarController.h"
#import "PHCaptureViewController.h"
#import "UIColor+Helper.h"

#import "Video.h"
#import <RKDropdownAlert.h>


typedef NS_ENUM(NSInteger, PHTabItem) {
    PHVideoTab = 0,
    PHCaptureTab,
    PHMoreTab,
    PHTabTotal
    
};
@interface PHMainTabBarController ()

@end

@implementation PHMainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set tag for tab bar
    [self.tabBar.items[PHVideoTab] setTag:PHVideoTab];
    [self.tabBar.items[PHCaptureTab] setTag:PHCaptureTab];
    [self.tabBar.items[PHMoreTab] setTag:PHMoreTab];
    
    // set default item to be capture
    self.selectedIndex = PHCaptureTab;
    
    self.tabBar.tintColor       = [UIColor prepHeroYellowColor];
    self.tabBar.backgroundColor = [UIColor grayColor];
    
    
    // register new video notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNewVideoClip:)
                                                 name:PHVideoCreatedNotification
                                               object:nil];
    
}
// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"capture-button"] highlightImage:nil];
}

- (void)processNewVideoClip:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Dispatch in main thread always, otherwise xcode throw error
        [RKDropdownAlert title:@"Video Caputured" message:@"Congrats!"];
        [self.tabBar.items[PHVideoTab] setBadgeValue:@"new"];
    });
    
    if ([notification.object isKindOfClass:[Video class]])
    {
        
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    if (self.selectedViewController.class == [PHCaptureViewController class]) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
