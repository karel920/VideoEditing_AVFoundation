//
//  PHRecorder.h
//  PrepHero
//
//  Created by Dong on 11/6/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "PHEncoder.h"


typedef NS_ENUM(NSInteger, RecorderState) {
    RecorderStopped,
    RecorderPlaying,
    RecorderStarting,
    RecorderStopping
};
@protocol RecordingCallbackListener;

@interface PHRecorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession *session;
    
    AVCaptureDevice *frontVideoDevice,
    *rearVideoDevice;
    
    AVCaptureInput *audioInput,
    *videoInput;
    
    AVCaptureAudioDataOutput *audioOutput;
    AVCaptureVideoDataOutput *videoOutput;
    
    AVCaptureVideoPreviewLayer *previewOutput;
    
    // The two media encoders.
    PHEncoder *frontEncoder, *rearEncoder;
    
    NSString *path;
    
    NSLock *encoders;
    
    NSLock *worker;

    NSError *error;
    
    CGFloat volume;
    
    RecorderState state;
    
    bool ready;
}

@property (nonatomic, assign) id<RecordingCallbackListener> delegate;
@property (nonatomic, assign) CGFloat theVideoRate;
@property (nonatomic, assign) VideoResolution theVideoResolution;
@property (nonatomic, assign) BOOL allowsVideoResolutionChanges;
@property (nonatomic, assign) BOOL changePreset;
@property (nonatomic, assign) NSInteger framesPerSecond;

- (id)       initWithPreview: (UIView *)preview
            callbackListener: (id<RecordingCallbackListener>)callbackListener
            usingFrontCamera: (bool)front
                  usingTorch: (bool)torch
            videoWithQuality: (VideoResolution)videoResolution
                   audioRate: (double)audioRate
             andVideoBitRate: (NSInteger)videoBitRate
            keyFrameInterval: (NSInteger)keyframeInterval
             framesPerSecond: (NSInteger)fps
                bufferLength: (double)bufferLength
                 bufferCount: (int)bufferCount
           validOrientations: (Video_Orientation)orientation
          previewOrientation: (Video_Orientation)previewOrientation;

- (void)start;

- (void)stop;

- (bool)active;

- (void)setPreview:(UIView *)preview;

- (void)setVideoQuality:(VideoResolution)videoResolution;

- (void)setAudioRate:(double)audioRate;

- (void)setVideoBitrate:(NSInteger)videoBitRate;

- (void)setKeyFrameInterval:(NSInteger)keyFrameInterval;

- (void)setFPS:(NSInteger)fps;

- (void)setBufferLength:(double)bufferLength;

- (void)setPreviewOrientation:(Video_Orientation)previewOrientation;

- (void)validateOrientations:(Video_Orientation)videoOrientations;

- (void)changePreviewFrame:(CGRect)newFrame;

- (void)useFrontCamera:(BOOL)front completion:(void (^)(BOOL success))completionBlock;

- (void)useTorch:(BOOL)torch;

- (void)endSession;

- (NSArray *)getVideoFiles:(double)durationSeconds;

- (void)setScaleAndCropFactor:(CGFloat)factor;

- (CGFloat)getVideoZoomFactor;

@end


@protocol RecordingCallbackListener <NSObject>

@required
- (void)recordingStateChanged: (RecordingState)recordingState
                  withMessage: (NSString *)message;

@end