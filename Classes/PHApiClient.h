//
//  PHApiClient.h
//  PrepHero
//
//  Created by Xinjiang Shao on 7/9/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AVFoundation/AVFoundation.h>


#define kPHAPIClientUploadNotification @"kPHAPIClientUploadNotification"
#define kPHAPIClientDefaultRetryCount 5
#define kPHAPIVerison 1.0
#define kPHUserAgentPrefix @"PrepHero iOS Agent"
#define kPHBaseURL @"https://api.prephero.com/"
//#define kPHBaseURL @"http://localhost:3000/"
#define kPHAWSAccessKey @"AKIAILKZBYAF3Q53LJQA"
#define kPHAWSSecret @"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"

@interface PHApiClient : AFHTTPSessionManager

+ (PHApiClient *) sharedClient;
- (void)isApiServerAvailable;
- (void)isValidWithUsername:(NSString *)userName password:(NSString *)password completion:(void (^)(NSDictionary *json, BOOL success))completion;
- (void)getUserInfo:(void (^)(NSDictionary *json, BOOL success))completion;
- (void)updateUserInfo:(NSDictionary *)userInfo compeltion:(void (^)(NSDictionary *json, BOOL success))completion;
- (void)updateProfileImage:(UIImage *)profileImage completion:(void (^)(NSDictionary *json, BOOL success))completion;

- (void) uploadVideoToS3At:(NSString *) destinationPath
                  withFile:(NSURL *) fileUrl;
@end
