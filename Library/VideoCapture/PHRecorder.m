//
//  PHRecorder.m
//  PrepHero
//
//  Created by Dong on 11/6/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PHRecorder.h"
#import "PHVideoSessionManager.h"

#define VIDEO_CLIP_NAME         @"video_clip_%d.mov"

static PHRecorder *recorder = nil;

@interface PHRecorder ()
{
    AVCaptureVideoOrientation referenceOrientation;
    
    Video_Orientation recordingOrientation;
    
    BOOL isPortrait;
    
    BOOL waitingForVideoToBeSaved;
    BOOL waitingToProperlyStop;
    
    BOOL sessionJustStarted;
    
    CGFloat theAudioRate;
    CGFloat theVideoRate;
    
    NSInteger framesPerSecond;
    NSInteger kFrameInterval;
    
    VideoResolution theVideoResolution;
    
    NSMutableArray *encodersQueue;
    
    double BUFFER_LENGTH;
    int BUFFER_COUNT;
    
    BOOL sessionWasRunnig;
    
    NSThread *currentThread;
    
    dispatch_queue_t movieWritingQueue;
    
    NSConditionLock *record;
    
    int currentBuffer;
    
    BOOL isFront;
}

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;
@property (nonatomic, copy) void (^changeCameraCompletionBlock)(BOOL);

@end

@implementation PHRecorder

@synthesize referenceOrientation;
@synthesize theVideoRate;
@synthesize theVideoResolution;
@synthesize allowsVideoResolutionChanges;
@synthesize changePreset;
@synthesize framesPerSecond;

