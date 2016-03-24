//
//  PHCaptureViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/18/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//
//  Forked From https://github.com/adriaan/VideoCaptureDemo

#import "PHCaptureViewController.h"
#import "PHFileManager.h"
#import "PHPermissionsManager.h"
#import "UIColor+Helper.h"
#import "UIVIew+Helper.h"
#import "Video.h"
#import "PHCameraInfoView.h"
#import "PHRecordingControlls.h"
#import "PHLocationManager.h"
#import "PHRecorder.h"
#import "PHVideoMerge.h"


@interface PHCaptureViewController () <UITabBarDelegate, RecordingCallbackListener>
{
    NSTimeInterval startTime;
    
    PHRecorder *recorder;
    BOOL orientationLandscape;

}


@property (nonatomic, strong) PHCameraInfoView *cameraInfoView;

@property (nonatomic, strong) UIView *cameraPreviewView;

@property (nonatomic, strong) UIView *orientationNoticeView;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIImageView *deviceIconView;

@property (nonatomic, strong) PHRecordingControlls *recordingControllsView;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL dismissing;
@property (nonatomic, assign) NSTimer *timer;

@end


@implementation PHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    // orientation lock check
   
    //NSLog(@"Locked: %@",[orientationLockManager isLocked] ? @"YES":@"NO");
    
    [self checkPermissions];
    [self configureInterface];
    [self initRecorder];
    
}


- (IBAction)slideZoomFactor:(UISlider *)sender {
    self.cameraInfoView.extraOutputLabel.text = [NSString stringWithFormat:@"Slider Value: %f", sender.value];
    
    CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(sender.value, sender.value);
    affineTransform = CGAffineTransformScale(affineTransform, sender.value, sender.value);
    affineTransform = CGAffineTransformRotate(affineTransform, 0);
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];

    [self.cameraPreviewView setTransform:affineTransform];

    [recorder setScaleAndCropFactor:sender.value];
    
    [CATransaction commit];
    
    self.cameraInfoView.zoomcontrolLabel.text = [NSString stringWithFormat:@"Zoom Factor: %f", [recorder getVideoZoomFactor]];
    
}

- (IBAction)toggleRecording:(id)sender {
    [self endTimer];
    
    NSArray *videoFiles = [recorder getVideoFiles:kPHMaxRecordDuration];
    
    PHFileManager *fm = [PHFileManager new];
    NSURL *newFileURL = [fm tempFileURL];
    
    NSLog(@"Tmp File - %@", newFileURL);
    
    [[NSFileManager defaultManager] removeItemAtURL:newFileURL error:nil];
    
    [PHVideoMerge mergeVideos:videoFiles toVideoFile:newFileURL maxSeconds:kPHMaxRecordDuration completion:^(BOOL success) {
        [fm copyFileToCameraRoll:newFileURL];
    }];
    
    [self startTimer];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    // return !_recording;
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)checkPermissions {
    PHPermissionsManager *pm = [PHPermissionsManager new];
    [pm checkCameraAuthorizationStatusWithBlock:^(BOOL granted) {
        if(!granted){
            NSLog(@"we don't have permission to use the camera");
        }
    }];
    if ([CLLocationManager locationServicesEnabled]) {
        
        [pm checkLocationAuthorizationWithBlock:^(BOOL granted) {
            if(!granted) {
                NSLog(@"we don't have permission to use the location");
            }else{
                // Start Location Update
                //[[PHLocationManager sharedLocationManager] startLocationUpdates];
            }
        }];
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
   
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appEnteredForeground:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)appEnteredBackground:(NSNotification *)appEnteredBackgroundNotification {

}

- (void)appEnteredForeground:(NSNotification *)appEnteredForegroundNotification {
    NSLog(@"appEnteredForegroundNotification:");
    [self checkOrientation];
    
}

- (void)checkOrientation {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    
    if (!UIDeviceOrientationIsLandscape(deviceOrientation)) {
        
        _orientationNoticeView.hidden = NO;
        _recordingControllsView.hidden = YES;
        
        [self showTabBar:self.tabBarController];
        
        [self.cameraPreviewView setHidden:YES];
        [recorder setPreview:nil];
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [NSThread detachNewThreadSelector:@selector(stop) toTarget:recorder withObject:nil];
        
    } else {
        _orientationNoticeView.hidden = YES;
        _recordingControllsView.hidden = NO;
        
        [self hideTabBar:self.tabBarController];
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [self.cameraPreviewView setHidden:NO];
        
        self.cameraPreviewView.frame = self.view.bounds;
        
        [recorder setPreview:self.cameraPreviewView];
        [recorder setPreviewOrientation:(Video_Orientation)deviceOrientation];
        

        [NSThread detachNewThreadSelector:@selector(start) toTarget:recorder withObject:nil];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.view setNeedsUpdateConstraints];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self checkOrientation];
        
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)updateViewConstraints {
    
    // update frame for status reporting
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _cameraInfoView.frame = CGRectMake(10.0f, 20.0f, screenSize.width - 150.0f, 80.0f);
    _recordingControllsView.frame = CGRectMake(_cameraInfoView.frame.size.width + 10.0f, 20.0f, screenSize.width - 20.0f - _cameraInfoView.frame.size.width, screenSize.height - 40.0f);
    
    [super updateViewConstraints];
}

