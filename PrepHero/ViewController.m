//
//  ViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/12/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PHLogInViewController.h"
#import "PHSignUpViewController.h"
#import "PHCaptureViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PHLogInViewController *logInViewController = [[PHLogInViewController alloc] init];
        [logInViewController setDelegate:logInViewController]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PHSignUpViewController *signUpViewController = [[PHSignUpViewController alloc] init];
        //[signUpViewController setDelegate:self]; // Set ourselves as the delegate
        [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];
    }else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
       
        PHCaptureViewController *captureViewController = (PHCaptureViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:capViewControllerIdentifier];
        [captureViewController setupCaptureConfig];
        self.navigationController.navigationBarHidden = YES;
        //self.navigationController.hidesBarsOnTap = YES;
        [self.navigationController pushViewController:captureViewController animated:YES];
        //[self presentViewController:captureViewController animated:YES completion:nil];
        //[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User Information", nil) message:NSLocalizedString(@"You're In!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        //[PFUser logOut];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