- (id)init {
    
    if (self = [super init]) {
        
        NSLog(@"initialize");
        
        recorder = self;
        
        state = RecorderStopped;
        
        ready = YES;
        
        previewOutput = nil;
        
        encoders = [[NSLock alloc] init];
        worker = [[NSLock alloc] init];
        record = [[NSConditionLock alloc] initWithCondition:0];
    }
    
    return self;
}


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
{
    
    if (self = [self init]) {
        
        /*
         * Create capture session
         */
        session = [[AVCaptureSession alloc] init];
        
        /*
         * Create audio connection
         */
        
        dispatch_queue_t sampleQueue = dispatch_queue_create("recording_samples", NULL);
        
        /*
        AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio] error:nil];
        
        if (audioIn == nil) {
            [[[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                         message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                        delegate:nil
                               cancelButtonTitle:@"Dismiss"
                               otherButtonTitles:nil] autorelease] show];
            
            if (_delegate) {
                [_delegate recordingStateChanged: RecordingState_Error withMessage: @"The library requires access to your device's microphone."];
            }
            
            [session release];
            
            return nil;
        }
        
        if ([session canAddInput:audioIn])
            [session addInput:audioIn];
        audioInput = audioIn;
        [audioIn release];
        
        AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
        [audioOut setSampleBufferDelegate:self queue: sampleQueue];
        
        if ([session canAddOutput:audioOut])
            [session addOutput:audioOut];
        audioOutput = audioOut;
        [audioOut release];
         */
        
        /*
         * Create video connection
         */
        
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            
            if (device.position == AVCaptureDevicePositionFront) {
                frontVideoDevice = [device retain];
            } else {
                rearVideoDevice = [device retain];
            }
        }
        
        isFront = front;
        
        AVCaptureDevice *device = front ? frontVideoDevice : rearVideoDevice;
        
        if ( ! device || ! [device supportsAVCaptureSessionPreset: [self sessionPresetForResolution: videoResolution]]) {
            dispatch_release(sampleQueue);
            if (_delegate) {
                [_delegate recordingStateChanged: RecordingState_Error withMessage: [NSString stringWithFormat: @"This device doesn't support the selected video preset: %@", [self sessionPresetForResolution: videoResolution]]];
            }
            
            
            [frontVideoDevice release];
            [rearVideoDevice release];
            [session release];
            
            
            return nil;
        }
        
        AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
        
        if ([session canAddInput:videoIn])
            [session addInput:videoIn];
        videoInput = videoIn;
        [videoIn release];
        
        AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
        
        [videoOut setAlwaysDiscardsLateVideoFrames:YES];

        [videoOut setSampleBufferDelegate:self queue:sampleQueue];
        
        if ([session canAddOutput:videoOut])
            [session addOutput:videoOut];
        videoOutput = videoOut;
        [videoOut release];
        
        dispatch_release(sampleQueue);
        
        recordingOrientation = orientation;
        
        if (recordingOrientation != Orientation_All) {
            [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: recordingOrientation]];
        }
        else {
            [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: recordingOrientation]];
        }
        
        _delegate = callbackListener;
        
        kFrameInterval = keyframeInterval;
        theVideoResolution = videoResolution;
        theVideoRate = videoBitRate;
        theAudioRate = audioRate;
        
        BUFFER_LENGTH = bufferLength > 0 ? bufferLength : kDefaultBufferLength;
        BUFFER_COUNT = bufferCount > 0 ? bufferCount : kDefaultBufferCount;
        
        encodersQueue = [[NSMutableArray alloc] init];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [notificationCenter addObserver: self
                               selector: @selector(savingFileStateChanged:)
                                   name: @"saveFileState"
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationDidEnterBackground)
                                   name: UIApplicationDidEnterBackgroundNotification
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationDidEnterForeground)
                                   name: UIApplicationDidBecomeActiveNotification
                                 object: nil];
        
        
        if (![PHVideoSessionManager setPreset: videoResolution forSession: session]) {
            
            theVideoResolution = VideoResolution_192x144;
            theVideoRate = MaximumBitrate_192x144;
            
            if (_delegate) {
                [_delegate recordingStateChanged: RecordingState_Warning withMessage: [NSString stringWithFormat: @"This version of the library does not support this video resolution. 192x144 at %ld bitrate will be considered.", (long)MaximumBitrate_192x144]];
            }
        }
        
        self.referenceOrientation = [self captureOrientationFromVideoOrientation: orientation];
        
        if (recordingOrientation == Orientation_All) {
            [self setOutputOrientation: [[UIDevice currentDevice] orientation]];
        }
        
        if (previewOrientation == Orientation_All) {
            previewOrientation = Orientation_Portrait;
        }
        
        switch (recordingOrientation) {
            case Orientation_LandscapeLeft:
            case Orientation_LandscapeRight:
                isPortrait = NO;
                break;
            case Orientation_Portrait:
            case Orientation_PortraitUpsideDown:
                isPortrait = YES;
                break;
            default:
                break;
        }
        
        // Add preview layer.
        if (preview) {
            previewOutput = [[AVCaptureVideoPreviewLayer alloc] initWithSession: session];
            [previewOutput setFrame:[preview bounds]];
            
            [[preview layer] insertSublayer: previewOutput atIndex: 0];

            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.9) {
                
                if ([[previewOutput connection] isVideoOrientationSupported]) {
                    
                    [[previewOutput connection] setVideoOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
                }
            } else {
                if ([previewOutput isOrientationSupported]) {
                    [previewOutput setOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
                }
            }
        }
        
        
        // Setup notifications.
        NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
        [notify addObserver:self
                   selector:@selector(onRecordError:)
                       name:AVCaptureSessionRuntimeErrorNotification
                     object:session];
        
        [notify addObserver:self
                   selector:@selector(onRecordStart)
                       name:AVCaptureSessionDidStartRunningNotification
                     object:session];
        
        [notify addObserver:self
                   selector:@selector(onRecordStop)
                       name:AVCaptureSessionDidStopRunningNotification
                     object:session];
        
        framesPerSecond = fps;
        
        [self useTorch:torch];
        
        [session beginConfiguration];
        [self setFrameRate: (int32_t)fps];
        [session commitConfiguration];
        
        movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
        
        // Start session.
        [session startRunning];
        
    }
    
    return self;
}


#pragma mark -
#pragma mark Setup Encoders

- (NSString *)getClipName:(int)bufferIndex
{
    NSString *clipName = [NSString stringWithFormat:VIDEO_CLIP_NAME, bufferIndex];
    return clipName;
}

