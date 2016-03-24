//
//  ProfileHeadView.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/21/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "ProfileHeadView.h"
#import "PHApiClient.h"
#import "UIColor+Helper.h"
#import "PHUtil.h"
#import "GVUserDefaults+PrepHero.h"

@implementation ProfileHeadView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        dispatch_queue_t _backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        float linePadding = 10.0f;
      
        [[PHApiClient sharedClient] getUserInfo:^(NSDictionary *json, BOOL success) {
            if (success) {
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:json];
                NSLog(@"%@", userInfo);
                
                [GVUserDefaults standardUserDefaults].gradyear = userInfo[@"gradyear"];
                [GVUserDefaults standardUserDefaults].phone = userInfo[@"phone"];
                [GVUserDefaults standardUserDefaults].firstname = userInfo[@"firstname"];
                [GVUserDefaults standardUserDefaults].lastname = userInfo[@"lastname"];
                [GVUserDefaults standardUserDefaults].profileImageURL = userInfo[@"profile_image_url"];
                [GVUserDefaults standardUserDefaults].gender = userInfo[@"gender"];
                
                
                dispatch_async(_backgroundQueue, ^{
                    
                    _profileImageView = [[PHProfileImageNode alloc] initWithProfileURL:userInfo[@"profile_image_url"]];
                    _profileImageView.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
                    [_profileImageView measure:CGSizeMake(SCREEN_WIDTH, FLT_MAX)];
                    _profileImageView.frame = (CGRect){CGPointZero, _profileImageView.calculatedSize};
                    
                    float centerX = _profileImageView.calculatedSize.width/2.0f;
                    _userName = [[ASTextNode alloc] init];
                    NSString *userNameString = [NSString stringWithFormat:@"%@ %@", userInfo[@"firstname"], userInfo[@"lastname"]];
                    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style.paragraphSpacing = 3.0f;
                    style.lineSpacing = 0.0f;
                    style.hyphenationFactor = 1.0;
                    style.alignment = NSTextAlignmentCenter;
                    
                    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
                    _userName.attributedString = [[NSAttributedString alloc] initWithString:userNameString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: font,
                                                                                              NSParagraphStyleAttributeName: style,
                                                                                              NSForegroundColorAttributeName: [UIColor prepHeroBlueColor]
                                                                                              }];
                    [_userName measure:CGSizeMake(SCREEN_WIDTH, FLT_MAX)];
                    //_userName.backgroundColor = [UIColor blackColor];
                    _userName.frame = CGRectMake(centerX - _userName.calculatedSize.width/2.0f, _profileImageView.frame.size.height + linePadding , _userName.calculatedSize.width, _userName.calculatedSize.height);
                    
                    
                    _gradYear = [[ASTextNode alloc] init];
                    //_gradYear.backgroundColor = [UIColor prepHeroYellowColor];
                    NSString *gradYearString = [NSString stringWithFormat:@"High School Grad Year: %@", userInfo[@"gradyear"]];
                    _gradYear.attributedString = [[NSAttributedString alloc] initWithString:gradYearString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: font,
                                                                                              NSParagraphStyleAttributeName: style,
                                                                                              NSForegroundColorAttributeName: [UIColor prepHeroBlueColor]
                                                                                              }];
                    [_gradYear measure:CGSizeMake(SCREEN_WIDTH, FLT_MAX)];
                    _gradYear.frame = CGRectMake(centerX - _gradYear.calculatedSize.width/2.0f, _userName.frame.size.height+_profileImageView.frame.size.height + 2 * linePadding, _gradYear.calculatedSize.width, _gradYear.calculatedSize.height);
                    
                    
                    // self.view isn't a node, so we can only use it on the main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addSubview:_userName.view];
                        [self addSubview:_gradYear.view];
                        [self addSubview:_profileImageView.view];
                        
                    });
                });
            }
        }];
    }
    return self;
}
@end
