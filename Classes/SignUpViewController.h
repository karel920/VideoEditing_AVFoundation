//
//  SignUpViewController.h
//  PrepHero
//
//  Created by Xinjiang Shao on 9/18/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHPrimaryButton.h"

@interface SignUpViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIWebView *signUpWebView;
@property (nonatomic, strong) PHPrimaryButton *backButton;
@property (nonatomic, strong) NSURL *signUpURL;
- (instancetype) initWithURL: (NSURL *) signUpURL;

@end