- (void)setupEncoders
{
    if (recordingOrientation == Orientation_All) {
        [session beginConfiguration];
        [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: self.referenceOrientation];
        [session commitConfiguration];
    }
    
    [self setupEncodersQueue];
}

- (void)setupEncodersQueue
{
    @synchronized(encodersQueue){
        
        @synchronized(encodersQueue) {
            [encodersQueue removeAllObjects];
        }
        
        if (frontEncoder) {
            [frontEncoder release];
            frontEncoder = Nil;
        }
        
        currentBuffer = 0;
        
        PHEncoder *encoder1 = [[PHEncoder alloc] initWithFilename: [self getClipName:currentBuffer]
                                                       andQuality: theVideoResolution
                                                         andAudio: theAudioRate
                                                  andVideoBitRate: theVideoRate
                                                       isPortrait: isPortrait
                                                 keyFrameInterval: kFrameInterval didChangePreset: self.changePreset];
        
        currentBuffer++;
        
        PHEncoder *encoder2 = [[PHEncoder alloc] initWithFilename: [self getClipName:currentBuffer]
                                                       andQuality: theVideoResolution
                                                         andAudio: theAudioRate
                                                  andVideoBitRate: theVideoRate
                                                       isPortrait: isPortrait
                                                 keyFrameInterval: kFrameInterval didChangePreset: self.changePreset];
        
        currentBuffer++;
        
        PHEncoder *encoder3 = [[PHEncoder alloc] initWithFilename: [self getClipName:currentBuffer]
                                                       andQuality: theVideoResolution
                                                         andAudio: theAudioRate
                                                  andVideoBitRate: theVideoRate
                                                       isPortrait: isPortrait
                                                 keyFrameInterval: kFrameInterval didChangePreset: self.changePreset];
        
        rearEncoder = encoder1;
        
        @synchronized(encodersQueue){
            [encodersQueue addObject: encoder1];
            [encodersQueue addObject: encoder2];
            [encodersQueue addObject: encoder3];
            
            [encoder1 release];
            [encoder2 release];
            [encoder3 release];
        }
    }
}

- (void)addEncoderToQueue
{
    @autoreleasepool {
        
        PHEncoder *encoder = [[PHEncoder alloc] initWithFilename: [self getClipName:currentBuffer]
                                                      andQuality: theVideoResolution
                                                        andAudio: theAudioRate
                                                 andVideoBitRate: theVideoRate
                                                      isPortrait: isPortrait
                                                keyFrameInterval: kFrameInterval
                                                 didChangePreset: self.changePreset];
        changePreset = NO;
        
        currentBuffer++;
        if (currentBuffer == BUFFER_COUNT) {
            currentBuffer = 0;
        }
        
        NSLog(@"Recorder::Worker::Add Encoder. Current Buffer - %d", currentBuffer);
        
        @synchronized(encodersQueue){
            [encodersQueue addObject: encoder];
            [encoder release];
        }
    }
}

#pragma mark -
#pragma mark Frame Rate

- (void)setFrameRate:(int32_t)fr
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        NSArray *supportedFrameRateRanges = [[[(AVCaptureDeviceInput*)videoInput device] activeFormat] videoSupportedFrameRateRanges];
        
        if (supportedFrameRateRanges.count > 0) {
            AVFrameRateRange *frameRateRange = [supportedFrameRateRanges objectAtIndex: 0];
            
            if (frameRateRange.minFrameRate <= fr && frameRateRange.maxFrameRate >= fr) {
                
                [[(AVCaptureDeviceInput*)videoInput device] lockForConfiguration: NULL];
                
                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMinFrameDuration: CMTimeMake(1, fr)];
                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMaxFrameDuration: CMTimeMake(1, fr)];
                
                [[(AVCaptureDeviceInput*)videoInput device] unlockForConfiguration];
            }
            else {
                
                if (_delegate) {
                    [_delegate recordingStateChanged: RecordingState_Warning withMessage: [NSString stringWithFormat: @"The frame rate (%ld) is out of the supported frame rate range for this device [%d..%d]", (long)fr, (int)frameRateRange.minFrameRate, (int)frameRateRange.maxFrameRate]];
                }
            }
        }
    }
    else {
        AVCaptureConnection *conn = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if (conn.supportsVideoMinFrameDuration)
            conn.videoMinFrameDuration = CMTimeMake(1, fr);
        if (conn.supportsVideoMaxFrameDuration)
            conn.videoMaxFrameDuration = CMTimeMake(1, fr);
    }
}

