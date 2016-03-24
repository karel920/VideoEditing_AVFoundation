//
//  LogInViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/16/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "LogInViewController.h"
#import "UIColor+Helper.h"
#import "UIVIew+Helper.h"
#import "UIImage+Helper.h"
#import "PHApiClient.h"
#import "SignUpViewController.h"
#import "GVUserDefaults+PrepHero.h"
#import "PHTutorialViewController.h"
#import <SSKeychain.h>
#import <SafariServices/SafariServices.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor prepHeroBlueColor];
    
    _scrollView             = [UIScrollView autolayoutView];
    _contentView            = [UIView autolayoutView];
    
    [_scrollView addSubview:_contentView];
    [self.view addSubview:_scrollView];
    
    NSDictionary *tmpViewsDictionary = @{@"scrollView":self.scrollView,
                                         @"contentView":self.contentView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[scrollView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:tmpViewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self addContentSubViews];
    
    [self registerForKeyboardNotifications];
    
//    BOOL showTutorialOnLaunch = [GVUserDefaults standardUserDefaults].showTutorial;
//    if (showTutorialOnLaunch) {
//        PHTutorialViewController *joyRideVc = [PHTutorialViewController new];
//        
//        [self presentViewController:joyRideVc animated:YES completion:nil];
//        
//    }

}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailTextfield)
    {
        [self.emailTextfield resignFirstResponder];
        [self.passwordTextfield becomeFirstResponder];
    }
    else if (textField == self.passwordTextfield)
    {
        [self.passwordTextfield resignFirstResponder];
        
        [self loginUser:self];
    }
    return YES;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    self.activeField = nil;
}

- (void)addContentSubViews {

    _logoImageView = [UIImageView autolayoutView];
    _logoImageView.image = [UIImage imageNamed:@"loginscreen-logo"];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_contentView addSubview:_logoImageView];

    _brandName = [UILabel autolayoutView];
    [_brandName setFont:[UIFont fontWithName:@"Michroma" size:24.0f]];
    [_brandName setText:@"PREPHERO"];
    [_brandName setTextColor:[UIColor prepHeroYellowColor]];
    [_contentView addSubview:_brandName];
    
    _emailTextfield = [PHTextField autolayoutView];
    _emailTextfield.textColor = [UIColor prepHeroYellowColor];
    _emailTextfield.placeholder = NSLocalizedString(@"Email Address", @"Email Address");
    _emailTextfield.tintColor = [UIColor prepHeroYellowColor];
    _emailTextfield.backgroundColor = [UIColor whiteColor];
    _emailTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextfield.returnKeyType = UIReturnKeyNext;
    _emailTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailTextfield.delegate = self;
    [_contentView addSubview:_emailTextfield];
    
    _passwordTextfield = [PHTextField autolayoutView];
    _passwordTextfield.textColor = [UIColor prepHeroYellowColor];
    _passwordTextfield.placeholder = NSLocalizedString(@"Password", @"Password");
    _passwordTextfield.tintColor = [UIColor prepHeroYellowColor];
    _passwordTextfield.backgroundColor = [UIColor whiteColor];
    _passwordTextfield.secureTextEntry = YES;
    _passwordTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextfield.returnKeyType = UIReturnKeyDone;
    _passwordTextfield.delegate = self;
    [_contentView addSubview:_passwordTextfield];
    
    _logInButton = [PHPrimaryButton autolayoutView];
    UIImage *logInBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor]
                                                     cornerRadius:0.0f
                                                      shadowColor:[UIColor blackColor]
                                                     shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    UIImage *logInActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor blackColor]
                                                           cornerRadius:0.0f
                                                            shadowColor:[UIColor blackColor]
                                                           shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_logInButton setBackgroundImage:logInBackgroundImage
                            forState:UIControlStateNormal];
    [_logInButton setBackgroundImage:logInActiveBackgroundImage
                            forState:UIControlStateHighlighted];
    [_logInButton setTitleColor:[UIColor colorFromHexCode:@"313131"] forState:UIControlStateNormal];
    [_logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_logInButton setTitle:NSLocalizedString(@"Login Now", @"Login Now")
                  forState:UIControlStateNormal];
    _logInButton.titleLabel.font = [UIFont fontWithName:@"PROMESH-Two" size:20.0f];
    [_logInButton addTarget:self action:@selector(loginUser:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_logInButton];
    
    _twitterLogInButton = [PHPrimaryButton autolayoutView];
    UIImage *twitterLoginMethodBackgroundImage = [UIImage buttonImageWithColor:[UIColor twitterButtonBackgroundColor]
                                                                cornerRadius:5.0f
                                                                 shadowColor:[UIColor twitterButtonBackgroundColor]
                                                                shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_twitterLogInButton setBackgroundImage:twitterLoginMethodBackgroundImage
                                       forState:UIControlStateNormal];
    [_twitterLogInButton setTitle:NSLocalizedString(@"Login via Twitter", @"Login via Twitter")
                            forState:UIControlStateNormal];
    [_twitterLogInButton addTarget:self
                            action:@selector(loginTwitterUser:)
                  forControlEvents:UIControlEventTouchUpInside];
    _twitterLogInButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_contentView addSubview:_twitterLogInButton];
    
    
    _facebookLogInButton = [PHPrimaryButton autolayoutView];
    UIImage *facebookLoginMethodBackgroundImage = [UIImage buttonImageWithColor:[UIColor facebookButtonBackgroundColor]
                                                                  cornerRadius:5.0f
                                                                   shadowColor:[UIColor facebookButtonBackgroundColor]
                                                                  shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_facebookLogInButton setBackgroundImage:facebookLoginMethodBackgroundImage
                                   forState:UIControlStateNormal];
    [_facebookLogInButton setTitle:NSLocalizedString(@"Login via Facebook", @"Login via Facebook")
                         forState:UIControlStateNormal];
    [_facebookLogInButton addTarget:self
                             action:@selector(loginFacebookUser:)
                   forControlEvents:UIControlEventTouchUpInside];
    _facebookLogInButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_contentView addSubview:_facebookLogInButton];

    _signUpButton = [PHPrimaryButton autolayoutView];
    UIImage *signUpBackgroundImage = [UIImage buttonImageWithColor:[UIColor darkGrayColor]
                                                      cornerRadius:10.0f
                                                       shadowColor:[UIColor blackColor]
                                                      shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_signUpButton setBackgroundImage:signUpBackgroundImage
                             forState:UIControlStateNormal];
    _signUpButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    
    [_signUpButton setTitle:NSLocalizedString(@"Sign Up", @"Sign Up")
                   forState:UIControlStateNormal];
    [_signUpButton addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_signUpButton];
    
    [self addContentSubViewConstraints];

}
                                                                                               
