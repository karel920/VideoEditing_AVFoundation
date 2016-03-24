//
//  PHSettingsViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/29/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHSettingsViewController.h"
#import "UIColor+Helper.h"
#import "PHApiClient.h"
#import "Video.h"
#import "PHUtil.h"
#import "PHTutorialViewController.h"
#import "GVUserDefaults+PrepHero.h"
#import <SSKeychain.h>
#import <STKWebKitViewController/STKWebKitModalViewController.h>
#import <AVFoundation/AVFoundation.h>
#import <TwitterKit/TwitterKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

typedef NS_ENUM(NSInteger, PHSettingsSection) {
    PHAccountSection = 0,
    PHServerSection,
    PHSupportSection,
    PHSocialMediaSection,
    PHLogOutSection,
    PHSectionTotal
};

@interface PHSettingsViewController ()

@end

@implementation PHSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Settings", nil);
    
    NSString *cellIdentifier = @"kPHSettingCellIdentifier";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
   

    _profileHeadView = [[ProfileHeadView alloc] init];
    
    float newHeight = 210.0f;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect oldFrame = _profileHeadView.frame;
        _profileHeadView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, newHeight);
        
        [self.tableView setTableHeaderView:_profileHeadView];
    }];

    
    _settingOptions = [[NSMutableArray alloc] initWithCapacity:PHSectionTotal];
    
    [_settingOptions insertObject:[NSMutableArray arrayWithObjects:@"Link Twitter", @"Link Facebook", nil] atIndex:PHAccountSection];
    [_settingOptions insertObject:[NSMutableArray arrayWithObjects:@"Sync With PrepHero", nil] atIndex:PHServerSection];
    [_settingOptions insertObject:[NSMutableArray arrayWithObjects:@"Support & Feedback", @"PrepHero Website", @"Version", @"App Tutorial", nil] atIndex:PHSupportSection];
    [_settingOptions insertObject:[NSMutableArray arrayWithObjects:@"Like Us on Facebook", @"Follow Us On Twitter", nil] atIndex:PHSocialMediaSection];
    [_settingOptions insertObject:[NSMutableArray arrayWithObjects:@"Log Out", nil] atIndex:PHLogOutSection];
    
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}



- (void)signOutUser:(UIButton *)sender
{
   
    [GVUserDefaults standardUserDefaults].loggedIn = NO;
    
    [SSKeychain deletePasswordForService:kPHKeychainServiceName account:[GVUserDefaults standardUserDefaults].email];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PHUserLoggedOutNotification
                                                        object:nil];
}