#pragma mark -
#pragma mark Orientation Setups

- (void)setOutputOrientation:(UIDeviceOrientation)orientation
{
    if (recordingOrientation == Orientation_All) {
        
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                self.referenceOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                self.referenceOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortrait:
                self.referenceOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.referenceOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
                
            default:
                break;
        }
        
        isPortrait = UIDeviceOrientationIsPortrait(orientation) ? YES : NO;
    }
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) ) {
        
        if (state == RecorderStopped && recordingOrientation == Orientation_All) {
            
            [self setOutputOrientation: orientation];
        }
    }
}

- (AVCaptureVideoOrientation)captureOrientationFromVideoOrientation:(Video_Orientation)videoOrientation
{
    AVCaptureVideoOrientation orientation;
    
    switch (videoOrientation) {
        case Orientation_LandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case Orientation_LandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case Orientation_Portrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case Orientation_PortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return orientation;
}

#pragma mark -

- (void)dealloc {
    
    // Teardown encoders.
    if (frontEncoder) {
        [frontEncoder release];
    }
    
    if (encodersQueue) {
        [encodersQueue release];
    }
    
    // Teardown synchronization objects.
    [encoders release];
    [worker release];
    [record release];
    
    [super dealloc];
}

- (void)endSession
{
    [session stopRunning];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    if (previewOutput) {
        NSLog(@"remove preview");
        [previewOutput removeFromSuperlayer];
        [previewOutput release];
    }
    
    [frontVideoDevice release];
    [rearVideoDevice release];
    
    [session release];
    session = nil;
    
    if (movieWritingQueue) {
        dispatch_release(movieWritingQueue);
        movieWritingQueue = NULL;
    }
}

#pragma mark -
#pragma mark Workers

/// The heart of it all, combines the demuxer, encoder and the
/// streamer to send data to the destination server.
- (void)workerThread {
    
    @autoreleasepool {
        
        nlog2(DBGLog, @"Recorder::Worker::Starting...");
        
        [worker lock];
        
        BOOL didCatchError;
        
        @try {
            
            nlog2(DBGLog, @"Recorder::Worker::Sleeping...");

            state = RecorderPlaying;
            
            [encoders lock];
            
            PHEncoder *firstEncoder;
            
            @synchronized(encodersQueue) {
                firstEncoder = [encodersQueue objectAtIndex: 0];
            }
            
            @synchronized(encodersQueue) {
                rearEncoder = [encodersQueue objectAtIndex: 1];//retain
            }
            
            [rearEncoder startEncoding];
            
            [encoders unlock];
            
            [NSThread detachNewThreadSelector: @selector(finishEncoding)
                                     toTarget: firstEncoder
                                   withObject: nil];
            
            [NSThread sleepForTimeInterval:BUFFER_LENGTH];
            
            BOOL newSessionPreset;
            
            while (state == RecorderPlaying) {
                @autoreleasepool {
                    
                    nlog2(DBGLog, @"Recorder::Worker::Swapping buffers...");
                    
                    [encoders lock];
                    
                    NSDate *date;
                    
                    if (frontEncoder) {
                        [frontEncoder release];
                        frontEncoder = Nil;
                    }
                    
                    @synchronized(encodersQueue) {
                        frontEncoder = [[encodersQueue objectAtIndex: 0] retain];
                        [encodersQueue removeObjectAtIndex: 0];
                    }
                    
                    PHEncoder *midleEncoder;
                    
                    @synchronized(encodersQueue) {
                        midleEncoder = [encodersQueue objectAtIndex: 0];
                    }
                    
                    [NSThread detachNewThreadSelector: @selector(finishEncoding)
                                             toTarget: midleEncoder
                                           withObject: nil];
                    
                    @synchronized(encodersQueue) {
                        rearEncoder = [encodersQueue objectAtIndex: 1];// retain];
                    }
                    
                    [rearEncoder startEncoding];
                    
                    date = [NSDate date];
                    
                    if ([frontEncoder didChangePreset]) {
                        NSLog(@"we have a preset change ladies and gentleman!!!!!!");
                        newSessionPreset = YES;
                        [self changeSessionPreset: [frontEncoder resolution]];
                    }
                    else {
                        newSessionPreset = NO;
                    }
                    
                    [encoders unlock];
                    
                    [NSThread detachNewThreadSelector:@selector(addEncoderToQueue)
                                             toTarget:self
                                           withObject:nil];
                    
                    nlog2(DBGLog, @"Recorder::Worker::Buffers swapped.");
                    
                    // Sleep until the next buffer is finished
                    double delay;
                    
                    if (frontEncoder.notReadyForDealloc) {
                        NSLog(@"goto finally");
                    }
                    
                    delay = -[date timeIntervalSinceNow];
                    
                    if (BUFFER_LENGTH - delay > 0) {
                        NSLog(@"Worker::Sleeping... %f",BUFFER_LENGTH - delay);
                        //nlog2(DBGLog, @"Worker::Sleeping... %f", BUFFER_LENGTH - delay);
                        [NSThread sleepForTimeInterval: BUFFER_LENGTH - delay];
                    }
                }
                
            }
            
        } @catch (NSException *exception) {
            nlog(DBGLog, @"Recorder::Worker::%@ %@.", [exception name], [exception reason]);
            
            if (_delegate) {
                [_delegate recordingStateChanged: RecordingState_Error withMessage: [NSString stringWithFormat:  @"Error: %@.", [exception reason]]];
            }
            
            didCatchError = YES;
        } @finally {
            
            [encoders lock];
            
            [rearEncoder finishEncoding];
            
            [encoders unlock];
            
            nlog2(DBGLog, @"Recorder::Worker::Stopped.");
            
            [worker unlock];
            
            if (didCatchError) {
                [self stop];
            }
        }
    }
}

#pragma mark -
#pragma mark Session Preset Setup

- (void)changeSessionPreset:(VideoResolution)resolution
{
    NSLog(@"changeSessionPreset");
    
    [session beginConfiguration];
    
    [session setSessionPreset: [self sessionPresetForResolution: resolution]];
    
    [session commitConfiguration];
}

- (NSString *)sessionPresetForResolution:(VideoResolution)resolution
{
    NSString *returnResolution;
    
    switch (resolution) {
        case VideoResolution_192x144:
            returnResolution = AVCaptureSessionPresetLow;
            break;
        case VideoResolution_320x240:
            returnResolution = AVCaptureSessionPreset352x288;
            break;
        case VideoResolution_480x360:
            returnResolution = AVCaptureSessionPresetMedium;
            break;
        case VideoResolution_640x480:
            returnResolution = AVCaptureSessionPreset640x480;
            break;
        case VideoResolution_1280x720:
            returnResolution = AVCaptureSessionPreset1280x720;
            break;
        case VideoResolution_1920x1080:
            returnResolution = AVCaptureSessionPreset1920x1080;
            break;
        default:
            break;
    }
    
    return returnResolution;
}

#pragma mark - Events

- (void)onRecordStart {
    nlog2(DBGLog, @"Recorder::Session starting...");
    
    [record lockWhenCondition:0];
    [record unlockWithCondition:1];
    
    nlog2(DBGLog, @"Recorder::Session started.");
}

- (void)onRecordStop {
    nlog2(DBGLog, @"Recorder::Stopping session...");
    
    [self stop];
    [record lockWhenCondition:1];
    [record unlockWithCondition:0];
    
    nlog2(DBGLog, @"Recorder::Session stopped.");
}

- (void)onRecordError:(NSNotification *)notification {
    
    nlog2(DBGError, @"Recorder::Stream error.");
    
    NSLog(@"User Info: %@", notification.userInfo);
    
    [record lock];
    [record unlockWithCondition:2];
    
    nlog2(DBGError, @"Recorder::Stream invalidated. This should never happen.");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"didDropSampleBuffer with reason: ");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CFRetain(sampleBuffer);
    
    dispatch_async(movieWritingQueue, ^{
        
        //NSLog(@"didOutputSampleBuffer");
        if (state == RecorderPlaying) {
            
            BOOL isAudio = captureOutput == audioOutput;
            
            if (! isAudio) {
                
                [encoders lock];
                
                //[rearEncoder appendSample: sampleBuffer isAudio: NO];
                
                [rearEncoder appendSample:sampleBuffer isAudio: NO];
                
                [encoders unlock];
            }
        }
        
        CFRelease(sampleBuffer);
    });

}

