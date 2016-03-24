//
//  PHVideoMerge.h
//  PrepHero
//
//  Created by Dong on 11/21/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHVideoMerge : NSObject

+ (void)mergeVideos:(NSArray *)videoFileNames toVideoFile:(NSURL *)outputURL maxSeconds:(CGFloat)maxSeconds completion:(void (^)(BOOL success))completion;
+ (void)mergeClipedVideos:(NSArray *)videoAssetFileNames completion:(void (^)(BOOL success))completion;
@end
