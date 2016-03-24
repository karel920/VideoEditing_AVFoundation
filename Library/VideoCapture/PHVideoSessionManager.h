//
//  PHVideoSessionManager.h
//  PrepHero
//
//  Created by Dong on 11/12/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface PHVideoSessionManager : NSObject

+ (BOOL)setPreset:(VideoResolution)resolution forSession:(AVCaptureSession*)session;
+ (NSString *)videoProfileForWidth:(NSInteger*)width height:(NSInteger*)height forResolution:(VideoResolution*)resolution;

@end
