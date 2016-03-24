//
//  PHSideMenuViewController.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/19/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHSideMenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (nonatomic, strong) UITableViewController *menuTableViewController;
@property (nonatomic, strong) UINavigationController *menuNavigationViewController;
- (void)cancelButtonTapped:(UIBarButtonItem *)sender;

@end
