//
//  PHEncoder.h
//  PrepHero
//
//  Created by Dong on 11/6/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface PHEncoder : NSObject {
    // The URL to where the encoded file should be saved.
    NSURL *url;

    // The path to where the encoded file should be saved.
    NSString *path;

    AVAssetWriterInput *audio,
    *video;

    AVAssetWriter *writer;

    NSConditionLock *state;

    // `defaultManager` is _not_ thread safe so we need a local copy.
    NSFileManager *manager;

    // Holds the last error that was passed in from one of the native methods.
    NSError *error;

    // Whether or not encoding has started.
    bool start;

    NSInteger osVersion;
}

- (id)initWithFilename:(NSString *)filename
            andQuality:(VideoResolution)theResolution
              andAudio:(double)audioRateValue
       andVideoBitRate:(NSInteger)videoBitrate
            isPortrait:(BOOL)isPortrait
      keyFrameInterval:(NSInteger)keyframeInterval
       didChangePreset:(BOOL)changePreset;

- (void)startEncoding;
- (void)finishEncoding;
- (void)appendSample:(CMSampleBufferRef)sampleBuffer isAudio:(bool)isAudio;
- (void)dealloc;
- (NSString *)filename;

- (void)transformVideoInput:(CGAffineTransform)transform;

- (BOOL)didChangePreset;
- (VideoResolution)resolution;
- (BOOL)notReadyForDealloc;

@end
