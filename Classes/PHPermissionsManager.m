//
//  PHPermissionsManager.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/18/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PHLocationManager.h"

@interface PHPermissionsManager () <UIAlertViewDelegate>


@end

@implementation PHPermissionsManager

- (void)checkMicrophonePermissionsWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if(!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (IS_IOS7_OR_LESS) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Disabled"
                                                                    message:@"To enable sound recording with your video please go to the Settings > PrepHero > Microphone and enable access."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:@"Settings", nil];
                    alert.delegate = self;
                    [alert show];
                }else{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Microphone Disabled"
                                                                                   message:@"To enable sound recording with your video please go to the Settings > PrepHero > Microphone and enable access."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                          }];
                    
                    [alert addAction:defaultAction];
                    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
                }
            });
        }
        if(block != nil)
            block(granted);
    }];
}


- (void)checkCameraAuthorizationStatusWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (!granted){
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                if (IS_IOS7_OR_LESS) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Disabled"
                                                                    message:@"This app doesn't have permission to use the camera, please go to the Settings > PrepHero > Camera and enable access."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:@"Settings", nil];
                    alert.delegate = self;
                    [alert show];
                }else{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Camera  Disabled"
                                                                                   message:@"This app doesn't have permission to use the camera, please go to the Settings > PrepHero > Camera and enable access."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                          }];
                    
                    [alert addAction:defaultAction];
                    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
                }
            });
    
        }
        if(block)
            block(granted);
    }];
}

- (void)checkLocationAuthorizationWithBlock:(void(^)(BOOL granted))block
{
    BOOL grantedStatus = NO;
    if(![[PHLocationManager sharedLocationManager] isAuthorized]){
        NSLog(@"Location Services Enabled");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (IS_IOS7_OR_LESS) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                                message:@"This app doesn't have permission to use the camera, please go to the Settings > PrepHero > Location and enable access."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Settings", nil];
                
                alert.delegate = self;
                [alert show];
            }else{
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Location Service  Disabled"
                                                                               message:@"This app doesn't have permission to use the camera, please go to the Settings > PrepHero > Location and enable access."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                      }];
                
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction * action) {
                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                
                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
       
    }else{
         grantedStatus = YES;
    }
    if(block)
        block(grantedStatus);
}

#pragma mark - UIAlertViewDelegate methods

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSLog(@"Tapped Settings");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    return YES;
}
@end
