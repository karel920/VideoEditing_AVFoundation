//
//  PHApiClient.m
//  PrepHero
//
//  Created by Xinjiang Shao on 7/9/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHApiClient.h"
#import "PHUtil.h"
#import "GVUserDefaults+PrepHero.h"

#import <AFAmazonS3Manager/AFAmazonS3Manager.h>
#import <AFAmazonS3Manager/AFAmazonS3ResponseSerializer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <SSKeychain.h>

@interface PHApiClient()

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *userAgent;
@end

@implementation PHApiClient

+ (PHApiClient *)sharedClient
{
    static PHApiClient *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PHApiClient alloc] initWithBaseURL:[NSURL URLWithString:kPHBaseURL]];
        //_sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if(!self)
        return nil;

    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Track App Version Usage with Custom UserAgent
    NSString *appVersion = [[PHUtil sharedInstance] getVersion];
    NSString *iosVersion = [UIDevice currentDevice].systemVersion;
    [self setUserAgent:[NSString stringWithFormat:@"%@ - Client Ver: %@ - iOS %@", kPHUserAgentPrefix, appVersion, iosVersion]];
    
    return self;
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
    [self.requestSerializer clearAuthorizationHeader];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}


- (void)isApiServerAvailable
{
    __block BOOL isServerLive = NO;
    [self GET:@"ping" parameters:nil success:^(NSURLSessionDataTask *task, id JSON) {
        NSString *serverResponse = [JSON valueForKeyPath:@"message"];
        if([serverResponse isEqualToString:@"pong"]){
            isServerLive = YES;
        }else{
            isServerLive = NO;
        }
        NSLog(@"API Server Status: %@", isServerLive ? @"YES": @"NO");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         NSLog(@"Error: %@", error);
    }];
    
}

- (void)isValidWithUsername:(NSString *)userName password:(NSString *)password completion:(void (^)(NSDictionary *json, BOOL success))completion
{
    [self setUsername:userName andPassword:password];
    NSLog(@"isValidWith %@: %@", userName, password);
    [self GET:@"users/login" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* responseObject) {
        //NSLog(@"Response: %@", responseObject);
        if (completion) {
            completion(responseObject, YES);
        }
        // POST a message 
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        // reponseCode is 401 means invalid username/password
        completion(nil, NO);
        
    }];
    
}

- (void)getUserInfo:(void (^)(NSDictionary *json, BOOL success))completion
{
    NSString *userName = [GVUserDefaults standardUserDefaults].email;
    NSString *password = [SSKeychain passwordForService:kPHKeychainServiceName account:[GVUserDefaults standardUserDefaults].email];
    
    NSString *path = [NSString stringWithFormat:@"users/%@", [GVUserDefaults standardUserDefaults].uid];
    NSLog(@"userName: %@ password: %@ path:%@", userName, password, path);
    [self setUsername:userName andPassword:password];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* responseObject) {
        //NSLog(@"Response: %@", responseObject);
        if (completion) {
            completion(responseObject, YES);
        }
        // POST a message
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        // reponseCode is 401 means invalid username/password
        completion(nil, NO);
        
    }];
}

- (void)updateUserInfo:(NSDictionary *)userInfo compeltion:(void (^)(NSDictionary *, BOOL))completion
{
    NSString *userName = [GVUserDefaults standardUserDefaults].email;
    NSString *password = [SSKeychain passwordForService:kPHKeychainServiceName account:[GVUserDefaults standardUserDefaults].email];
    
    NSString *path = [NSString stringWithFormat:@"users/%@", [GVUserDefaults standardUserDefaults].uid];
    
    [self setUsername:userName andPassword:password];
    
    
    [self PATCH:path parameters:userInfo success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* responseObject) {
        //NSLog(@"Response: %@", responseObject);
        if (completion) {
            completion(responseObject, YES);
        }
        // POST a message
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        // reponseCode is 401 means invalid username/password
        completion(nil, NO);
        
    }];
}
- (void)updateProfileImage:(UIImage *)profileImage completion:(void (^)(NSDictionary *json, BOOL success))completion
{
    NSString *userName = [GVUserDefaults standardUserDefaults].email;
    NSString *password = [SSKeychain passwordForService:kPHKeychainServiceName account:[GVUserDefaults standardUserDefaults].email];
    
    NSString *path = [NSString stringWithFormat:@"users/%@", [GVUserDefaults standardUserDefaults].uid];
    
    [self setUsername:userName andPassword:password];

    [self PUT:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* responseObject) {
        //NSLog(@"Response: %@", responseObject);
        if (completion) {
            completion(responseObject, YES);
        }
        // POST a message
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        // reponseCode is 401 means invalid username/password
        completion(nil, NO);
        
    }];
}


- (void) uploadVideoToS3At:(NSString *) destinationPath
                  withFile:(NSURL *) fileURL
{
    AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:kPHAWSAccessKey secret:kPHAWSSecret];
    s3Manager.requestSerializer.region = AFAmazonS3USStandardRegion;
    s3Manager.requestSerializer.bucket = @"prephero-videos";
    
    
    // Get the file using url loading mechanisms to get the mime type.
//    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:
//                                        [NSURL fileURLWithPath:fileName]];
//    fileRequest.cachePolicy = NSURLCacheStorageNotAllowed;
//    NSURLResponse *fileResponse = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:fileRequest
//                                         returningResponse:&fileResponse
//                                                     error:nil];
//    NSData *data = [NSData dataWithContentsOfURL:fileURL];
//    ALAssetRepresentation *rep = [asset defaultRepresentation];
//    Byte *buffer = (Byte*)malloc((NSUInteger)rep.size);
//    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
//    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:fileURL resultBlock:^(ALAsset *asset) // substitute YOURURL with your url of video
     {
         ALAssetRepresentation *rep = [asset defaultRepresentation];
         Byte *buffer = (Byte*)malloc(rep.size);
         NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
         NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
         
         unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
         CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
         NSData *md5data = [NSData dataWithBytes:md5Buffer length:sizeof(md5Buffer)];
         NSString *md5Base64 = [md5data base64EncodedStringWithOptions:0];
         
         // Build the un-authed request.
         NSURL *url = [s3Manager.baseURL URLByAppendingPathComponent:destinationPath];
         NSMutableURLRequest *originalRequest = [[NSMutableURLRequest alloc] initWithURL:url];
         originalRequest.HTTPMethod = @"PUT";
         originalRequest.HTTPBody = data;
         [originalRequest setValue:md5Base64 forHTTPHeaderField:@"Content-MD5"];
         [originalRequest setValue:@"audio/mpeg" forHTTPHeaderField:@"Content-Type"];
         
         // Sign it.
         NSURLRequest *request = [s3Manager.requestSerializer
                                  requestBySettingAuthorizationHeadersForRequest:originalRequest
                                  error:nil];
         // Upload it.
         AFHTTPRequestOperation *operation = [s3Manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Success!
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error uploading %@", error);
         }];
         [s3Manager.operationQueue addOperation:operation];
         
     }
     failureBlock:^(NSError *err) {
         NSLog(@"Error: %@",[err localizedDescription]);
      }];
    
    
//    [s3Manager postObjectWithFile:fileName
//                  destinationPath:destinationPath
//                       parameters:nil
//                         progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//                             NSLog(@"%f%% Uploaded", (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100));
//                         }
//                          success:^(AFAmazonS3ResponseObject *responseObject) {
//                              NSLog(@"Upload Complete: %@", responseObject.URL);
//                          }
//                          failure:^(NSError *error) {
//                              NSLog(@"Error: %@", error);
//                          }];
}


@end