#pragma mark - Public API

- (void)deleteClips {
    int i;
    
    NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    for (i = 0; i < BUFFER_COUNT; i++) {
        NSString *clipName = [self getClipName:i];
        NSString *clipFile = [appPath stringByAppendingPathComponent:clipName];
        
        if ([manager fileExistsAtPath:clipFile])
            [manager removeItemAtPath:clipFile error:&error];
    }
    
    [manager release];
    
}

/// Begin the recording process.
- (void)start {
    
    NSLog(@"START");
    
    if (waitingToProperlyStop) {
        
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Error withMessage: @"Waiting to properly stop previous session."];
        }
        return;
    }
    
    if (waitingForVideoToBeSaved) {
        
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Error withMessage: @"Waiting for previous video to be saved"];
        }
        
        return;
    }
    
    if ([rearEncoder notReadyForDealloc]) {
        
    	}
    
    nlog2(DBGLog, @"Recorder::Start encoding...");
    
    [record lockWhenCondition:1];
    
    if (state != RecorderStopped) {
        [record unlock];
        nlog2(DBGLog, @"Recorder::Already encoding.");
        
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"The recording is already running."];
        }
        return;
    }
    
    state = RecorderStarting;
    
    if (_delegate) {
        [_delegate recordingStateChanged: RecordingState_Starting withMessage: @"Preparing to start."];
    }
    
    [self deleteClips];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    nlog2(DBGLog, @"Recorder::Worker::Opening connection to server...");
    
    sessionJustStarted = YES;
    
    [self performSelectorOnMainThread: @selector(setupEncoders) withObject: nil waitUntilDone: YES];
    
    [rearEncoder startEncoding];
    
    [NSThread detachNewThreadSelector:@selector(workerThread)
                             toTarget:self
                           withObject:nil];

    [record unlock];
    
    if (_delegate) {
        [_delegate recordingStateChanged: RecordingState_Started withMessage: @"Recording started."];
    }
    
    nlog2(DBGLog, @"Recorder::Encoding started.");
}

