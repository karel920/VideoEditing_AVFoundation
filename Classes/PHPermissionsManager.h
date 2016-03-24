//
//  PHPermissionsManager.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/18/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHPermissionsManager : NSObject

- (void)checkMicrophonePermissionsWithBlock:(void(^)(BOOL granted))block;
- (void)checkCameraAuthorizationStatusWithBlock:(void(^)(BOOL granted))block;
- (void)checkLocationAuthorizationWithBlock:(void(^)(BOOL granted))block;
@end
