//
//  PHVideoMerge.m
//  PrepHero
//
//  Created by Dong on 11/21/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "PHVideoMerge.h"
#import <AVFoundation/AVFoundation.h>

@implementation PHVideoMerge

+ (void) mergeVideos:(NSArray *)videoFileNames toVideoFile:(NSURL *)outputURL maxSeconds:(CGFloat)maxSeconds completion:(void (^)(BOOL success))completion {
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
    
    CGFloat totalSeconds = 0.0;
    for (int i = 0; i < videoFileNames.count; i++) {
        NSString *filename  = [videoFileNames objectAtIndex:i];
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filename]];
        
        NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if ([videoTracks count] > 0) {
            [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoTracks objectAtIndex:0] atTime:currentCMTime error:nil];
        }
        
        NSArray *audioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([audioTracks count] > 0) {
            [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[audioTracks objectAtIndex:0] atTime:currentCMTime error:nil];
        }
        
        currentCMTime = CMTimeAdd(currentCMTime, videoAsset.duration);
        totalSeconds = CMTimeGetSeconds(currentCMTime);
        
        if (totalSeconds >= maxSeconds) {
            break;
        }
    }
        
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = outputURL;
    
    // CMTimeValue val = mixComposition.duration.value;
    CMTime start = CMTimeMake(0, 1);
    CMTime duration = CMTimeMakeWithSeconds(maxSeconds, 1);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL success = YES;
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                success = NO;
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error] debugDescription]);

                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                success = NO;
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                success = YES;
                NSLog(@"Export complete!");
                break;
            }
            default:
            {
                NSLog(@"default");
            }
        }
        
        completion(success);
    }];
}

+ (void) mergeClipedVideos:(NSArray *)videoAssetFileNames completion:(void (^)(BOOL success))completion {
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime currentCMTime = kCMTimeZero;
     for (int i = 0; i < videoAssetFileNames.count; i++) {
        NSString *filename  = [videoAssetFileNames objectAtIndex:i];
        AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:filename]];
        AVAssetTrack *assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        currentCMTime = CMTimeAdd(currentCMTime, videoAsset.duration);
         [compositionTrack insertTimeRange:assetTrack.timeRange ofTrack:assetTrack atTime:kCMTimeZero error:nil];
    }
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [filePaths objectAtIndex:0];
    NSString *videoFilePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/result.mov"]];
    NSURL *movieDestinationUrl = [NSURL fileURLWithPath: videoFilePath];
    NSLog(@"movie url destination %@",movieDestinationUrl);
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFilePath error:nil];
    }

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.outputURL = movieDestinationUrl;
    
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, currentCMTime);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL success = YES;
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                success = NO;
                NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error] debugDescription]);
                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                success = NO;
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                success = YES;
                NSLog(@"Export complete!");
                break;
            }
            default:
            {
                NSLog(@"default");
            }
        }
        
        completion(success);
    }];

}

@end