- (void)stop {
    
    [record lockWhenCondition:1];
    
    if (state != RecorderPlaying) {
        [record unlock];
        nlog2(DBGLog, @"Recorder::Not encoding.");
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"Recording was not runnig."];
        }
        return;
    }
    
    state = RecorderStopped;
    
    waitingToProperlyStop = YES;
    
    if (_delegate) {
        [_delegate recordingStateChanged: RecordingState_Stopping withMessage: @"Recording is stopping."];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    nlog2(DBGLog, @"Recorder::Stop encoding...");
    
    NSLog(@"stop everything - finish encoding");
    
    nlog2(DBGLog, @"Recorder::Encoding stopped.");
    
    [self setOutputOrientation: [[UIDevice currentDevice] orientation]];
    
    waitingToProperlyStop = NO;
    
    //give it time to properly close the session
    [NSThread sleepForTimeInterval: 1.0];
    
    [worker lock];
    [worker unlock];
    
    [record unlock];
    
    if (_delegate) {
        [_delegate recordingStateChanged: RecordingState_Stopped withMessage: @"Recording stopped."];
    }
    
}

/// Block the main thread until `timeout` has been reached.
/// @param timeout The maximum amount of time to wait.
/// @return NO if the timeout was reached.
- (bool)join:(int)timeout {
    if (state != RecorderPlaying)
        return YES;
    
    if ([worker lockBeforeDate:[[NSDate date] dateByAddingTimeInterval:timeout]]) {
        [worker unlock];
        return YES;
    }
    
    return NO;
}