- (IBAction)signUp:(id)sender {
    NSURL *signUpLink = [NSURL URLWithString:@"https://prephero.com/account/register?utm_source=ios_app&utm_medium=app&utm_content=regsiter"];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        SFSafariViewController *signUpViewController = [[SFSafariViewController alloc] initWithURL:signUpLink];
    
        [self presentViewController:signUpViewController animated:YES completion:nil];
    }else{
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] initWithURL:signUpLink];
        [self presentViewController:signUpViewController animated:YES completion:nil];
        //[[UIApplication sharedApplication] openURL:signUpLink];
    }
    
}
- (void)addContentSubViewConstraints {
    NSDictionary *subviews = NSDictionaryOfVariableBindings(_logoImageView,
                                                            _brandName,
                                                            _emailTextfield,
                                                            _passwordTextfield,
                                                            _logInButton,
                                                            _signUpButton,
                                                            _twitterLogInButton,
                                                            _facebookLogInButton
                                                            );

    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_logoImageView(==100)]-(>=20)-|"
                                                                         options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
                                                                         metrics:nil
                                                                           views:subviews]];
    // center logo
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_contentView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_brandName]-(>=20)-|"
                                                                         options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
                                                                         metrics:nil
                                                                           views:subviews]];
    // center brandName
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_brandName
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_contentView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_emailTextfield(>=190)]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_passwordTextfield(>=190)]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_logInButton(>=190)]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[_facebookLogInButton]-10-[_twitterLogInButton(==_facebookLogInButton)]-(20)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[_signUpButton]-(20)-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:subviews]];
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=30)-[_logoImageView(==100)]-(0)-[_brandName]-(20)-[_emailTextfield(>=56)]-(5)-[_passwordTextfield(>=56)]-(5)-[_logInButton(>=56)]-(5)-[_facebookLogInButton(>=56)]-(>=50)-[_signUpButton(>=50)]-(10)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews]];
    
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_twitterLogInButton
                                                             attribute:NSLayoutAttributeBaseline
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_facebookLogInButton
                                                             attribute:NSLayoutAttributeBaseline
                                                            multiplier:1.0
                                                              constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_twitterLogInButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_facebookLogInButton
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:0]];

    
}
- (IBAction)loginTwitterUser:(id)sender {
    
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            [SVProgressHUD show];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                NSLog(@"signed in as %@", [session userName]);
                // Comparing With Data Stored in PrepHero.com
                NSString *twitterAccount = [NSString stringWithFormat:@"tw_%@", [session userID]];
                NSString *twitterToken = [NSString stringWithFormat:@"%@-%@", [session authToken], [session authTokenSecret]];
                [[PHApiClient sharedClient] isValidWithUsername:twitterAccount password:twitterToken completion:^(NSDictionary *json, BOOL success) {
                    if(success){
                        NSLog(@"login With Twitter account");
                        // Configure User Default Options
                        [GVUserDefaults standardUserDefaults].email = twitterAccount;
                        //[GVUserDefaults standardUserDefaults].uname = [json valueForKey:@"uname"];
                        [GVUserDefaults standardUserDefaults].uid   = [json valueForKey:@"uid"];
                        [GVUserDefaults standardUserDefaults].showTutorial = YES;
                        
                        [GVUserDefaults standardUserDefaults].loggedIn = YES;
                        
                        [SSKeychain setPassword:twitterToken
                                     forService:kPHKeychainServiceName
                                        account:twitterAccount];
                        
                        //Store Credentials in KeyChain
                        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
                        
                        query.password = twitterToken;
                        query.service = kPHKeychainServiceName;
                        query.account = twitterAccount;
                        
                        NSError *error;
                        [query fetch:&error];
                        
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInFailureNotification
                                                                                    object:nil];
                            });
                        }else{

                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInSuccessfulNotification
                                                                                    object:nil];
                                [SVProgressHUD dismiss];
                            });
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showErrorWithStatus:@"Twitter Account not linked with PrepHero"];
                        });
                    }
                }];
                
                
            });
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"Twitter Auth Error"];
                });
            });
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    
     
}
- (IBAction)loginFacebookUser:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         
         if (error) {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 // time-consuming task
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD showErrorWithStatus:@"Auth Error"];
                 });
             });
             NSLog(@"Facebook Process error");
         } else if (result.isCancelled) {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 // time-consuming task
                 dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"User Cancelled Authentication"];
                 });
             });
             NSLog(@"Facebook Cancelled");
         } else {
             [SVProgressHUD showSuccessWithStatus:@"Logging In ..."];
             FBSDKAccessToken *token = result.token;
//             NSLog(@"userID: %@", token.userID);
//             NSLog(@"TokenString: %@", token.tokenString);
             NSString *fbAccount = [NSString stringWithFormat:@"fb_%@",token.userID];
             NSString *fbToken = [NSString stringWithFormat:@"%@", token.tokenString];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 // time-consuming task
                 //Loggin with facebook username and token;
                 NSLog(@"fb: %@ ", fbAccount);
                 [[PHApiClient sharedClient] isValidWithUsername:fbAccount password:fbToken completion:^(NSDictionary *json, BOOL success) {
                     if(success){
                         NSLog(@"login With Facebook account");
                         // Configure User Default Options
                         [GVUserDefaults standardUserDefaults].email = fbAccount;
                         //[GVUserDefaults standardUserDefaults].uname = [json valueForKey:@"uname"];
                         [GVUserDefaults standardUserDefaults].uid   = [json valueForKey:@"uid"];
                         [GVUserDefaults standardUserDefaults].showTutorial = YES;
                         
                         [GVUserDefaults standardUserDefaults].loggedIn = YES;
                         
                         [SSKeychain setPassword:fbToken
                                      forService:kPHKeychainServiceName
                                         account:fbAccount];
                         
                         //Store Credentials in KeyChain
                         SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
                         
                         query.password = fbToken;
                         query.service = kPHKeychainServiceName;
                         query.account = fbAccount;
                         
                         NSError *error;
                         [query fetch:&error];
                         
                         if (error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInFailureNotification
                                                                                     object:nil];
                             });
                         }else{
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInSuccessfulNotification
                                                                                     object:nil];
                                 [SVProgressHUD dismiss];
                             });
                         }
                     }else{
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInFailureNotification
                                                                                 object:nil];
                         });
                         
                         [SVProgressHUD showErrorWithStatus:@"Facebook Account not linked with PrepHero"];
                     }
                 }];
 
             });
             
         }
     }];
    
}
- (IBAction)loginUser:(id)sender {
    
    if (self.emailTextfield.text.length < 1 || self.passwordTextfield.text.length < 1) {
        
        return;
    }

    [SVProgressHUD show];
    
    __block NSString* tmpPasswordStored = self.passwordTextfield.text;
    [[PHApiClient sharedClient] isValidWithUsername:self.emailTextfield.text password:self.passwordTextfield.text completion:^(NSDictionary *json, BOOL success) {
        if(success){
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                // Configure User Default Options
                [GVUserDefaults standardUserDefaults].email = [json valueForKey:@"email"];
                [GVUserDefaults standardUserDefaults].uname = [json valueForKey:@"uname"];
                [GVUserDefaults standardUserDefaults].uid   = [json valueForKey:@"uid"];
                [GVUserDefaults standardUserDefaults].showTutorial = YES;
                
                [GVUserDefaults standardUserDefaults].loggedIn = YES;
                
                [SSKeychain setPassword:tmpPasswordStored
                             forService:kPHKeychainServiceName
                                account:[json valueForKey:@"email"]];
                
                //Store Credentials in KeyChain
                SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
              
                query.password = tmpPasswordStored;
                query.service = kPHKeychainServiceName;
                query.account = [json valueForKey:@"email"];
                
                NSError *error;
                [query fetch:&error];
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInFailureNotification
                                                                        object:nil];
                    });
                }else{
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedInSuccessfulNotification
                                                                            object:nil];
                        [SVProgressHUD dismiss];
                    });
                }
            });
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"Auth Error"];
                });
            });
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark - StatusBar Style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