- (void)configureInterface {
    self.cameraPreviewView = [[UIView alloc] init];
    self.cameraPreviewView.frame = self.view.bounds;
    [self.cameraPreviewView setHidden:YES];
    [self.view addSubview:self.cameraPreviewView];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float padding = 20.0f;
    
    // Configure Center Alert for Device Orientation
    _orientationNoticeView = [[UIView alloc] initWithFrame:CGRectMake(padding, (screenSize.height - 100.0f)/ 2.0f, screenSize.width - 2* padding, 100.0f)];
    
    _noticeLabel = [UILabel autolayoutView];
    [_noticeLabel setTextColor:[UIColor whiteColor]];
    [_noticeLabel setBackgroundColor:[UIColor clearColor]];
    [_noticeLabel setTextAlignment:NSTextAlignmentCenter];
    _noticeLabel.text = NSLocalizedString(@"Rotate Your Phone", nil);//@"Change Device Orientation for Recording";
    [_orientationNoticeView addSubview:_noticeLabel];
    UIImage *deviceHorizonal = [[UIImage imageNamed:@"device-horizontal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _deviceIconView = [[UIImageView autolayoutView] initWithImage:deviceHorizonal];
    [_deviceIconView setTintColor:[UIColor prepHeroYellowColor]];
    [_orientationNoticeView addSubview:_deviceIconView];
    
    _orientationNoticeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    [self.view addSubview:_orientationNoticeView];
    // Layout Format
    NSNumber *toppadding = [NSNumber numberWithFloat:roundf((screenSize.height - 150)/2.0f)];
    NSNumber *innerpadding = [NSNumber numberWithFloat:roundf((screenSize.width - 15 - 66)/2.0f)];
    NSNumber *secondRowPadding = [NSNumber numberWithFloat:roundf((screenSize.width - 15 - 150)/2.0f )];
    NSDictionary *metrics = @{@"height":@150.0, @"outerpadding": @15.0, @"topbottompadding":toppadding, @"innerpadding":innerpadding, @"innerpadding2":secondRowPadding};
    NSDictionary *views = NSDictionaryOfVariableBindings(_orientationNoticeView, _noticeLabel, _deviceIconView);

    [_orientationNoticeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(<=innerpadding)-[_deviceIconView(66)]-(<=innerpadding)-|" options: 0 metrics:metrics views:views]];
    [_orientationNoticeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(<=innerpadding2)-[_noticeLabel(150)]-(<=innerpadding2)-|" options:0 metrics:metrics views:views]];
    [_orientationNoticeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_deviceIconView(66)]-(<=1)-[_noticeLabel]|" options:0 metrics:metrics views:views]];

    _orientationNoticeView.hidden = NO;
    

    // Add Camera Controlls
    _recordingControllsView = [[PHRecordingControlls alloc] initWithFrame:CGRectMake(_cameraInfoView.frame.size.width +10.0f, 20.0f, screenSize.width - 20.0f - _cameraInfoView.frame.size.width, screenSize.height - 40.0f)];
    [self.view addSubview:_recordingControllsView];
    // link with selector toggleRecording
    [_recordingControllsView.captureButton addTarget:self action:@selector(toggleRecording:) forControlEvents:UIControlEventTouchDown];
    // _recordingControllsView.zoomFactorSlider.maximumValue = [_captureSessionCoordinator.cameraDevice.activeFormat videoZoomFactorUpscaleThreshold];
    [_recordingControllsView.zoomFactorSlider addTarget:self action:@selector(slideZoomFactor:) forControlEvents:UIControlEventTouchDragInside];

    // Add debug info
    _cameraInfoView = [[PHCameraInfoView alloc] initWithFrame:CGRectMake(10.0f, 20.0f, screenSize.width - 20.0f, 80.0f)];
    
    // _cameraInfoView.zoomcontrolLabel.text = [NSString stringWithFormat:@"Zoom Factor: %f",  _captureSessionCoordinator.cameraDevice.videoZoomFactor];
    [self.view addSubview:_cameraInfoView];

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if( UIDeviceOrientationIsLandscape(orientation) ){
        _orientationNoticeView.hidden = YES;
        _recordingControllsView.hidden = NO;
        
    }else{
        _orientationNoticeView.hidden = NO;
        _recordingControllsView.hidden = YES;
    }
    
}

#pragma mark - Timer Handler
- (void)timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - startTime;
    
    _cameraInfoView.timerLabel.text = [NSString stringWithFormat:@"Time leaps: %.2f", recorded];
}

#pragma mark - Tabbar hide and show
- (void) hideTabBar:(UITabBarController *) tabbarcontroller {
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            view.hidden = YES;
        }
    }
}

- (void) showTabBar:(UITabBarController *) tabbarcontroller {
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            view.hidden = NO;
            
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)initRecorder {
    VideoResolution videoResolution = VideoResolution_1920x1080;
    unsigned int bps = 8000 * 1000;
    recorder = [[PHRecorder alloc] initWithPreview:nil callbackListener:self usingFrontCamera:NO usingTorch:NO videoWithQuality:videoResolution audioRate:44100 andVideoBitRate:bps keyFrameInterval:10 framesPerSecond:30 bufferLength:0.4 bufferCount:40 validOrientations:Orientation_LandscapeRight previewOrientation:Orientation_LandscapeRight];
}

- (void)startTimer {
    NSLog(@"Timer Start");
    startTime = [[NSDate date] timeIntervalSince1970];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(timerHandler:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)endTimer {
    NSLog(@"Timer End");
    [self.timer invalidate];
    self.timer = nil;
//    [recorder stop];
    [_cameraInfoView.timerLabel setText:@"00:00:00"];
}

#pragma mark - RecordingCallbackListener delegate

- (void)recordingStateChanged: (RecordingState)recordingState
                  withMessage: (NSString *)message {
    NSLog(@"Recording State Changed To - %@", message);
    
    if (recordingState == RecordingState_Started) {
        [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
    } else if (recordingState == RecordingState_Stopping) {
        [self performSelectorOnMainThread:@selector(endTimer) withObject:nil waitUntilDone:NO];
    }
}

@end