/// @return Whether or not the recorder is ready to stream.
- (bool)ready {
    return ready;
}

/// @return Whether or not the recorder is active.
- (bool)active {
    return state != RecorderStopped;
}

- (BOOL) hasMultipleCameras {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

/// Setter for whether or not to use the front camera.
/// @param front YES to use front camera, NO to use the back one.
- (void)useFrontCamera:(BOOL)front completion:(void (^)(BOOL success))completionBlock{
    
    self.changeCameraCompletionBlock = completionBlock;
    [self performSelectorInBackground: @selector(changeCameraToFront:) withObject: [NSNumber numberWithBool: front]];
}

- (void)changeCameraToFront:(NSNumber *)frontNumber
{
    @autoreleasepool {
        
        BOOL front = frontNumber.boolValue;
        
        NSLog(@"FRONT: %d", front);
        
        if ([self hasMultipleCameras]) {
            
            isFront = front;
            
            AVCaptureDevice *device = front ? frontVideoDevice
            : rearVideoDevice;
            
            NSString *sessionPreset = [session sessionPreset];
            
            if ([device supportsAVCaptureSessionPreset: sessionPreset]) {
                
                [session beginConfiguration];
                [session removeInput:videoInput];
                
                videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                [session addInput: videoInput];
                
                if (recordingOrientation == Orientation_All) {
                    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                    [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: self.referenceOrientation];
                }
                else {
                    [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: recordingOrientation]];
                }
                
                [self setFrameRate: (int32_t)framesPerSecond];
                
                [session commitConfiguration];
                
                self.changeCameraCompletionBlock(YES);
            }
            else {
                
                self.changeCameraCompletionBlock(NO);
                
                if (_delegate) {
                    [_delegate recordingStateChanged: RecordingState_Warning withMessage: [NSString stringWithFormat: @"The camera doesn't support this session preset: %@", sessionPreset]];
                }
            }
        }
        else {
            
            self.changeCameraCompletionBlock(NO);
            
            if (_delegate) {
                [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"The device doesn't have multiple cameras."];
            }
        }
    }
}

/// Setter for whether or not to turn the back LED on.
/// @param torch Whether or not to turn the back LED on.
- (void)useTorch:(BOOL)torch {
    AVCaptureTorchMode mode = torch ? AVCaptureTorchModeOn: AVCaptureTorchModeOff;
    
    if ([rearVideoDevice isTorchModeSupported: mode] && [rearVideoDevice isTorchAvailable]) {
        [rearVideoDevice lockForConfiguration:&error];
        [rearVideoDevice setTorchMode:mode];
        [rearVideoDevice unlockForConfiguration];
    }
}

- (void)setPreview:(UIView *)preview
{
    if (state == RecorderStopped) {
        
        if (previewOutput) {
            [previewOutput removeFromSuperlayer];
            [previewOutput setFrame:[preview bounds]];
            [[preview layer] insertSublayer: previewOutput atIndex: 0];
            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
        else {
            previewOutput = [[AVCaptureVideoPreviewLayer alloc] initWithSession: session];
            [previewOutput setFrame:[preview bounds]];
            [[preview layer] insertSublayer: previewOutput atIndex: 0];
            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
    }
    else {
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"Cannot change the preview while recording"];
        }
    }
}

- (void)setVideoQuality:(VideoResolution)videoResolution
{
    theVideoResolution = videoResolution;
}

- (void)setAudioRate:(double)audioRate
{
    if (state == RecorderStopped) {
        theAudioRate = audioRate;
    }
    else {
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"Cannot change the audio rate while recording"];
        }
    }
}

- (void)setVideoBitrate:(NSInteger)videoBitRate
{
    theVideoRate = videoBitRate;
}

- (void)setKeyFrameInterval:(NSInteger)keyFrameInterval
{
    kFrameInterval = keyFrameInterval;
}

- (void)setFPS:(NSInteger)fps
{
    [session beginConfiguration];
    [self setFrameRate: (int32_t)fps];
    [session commitConfiguration];
}

