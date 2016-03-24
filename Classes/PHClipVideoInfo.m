//
//  PHClipVideoInfo.m
//  PrepHero
//
//  Created by admin on 1/25/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHClipVideoInfo.h"

@implementation PHClipVideoInfo

+ (PHClipVideoInfo *)sharedInstance {
    
    static dispatch_once_t onceToken;
    static PHClipVideoInfo *_sharedClient = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[[self class] alloc] init];
    });
    
    return _sharedClient;
}

- (NSArray *)loadVideoList:(NSString *) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSArray* data = [NSArray arrayWithContentsOfFile:path];
    return data;
}

- (void) removeVideo:(NSDictionary *)delVideoInfo fileName:(NSString *) fileName {
    NSLog(@"del Video Info: %@", delVideoInfo);
    NSMutableArray *removeVideo = [[NSMutableArray alloc] initWithArray:[self loadVideoList:fileName]];
    [removeVideo removeObject:delVideoInfo];
    [self saveVideoInfo:removeVideo fileName:fileName];
}

- (void) saveVideoInfo:(NSArray *)videoList fileName:(NSString *) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedPath;
    savedPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    [videoList writeToFile:savedPath atomically:NO];
}

- (void) addVideoInfo:(NSMutableDictionary *)videoInfo fileName:(NSString *)fileName {
    NSMutableArray* clipedVideo = [[NSMutableArray alloc] initWithArray:[self loadVideoList:fileName]];
    if (clipedVideo == nil) {
        clipedVideo = [[NSMutableArray alloc] init];
    }
    [clipedVideo addObject:videoInfo];
    [self saveVideoInfo:clipedVideo fileName:fileName];
}

- (void) updateVideoInfo:(NSDictionary*)videoInfo toVideoInfo:(NSMutableDictionary *) toVideoInfo fileName: (NSString *) fileName{
    NSMutableArray* clipedVideo = [[NSMutableArray alloc] initWithArray:[self loadVideoList:fileName]];
    if (clipedVideo == nil) {
        clipedVideo = [[NSMutableArray alloc] init];
    }
    NSInteger index = [clipedVideo indexOfObject:videoInfo];
    [clipedVideo removeObject:videoInfo];
    [clipedVideo insertObject:toVideoInfo atIndex:index];
    [self saveVideoInfo:clipedVideo fileName:fileName];
}

@end