- (void)syncVideos
{
    NSManagedObjectContext *managedObjectContext = [[PHUtil sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSMutableArray *videos = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
   // NSLog(@"UserInfo: %@", [PFUser currentUser]);
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *uid = currentUser[@"uid"];
   
    
    for (Video *video in videos) {
        //NSLog(@"video: %@, uid: %@, uname: %@", video.videoPath, uid, uname);
        NSURL *url = [NSURL URLWithString:[video valueForKey:@"videoPath"]];
        AVAsset *asset = [AVAsset assetWithURL:url];
        if (![asset isReadable]) {
            continue;
        }
        NSArray *parts = [[url query] componentsSeparatedByString:@"&"];
        NSString *videoName = [parts[0] componentsSeparatedByString:@"="][1];
        NSString *destinationPath = [NSMutableString stringWithFormat:@"/%@/%@.mov", uid, videoName];
        NSLog(@"destinationPath: %@", destinationPath);
        [[PHApiClient sharedClient] uploadVideoToS3At:destinationPath withFile:url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _settingOptions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_settingOptions objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kPHSettingCellIdentifier" forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    cell.textLabel.text = NSLocalizedString([[_settingOptions objectAtIndex:section] objectAtIndex:row], nil);
    
    
    if (section != PHServerSection && section != PHLogOutSection ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    //self.navigationController.hidesBarsOnSwipe = NO;
    
    switch (section) {
        case PHAccountSection:
        {
            switch (row) {
                case 0:
                {
                    
                    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
                        if (session) {
                            NSLog(@"signed in as %@", [session userName]);
                            // Store Token in PrepHero
                            
                            NSString *twitterAccount = [NSString stringWithFormat:@"tw_%@", [session userID]];
                            NSString *twitterToken = [NSString stringWithFormat:@"%@-%@", [session authToken], [session authTokenSecret]];
                            NSMutableDictionary *twitterAuthToken = [NSMutableDictionary new];
                            [twitterAuthToken setValue:twitterAccount forKey:@"twitter"];
                            [twitterAuthToken setValue:twitterToken forKey:@"twitter_token"];
                            //NSLog(@"params: %@", twitterAuthToken);
                            [SVProgressHUD showSuccessWithStatus:@"Linking ..."];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[PHApiClient sharedClient] updateUserInfo:twitterAuthToken compeltion:^(NSDictionary *json, BOOL success) {
                                    if (success) {
                                        NSLog(@"%@", json);
                                        
                                       
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [SVProgressHUD dismiss];
                                            });
                                       
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [SVProgressHUD showErrorWithStatus:@"Failed to Link With PrepHero"];
                                        });
                                         NSLog(@"Failed to update twitter credentials with PrepHero");
                                    }
                                    
                                }];
                            });
                            
                        } else {
                            NSLog(@"error: %@", [error localizedDescription]);
                        }
                    }];
                    break;
                }
                case 1:
                {
                    // Facebook Linking
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
                             NSLog(@"Facebook Process error : %@", error);
                         } else if (result.isCancelled) {
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 // time-consuming task
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SVProgressHUD showErrorWithStatus:@"User Cancelled Authentication"];
                                 });
                             });
                             NSLog(@"Facebook Cancelled");
                         } else {
                             [SVProgressHUD showSuccessWithStatus:@"Linking ..."];
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 // time-consuming task
                                 FBSDKAccessToken *token = result.token;
                                 NSLog(@"userID: %@", token.userID);
                                 NSLog(@"TokenString: %@", token.tokenString);
                                 NSString *fbAccount = [NSString stringWithFormat:@"fb_%@",token.userID];
                                 NSString *fbToken = [NSString stringWithFormat:@"%@", token.tokenString];
                                 //Setup facebook username and token;
                                 NSMutableDictionary *facebookAuthToken = [NSMutableDictionary new];
                                 [facebookAuthToken setValue:fbAccount forKey:@"facebook"];
                                 [facebookAuthToken setValue:fbToken forKey:@"facebook_token"];
                                 [[PHApiClient sharedClient] updateUserInfo:facebookAuthToken compeltion:^(NSDictionary *json, BOOL success) {
                                     if (success) {
                                         NSLog(@"%@", json);
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [SVProgressHUD dismiss];
                                         });
                                     }else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [SVProgressHUD showErrorWithStatus:@"Failed to Link With PrepHero"];
                                         });
                                         NSLog(@"Failed to update facebook credentials with PrepHero");
                                     }
                                     
                                 }];

                             });
                             
                         }
                     }];

                   
                    break;
                }
                default:
                    break;
            }
            
            
            // FaceBook, Twitter Accounts
            break;
        }
        case PHServerSection:
        {
            
            // Sync with AWS S3
            [SVProgressHUD show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // upload now
                [self syncVideos];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            });
            break;
        }
        case PHSupportSection:
        {
            //self.navigationController.hidesBarsOnSwipe = YES;
            
            switch (row) {
                case 0:
                {
                    NSURL *supportUrl = [NSURL URLWithString:@"https://prephero.com/support"];
                    STKWebKitModalViewController *controller = [[STKWebKitModalViewController alloc] initWithURL:supportUrl];
                    [self presentViewController:controller animated:YES completion:nil];
                    break;
                }
                case 1:
                {
                    NSURL *homeUrl = [NSURL URLWithString:@"https://prephero.com"];
                    STKWebKitModalViewController *controller = [[STKWebKitModalViewController alloc] initWithURL:homeUrl];
                    [self presentViewController:controller animated:YES completion:nil];
                    break;
                }
                case 2:
                {
                    NSString *appVersion = [[PHUtil sharedInstance] getVersion];
                    UIAlertController * alert =   [UIAlertController
                                                   alertControllerWithTitle:@"Current App Version"
                                                   message:appVersion
                                                   preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                    [alert addAction:ok];
                    break;
  
                }
                case 3:
                {
                    PHTutorialViewController *tutor = [PHTutorialViewController new];
                    [self presentViewController:tutor animated:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case PHSocialMediaSection:
        {
            switch (row) {
                case 0:
                {
                    BOOL fbInstalled = [self schemeAvailable:@"fb://"];
                    
                    NSURL *facebookUrl = [NSURL URLWithString:@"fb://profile/157387361019459"];
                    
                    if (!fbInstalled ) {
                        facebookUrl = [NSURL URLWithString:@"https://facebook.com/PrepHero"];
                    }
                    [[UIApplication sharedApplication] openURL:facebookUrl];
                    
                    break;
                }
                case 1:
                {
                    BOOL twInstalled = [self schemeAvailable:@"twitter://"];
                    NSURL *twitterUrl = [NSURL URLWithString:@"twitter://user?screen_name=prephero"];
                   
                    if (!twInstalled) {
                        twitterUrl = [NSURL URLWithString:@"https://twitter.com/prephero"];
                    }
                    [[UIApplication sharedApplication] openURL:twitterUrl];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case PHLogOutSection:
            [self performSelector:@selector(signOutUser:) withObject:nil afterDelay:0];
            break;
        default:
            break;
    }
    
}

- (BOOL)schemeAvailable:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    return [application canOpenURL:URL];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
