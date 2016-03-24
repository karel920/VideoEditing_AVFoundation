//
//  SignUpViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/18/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "SignUpViewController.h"
#import "UIVIew+Helper.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [UIView autolayoutView];
    [self.view addSubview:_contentView];
    
    NSDictionary *tmpViewsDictionary = @{
                                         @"contentView":_contentView
                                         };
  
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    _signUpWebView            = [UIWebView autolayoutView];
    [self.contentView addSubview:_signUpWebView];

    _backButton = [PHPrimaryButton autolayoutView];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    [_backButton addTarget:self action:@selector(closeController:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_backButton];
    
    NSDictionary *subviews = NSDictionaryOfVariableBindings(_backButton,
                                                            _signUpWebView);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[_backButton]-(0)-[_signUpWebView]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
  
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_backButton]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:subviews]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_signUpWebView]-(0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:subviews]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_signUpURL];
    [self.signUpWebView loadRequest:request];
}


- (void)closeController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype) initWithURL: (NSURL *) signUpURL {
    self = [super init];
    if (self) {
        self.signUpURL = signUpURL;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