- (void)setBufferLength:(double)bufferLength
{
    if (state == RecorderStopped) {
        BUFFER_LENGTH = bufferLength;
    }
    else {
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"Cannot change the buffer length while recording"];
        }
    }
}

- (void)setPreviewOrientation:(Video_Orientation)previewOrientation
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.9) {
        
        if ([[previewOutput connection] isVideoOrientationSupported]) {
            
            [[previewOutput connection] setVideoOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
        }
    } else {
        if ([previewOutput isOrientationSupported]) {
            [previewOutput setOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
        }
    }
}

- (void)validateOrientations:(Video_Orientation)videoOrientations
{
    if (state == RecorderStopped) {
        recordingOrientation = videoOrientations;
        [self captureOrientationFromVideoOrientation: videoOrientations];
    }
    else {
        if (_delegate) {
            [_delegate recordingStateChanged: RecordingState_Warning withMessage: @"Cannot modify the video orientation while recording"];
        }
    }
}

- (void)changePreviewFrame:(CGRect)newFrame
{
    previewOutput.frame = newFrame;
}

- (NSArray *)getVideoFiles:(double)durationSeconds
{
    NSMutableArray *videoFiles = [[NSMutableArray new] autorelease];
    int bufferCount = ceil(durationSeconds / BUFFER_LENGTH);
    int currentBufferIndex;
    int i;
    
    currentBufferIndex = currentBuffer - 1 - (bufferCount - 1);
    if (currentBufferIndex < 0) {
        currentBufferIndex += BUFFER_COUNT;
    }
    
    NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (i = 0; i < bufferCount; i++) {
        NSString *clipName = [self getClipName:currentBufferIndex];
        [videoFiles addObject:[appPath stringByAppendingPathComponent:clipName]];
        
        currentBufferIndex++;
        
        if (currentBufferIndex >= BUFFER_COUNT) {
            currentBufferIndex = 0;
        }
    }
    
    return videoFiles;
}

- (void)setScaleAndCropFactor:(CGFloat)factor {
    AVCaptureConnection *connection;
    
    connection = [videoOutput connectionWithMediaType: AVMediaTypeVideo];
    
    NSLog(@"videoMaxScaleAndCropFactor - %f", connection.videoMaxScaleAndCropFactor);
    
    if (connection.videoMaxScaleAndCropFactor >= factor) {
        connection.videoScaleAndCropFactor = factor;
    }
    
    AVCaptureDevice *device = isFront ? frontVideoDevice : rearVideoDevice;
    
    CGFloat maxZoomFactor = [device.activeFormat videoZoomFactorUpscaleThreshold];
    
    NSError *err;
    BOOL zoomFactorSupported = NO;
    
    if (factor <= maxZoomFactor && factor >= 1.0 ) {
        zoomFactorSupported = YES;
    }
    
    if (zoomFactorSupported && [device lockForConfiguration:&err]) {
        [device rampToVideoZoomFactor:factor withRate:.025f];
        [device unlockForConfiguration];
    }
}

- (CGFloat)getVideoZoomFactor {
    AVCaptureDevice *device = isFront ? frontVideoDevice : rearVideoDevice;
    return device.activeFormat.videoZoomFactorUpscaleThreshold;
}

#pragma mark -
#pragma mark Save video manager notifications

- (void)savingFileStateChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    waitingForVideoToBeSaved = [[userInfo objectForKey: @"waitingForVideoToBeSaved"] boolValue];
}

#pragma mark -
#pragma mark Background Tasks

- (void)applicationDidEnterBackground
{
    //    NSLog(@"applicationDidEnterBackground");
    //
    //    if (state == STATE_PLAYING) {
    //        sessionWasRunnig = YES;
    //        [self stopEverything];
    //    }
}

- (void)applicationDidEnterForeground
{
    //    NSLog(@"applicationDidEnterForeground");
    //
    //    if (sessionWasRunnig) {
    //        sessionWasRunnig = NO;
    //        [self performSelector: @selector(start) withObject: nil afterDelay: 0.5];
    //    }
}

@end
