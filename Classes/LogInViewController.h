//
//  LogInViewController.h
//  PrepHero
//
//  Created by Xinjiang Shao on 9/16/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHPrimaryButton.h"
#import "PHTextField.h"


@interface LogInViewController : UIViewController <UITextFieldDelegate>


@property (strong, nonatomic) PHTextField *emailTextfield;
@property (strong, nonatomic) PHTextField *passwordTextfield;
@property (strong, nonatomic) PHPrimaryButton *logInButton;
@property (strong, nonatomic) PHPrimaryButton *twitterLogInButton;
@property (strong, nonatomic) PHPrimaryButton *facebookLogInButton;

@property (strong, nonatomic) PHPrimaryButton *signUpButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *brandName;

@property (weak, nonatomic)   UITextField *activeField;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;

@end
