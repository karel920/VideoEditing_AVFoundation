//
//  PHClipVideoInfo.h
//  PrepHero
//
//  Created by admin on 1/25/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHClipVideoInfo : NSObject

+ (PHClipVideoInfo *) sharedInstance;

- (NSArray *) loadVideoList:(NSString *) fileName;
- (void) addVideoInfo:(NSMutableDictionary *) videoInfo fileName:(NSString *) fileName;
- (void) removeVideo:(NSDictionary *) delVideoInfo fileName:(NSString *) fileName;
- (void) saveVideoInfo:(NSArray *) videoList fileName:(NSString *) fileName;
- (void) updateVideoInfo:(NSDictionary*)videoInfo toVideoInfo:(NSMutableDictionary *) toVideoInfo fileName: (NSString *) fileName;

@end
