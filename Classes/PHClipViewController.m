//
//  PHClipViewController.m
//  PrepHero
//
//  Created by admin on 1/13/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHClipViewController.h"
#import "PHClipEditerViewController.h"
#import "PHRowVideoViewController.h"
#import "PHHighlightsViewController.h"
#import <SVProgressHUD.h>

@interface PHClipViewController ()<UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    VIMVideoPlayer *player;
    CMTime duration;
    CMTime startPlayTime;
    CMTime markTime;
    CMTime markYourselfTime;
    CMTime endClipTime;
    AVURLAsset *asset;
    UIImageView *highlightImageView;
    CGRect highlightFrame;
    NSString *filePath;
    CMTime newTiem;
    UITapGestureRecognizer *tapGestureRecognize;
    UIPanGestureRecognizer *gestureRecognize;
    UIPinchGestureRecognizer *pinchRecognizer;
    CALayer *containerLayer;
    CALayer *translucentBlackLayer;
    CAShapeLayer *maskLayer;
    UIBezierPath *path;
    CGPoint pt;
    float radiusSize;
    CGSize size;
    BOOL flagHighlightStart;
    BOOL flagEnabledSave;
    int flagValue;
    float sizeRate;
    CGRect frameRect;
}
@end

@implementation PHClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // get video data for table view database
    NSString *videoPath = [_videoData valueForKey:@"videoPath"];
    NSURL *url = [NSURL URLWithString:videoPath];
    asset = [AVURLAsset assetWithURL:url];
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    duration = videoAssetTrack.timeRange.duration;

    // video player initialize
    player = [[VIMVideoPlayer alloc] init];
    player.delegate = self;
    [player setAsset:asset];
    [player enableTimeUpdates];
    startPlayTime = player.player.currentTime;
    
    // video playView initialize
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    size = videoAssetTrack.naturalSize;
    sizeRate = screenSize.width/size.width;
    CGPoint originPoint = CGPointMake(0, (screenSize.height - 140)/2 - size.height*sizeRate/2);
    frameRect =  CGRectMake(originPoint.x, originPoint.y, size.width*sizeRate, size.height*sizeRate);
    _playView = [[VIMVideoPlayerView alloc] initWithFrame:frameRect];
    _playView.clipsToBounds = YES;
    [_playView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    [_clipView addSubview:_playView];
    _playView.delegate = self;
    [_playView setPlayer:player];
    NSLog(@"%@",NSTemporaryDirectory());
    
    // Highlight circle imageView initialize
    highlightImageView = [[UIImageView alloc] init];
    containerLayer = [CALayer layer];
    maskLayer = [CAShapeLayer layer];
    translucentBlackLayer = [CALayer layer];
    
    // View initialize of ClipVC
    [self setUpView];
    flagEnabledSave = NO;
}

- (void) setUpView {
    
    UIImage *editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonBackGroundColor] cornerRadius:2.0f shadowColor:[UIColor darkGrayColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] cornerRadius:2 shadowColor:[UIColor blackColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *editButtonDisableBackgroundImage = [UIImage buttonImageWithColor:[UIColor darkGrayColor] cornerRadius:2 shadowColor:[UIColor blackColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    [_btnMarkBeginning setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnMarkBeginning setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnMarkBeginning setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnMarkBeginning setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnMarkBeginning setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnMarkYourself setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnMarkYourself setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnMarkYourself setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnMarkYourself setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnMarkYourself setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnMarkEnd setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnMarkEnd setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnMarkEnd setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnMarkEnd setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnMarkEnd setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnPlay setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnPlay setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnPlay setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnPlay setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnSlow setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnSlow setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnSlow setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnSlow setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnSlow setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnSlower setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnSlower setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnSlower setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    [_btnSlower setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnSlower setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnPause setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnPause setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnPause setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnPause setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnPause setBackgroundImage:editButtonDisableBackgroundImage forState:UIControlStateDisabled];
    
    _btnPause.enabled = NO;
    _btnMarkYourself.enabled = NO;
    _btnMarkEnd.enabled = NO;
    _btnSave.titleLabel.textColor = [UIColor darkGrayColor];
    
    // highlight imageview setup
    highlightImageView.frame = CGRectMake(1000, 1000, 40, 40);
    [highlightImageView setImage:[UIImage imageNamed:@"Circle100"]];
    [_playView addSubview:highlightImageView];
    
    // Pangesture and Pinch gesture recognize set up
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    gestureRecognize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(videoEditing)];
    tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(highlightStart:)];
    [_playView addGestureRecognizer:gestureRecognize];
    [_playView addGestureRecognizer:pinchRecognizer];
    pinchRecognizer.delegate = self;
    gestureRecognize.delegate = self;
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.enabled = NO;
    pinchRecognizer.enabled = NO;
    gestureRecognize.enabled = NO;
    [gestureRecognize setMaximumNumberOfTouches:1];
    tapGestureRecognize.numberOfTouchesRequired = 1;
    [_playView addGestureRecognizer:tapGestureRecognize];
    
    // highlight layer install
    radiusSize = 40;
    flagHighlightStart = YES;
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filePath = [filePaths objectAtIndex:0];

}

- (void) highlightViewSetup:(CGRect) frame radius:(float) radius {
    
    [containerLayer setBounds:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    NSLog(@"%f,%f", frame.size.width,frame.size.height);
    [containerLayer setPosition:CGPointMake(frame.size.width/2, frame.size.height/2)];
    [translucentBlackLayer setBounds:[containerLayer bounds]];
    [translucentBlackLayer setPosition:CGPointMake([containerLayer bounds].size.width/2.0f, [containerLayer bounds].size.height/2.0f)];
    [translucentBlackLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [translucentBlackLayer setOpacity:0.45];
    [containerLayer addSublayer:translucentBlackLayer];
    [maskLayer setBorderColor:[[UIColor purpleColor] CGColor]];
    [maskLayer setBorderWidth:5.0f];
    [maskLayer setBounds:[containerLayer bounds]];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(pt.x - radius/2, pt.y - radius/2, radius, radius)];
    [path appendPath:[UIBezierPath bezierPathWithRect:[maskLayer bounds]]];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    [maskLayer setPath:[path CGPath]];
    [maskLayer setPosition: CGPointMake([translucentBlackLayer bounds].size.width/2.0f, [translucentBlackLayer bounds].size.height/2.0f)];
    [maskLayer setFillRule:kCAFillRuleEvenOdd];
    [translucentBlackLayer setMask:maskLayer];
}

- (IBAction) btnMarkClicked:(UIButton *)sender {
    
    switch (sender.tag) {
        case MarkButtonsState_Beginning:
            [self clipStart];
            break;
        case MarkButtonsState_Yourself:
            radiusSize = 40;
            [self highlightStart];
            break;
        case MarkButtonsState_End:
            [self highlightEnd];
            break;
        case MarkButtonsState_UnBeginning:
            if (_btnMarkEnd.tag == MarkButtonsState_UnEnd || flagHighlightStart == NO || _btnMarkBeginning.tag == MarkButtonsState_UnBeginning) {
                flagValue = ClipTimeChange_Beginnig;
                [self showWarningMessage:@"You are already clipping now. Are you going to reclip?"];
            }
            else{
                [self unMarkBeginning];
            }
            break;
        case MarkButtonsState_UnYourself:
            if (_btnMarkEnd.tag == MarkButtonsState_UnEnd || flagHighlightStart == NO) {
                flagValue = ClipTimeChange_Yourself;
                [self showWarningMessage:@"You have already set highlight, Are you going to reset?"];
            }
            else{
                [self unMarkHighlight];
            }
            break;
        case MarkButtonsState_UnEnd:
            flagValue = ClipTimeChange_End;
            [self showWarningMessage:@"You have already got highlight, Are you going to reset?"];
            break;
        default:
            break;
    }
}

- (void) clipStart {
    markTime = player.player.currentTime;
    _btnMarkBeginning.tag = MarkButtonsState_UnBeginning;
    [_btnMarkBeginning setTitle:@"UnmarkBeginning" forState:UIControlStateNormal];
    _btnMarkYourself.enabled = YES;
}

- (void) highlightStart {
    markYourselfTime = player.player.currentTime;
    _btnMarkYourself.tag = MarkButtonsState_UnYourself;
    [_btnMarkYourself setTitle:@"Unmark Yourself" forState:UIControlStateNormal];
    [self markStart];
    if (flagHighlightStart) {
        [self showAlertMessage:@"Tap on yourself on the video preview"];
    }
}

- (void) highlightEnd {
    endClipTime = player.player.currentTime;
    _btnMarkEnd.tag = MarkButtonsState_UnEnd;
    [self markEnd];
    [_btnMarkEnd setTitle:@"Unmark End" forState:UIControlStateNormal];
    flagEnabledSave = YES;
    _btnSave.titleLabel.textColor = [UIColor whiteColor];
}

- (void) unMarkBeginning {
    _btnMarkBeginning.tag = MarkButtonsState_Beginning;
    [_btnMarkBeginning setTitle:@"Mark Beginning" forState:UIControlStateNormal];
    [self unMarkHighlight];
    _btnMarkYourself.enabled = NO;
}

- (void) unMarkHighlight {
    _btnMarkYourself.tag = MarkButtonsState_Yourself;
    [_btnMarkYourself setTitle:@"Mark Yourself" forState:UIControlStateNormal];
    flagHighlightStart = YES;
    [self unMarkEnd];
    [self markEnd];
    _btnMarkEnd.enabled = NO;

}

- (void) unMarkEnd {
    _btnMarkEnd.tag = MarkButtonsState_End;
    [_btnMarkEnd setTitle:@"Mark End" forState:UIControlStateNormal];
    flagEnabledSave = NO;
    _btnSave.titleLabel.textColor = [UIColor darkGrayColor];
}

// Save Cliped video
- (IBAction)btnSaveClipedVideo:(id)sender {
    
    endClipTime = player.player.currentTime;
    [player pause];
    if(CMTimeGetSeconds(endClipTime) <= CMTimeGetSeconds(markTime))
    {
        [self showAlertMessage:@"Cannot Clip Video: Clip Duration is 0 second"];
    }
    else if (flagEnabledSave == NO)
    {
        [self showAlertMessage:@"Cannot Clip Video: Please end Clip"];
    }
    else {
        if (_tableVC.class == [PHRowVideoViewController class]) {
            PHRowVideoViewController *rowTableVC = (PHRowVideoViewController *) _tableVC;
            [rowTableVC removeSelectedRowVideo];
        }else if (_tableVC.class == [PHHighlightsViewController class]) {
            PHHighlightsViewController *highlightTableVC = (PHHighlightsViewController *) _tableVC;
            [highlightTableVC removeSelectedHighlightVideo];
        }
        
        [self videoHighlightFromMarkYourself:markYourselfTime];
        PHClipEditerViewController *clipEditVC = [[PHClipEditerViewController alloc] init];
        clipEditVC.segmentVC = _segmentVC;
        clipEditVC.videoData = _videoData;
        [_segmentVC.navigationController pushViewController:clipEditVC animated:YES];
    }
}

// All gesture event enable when click mark yourself button.
- (void) markStart {
    pinchRecognizer.enabled = YES;
    gestureRecognize.enabled = YES;
    tapGestureRecognize.enabled = YES;
}

// All gesture event disable when click mark yourself button.
- (void) markEnd {
    [containerLayer removeFromSuperlayer];
    highlightImageView.frame = CGRectMake(2000, 2000, 40, 40);
    pinchRecognizer.enabled = NO;
    gestureRecognize.enabled = NO;
    tapGestureRecognize.enabled = NO;
}

//highLight video

- (void) videoHighlightFromMarkYourself:(CMTime) editTime {

    [SVProgressHUD showWithStatus:@"Saving..."];
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CMTimeRange timeRange = CMTimeRangeMake(editTime, CMTimeMake(1, 20));
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:kCMTimeZero error:nil];
    compositionTrack.preferredTransform = assetTrack.preferredTransform;
    
    CALayer *highlightImageLayer = [CALayer layer];
    highlightImageLayer.frame = highlightFrame;
    NSLog (@"%f",highlightImageView.frame.origin.x);
    [highlightImageLayer setContents:(id) [highlightImageView.image CGImage]];
    CALayer *backGroundVideoLayer = [CALayer layer];
    backGroundVideoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    CALayer *parentLayer = [CALayer layer];
    [parentLayer addSublayer:backGroundVideoLayer];
    [parentLayer addSublayer:highlightImageLayer];
    [parentLayer addSublayer:containerLayer];
    
    AVMutableVideoComposition * layerComposition = [AVMutableVideoComposition videoComposition];
    layerComposition.frameDuration = CMTimeMake(2, 1);
    [layerComposition setAnimationTool: [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:backGroundVideoLayer inLayer:parentLayer]];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(2, 1));
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    layerComposition.instructions = [NSArray arrayWithObject:instruction];
    layerComposition.renderSize = size;
    NSString *videoFilePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/highlight.mov"]];
    NSURL *movieDestinationUrl = [NSURL fileURLWithPath: videoFilePath];
    NSLog(@"movie url destination %@",movieDestinationUrl);
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFilePath error:nil];
    }
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.videoComposition = layerComposition;
    assetExport.outputURL = movieDestinationUrl;
    assetExport.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(2,1));
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch (assetExport.status)
        {
            case AVAssetExportSessionStatusFailed:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"Failed"];
                });
                NSLog(@"Failed");
                break;
            case AVAssetExportSessionStatusCancelled:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showInfoWithStatus:@"Cancelled"];
                });
                NSLog(@"Canceled");
                break;
            default:
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [SVProgressHUD dismiss];
                });
                NSLog(@"movie complete");
                [self videoProcessing:markTime editTime:markYourselfTime endTime:endClipTime];
                break;
        }
        
       
    }];
    
}

// Video Clip function implementation

- (void) videoProcessing:(CMTime) startTime editTime:(CMTime) editTime endTime: (CMTime) endTime {
    float time1 = CMTimeGetSeconds(editTime)-CMTimeGetSeconds(startTime);
    float time2 = CMTimeGetSeconds(endTime)-CMTimeGetSeconds(editTime);
    CMTime delta1 = CMTimeMake(time1*1000, 1000);
    CMTime delta2 = CMTimeMake(time2*1000, 1000);
    CMTime total = CMTimeAdd(delta1, delta2);
    CMTimeRange timeRange1 = CMTimeRangeMake(startTime, delta1);
    CMTimeRange timeRange2 = CMTimeRangeMake(editTime, delta2);
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *track2 = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSString *clipedPath = [filePath stringByAppendingString:@"/highlight.mov"];
    NSURL *assetUrl = [NSURL fileURLWithPath: clipedPath];
    AVURLAsset *clipedAsset = [AVURLAsset assetWithURL:assetUrl];
    AVAssetTrack *track1 = [[clipedAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSArray *timeRanges = @[[NSValue valueWithCMTimeRange:timeRange1], [NSValue valueWithCMTimeRange:track1.timeRange], [NSValue valueWithCMTimeRange:timeRange2]];
    CMTime durations = CMTimeAdd(total, track1.timeRange.duration);
    CMTimeRange totalTimeRange = CMTimeRangeMake(kCMTimeZero, durations);
    NSArray *tracks = @[track, track1, track2];
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionTrack insertTimeRanges:timeRanges ofTracks:tracks atTime:kCMTimeZero error:nil];
    compositionTrack.preferredTransform = track.preferredTransform;
    
    NSString *videoFilePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/result.mov"]];
    NSURL *movieDestinationUrl = [NSURL fileURLWithPath: videoFilePath];
    NSLog(@"movie url destination: %@",movieDestinationUrl);
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:videoFilePath error:nil];
    }
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = movieDestinationUrl;
    assetExport.timeRange = totalTimeRange;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        BOOL success = YES;
        switch (assetExport.status)
        {
            case AVAssetExportSessionStatusFailed:
            {
                success = NO;
                NSLog(@"Export failed: %@ %@", [[assetExport error] localizedDescription],[[assetExport error] debugDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"Failed"];
                });
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                success = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showInfoWithStatus:@"Cancelled"];
                });
            
                NSLog(@"Export canceled");
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                success = YES;
                NSLog(@"Export complete!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                
                break;
            }
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                NSLog(@"default");
            }
        }
    }];
}


// ConvertPosition from tap position of view to highlight position of real video.
- (void) convertPosition {
    highlightFrame = CGRectMake(highlightImageView.frame.origin.x/sizeRate, size.height - (highlightImageView.frame.size.width+highlightImageView.frame.origin.y)/sizeRate, highlightImageView.frame.size.width/sizeRate, highlightImageView.frame.size.height/sizeRate);
    CGRect frame = [UIScreen mainScreen].bounds;
    float rate1 = frame.size.width/size.width;
    radiusSize = radiusSize/rate1;
    pt = CGPointMake(pt.x/rate1, size.height - pt.y/sizeRate);
    [self highlightViewSetup:CGRectMake(0, 0, frameRect.size.width/rate1, frameRect.size.height/rate1) radius:radiusSize];
}

// Move Hihghlight image and masklayer when Pan gesture recognize event happened
- (void) videoEditing {
    CGPoint translation = [gestureRecognize translationInView:self.view];
    highlightImageView.center = CGPointMake(highlightImageView.center.x + translation.x, highlightImageView.center.y + translation.y);
    highlightImageView.hidden = NO;
    path = [UIBezierPath bezierPathWithOvalInRect:
            CGRectMake(pt.x+translation.x - radiusSize/2.0f ,
                       pt.y+translation.y - radiusSize/2.0f ,
                       radiusSize, radiusSize)];
    pt.x = pt.x + translation.x;
    pt.y = pt.y + translation.y;
    [path appendPath:[UIBezierPath bezierPathWithRect:[maskLayer bounds]]];
    [maskLayer setPath:path.CGPath];
    [_playView.layer addSublayer:containerLayer];
    [gestureRecognize setTranslation:CGPointMake(0, 0) inView:self.view];
}

// highlight start.
- (IBAction) highlightStart: (UITapGestureRecognizer *) sender {
    
    _btnMarkEnd.enabled = YES;
    flagHighlightStart = NO;
    CGPoint point = [tapGestureRecognize locationInView:_playView];
    NSLog(@"%f,%f", point.x , point.y);
    float scale = highlightImageView.frame.size.width;
    highlightImageView.frame = CGRectMake(point.x - scale/2, point.y - scale/2, scale, scale);
    [_playView addSubview:highlightImageView];
    highlightImageView.hidden = NO;
    pt = point;
    [self highlightViewSetup:frameRect radius:radiusSize];
    [_playView.layer addSublayer:containerLayer];
}

// Pinch Event implement when user change highlight circle region.
- (IBAction) handlePinch :(UIPinchGestureRecognizer *)sender {
    highlightImageView.transform = CGAffineTransformScale(highlightImageView.transform, sender.scale, sender.scale);
    radiusSize = sender.scale * radiusSize;
    NSLog(@"%f,%f,%f",sender.scale, pt.x , pt.y);
    path = [UIBezierPath bezierPathWithOvalInRect:
            CGRectMake(pt.x - radiusSize/2.0f ,
                       pt.y - radiusSize/2.0f ,
                       radiusSize, radiusSize)];
    
    [path appendPath:[UIBezierPath bezierPathWithRect:[maskLayer bounds]]];
    [maskLayer setPath:path.CGPath];
    [_playView.layer addSublayer:containerLayer];
    sender.scale = 1;
}

// video player operation

- (IBAction)btnPlayClicked:(UIButton *)sender {
    switch (sender.tag) {
        case VideoPlayingState_Play:
            [player play];
            [self btnPlayEnable: NO];
            _btnMarkBeginning.enabled = NO;
            break;
        case VideoPlayingState_Slow:
            [player.player setRate:0.5f];
            [self btnPlayEnable:NO];
            _btnMarkBeginning.enabled = NO;
            break;
        case VideoPlayingState_Slower:
            [player.player setRate:0.25f];
            [self btnPlayEnable:NO];
            _btnMarkBeginning.enabled = NO;
            break;
        case VideoPlayingState_Pause:
            [player pause];
            [self btnPlayEnable:YES];
            _btnMarkBeginning.enabled = YES;
        default:
            break;
    }
}

- (void) btnPlayEnable: (BOOL) enable {
    if ((CMTimeGetSeconds(player.player.currentTime) == CMTimeGetSeconds(duration)) && (enable == NO)) {
        [self setUpView];
        [self unMarkBeginning];
    }
    _btnPlay.enabled = enable;
    _btnSlower.enabled = enable;
    _btnSlow.enabled = enable;
    _btnPause.enabled = (BOOL)(!enable);
}

- (IBAction)btnSeekClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 12:
            [self seekChange:YES];
            break;
        case 11:
            [self seekChange:NO];
            break;
        default:
            break;
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    float seekTime = sender.value*CMTimeGetSeconds(duration);
    CMTime cmTime = CMTimeMakeWithSeconds(seekTime, 1000);
    if ((_btnMarkBeginning.tag == 8 && seekTime <= CMTimeGetSeconds(markTime)) ||
        (_btnMarkYourself.tag == 9 && seekTime <= CMTimeGetSeconds(markYourselfTime))) {
        [self showAlertMessage:@"Cannot change play time."];
    }
    else{
        [player.player seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
    }
}

- (void) seekChange: (BOOL) flag {
    float seekTime;
    if (flag) {
        seekTime = CMTimeGetSeconds(player.player.currentTime) + 0.04;
    }else
    {
        seekTime = CMTimeGetSeconds(player.player.currentTime) - 0.04;
    }
    if ((_btnMarkBeginning.tag == 8 && seekTime <= CMTimeGetSeconds(markTime)) ||
        (_btnMarkYourself.tag == 9 && seekTime <= CMTimeGetSeconds(markYourselfTime))) {
        _btnSeekToBack.enabled = NO;
    }
    else{
        _btnSeekToBack.enabled = YES;
    }

    CMTime cmTime = CMTimeMakeWithSeconds(seekTime, 1000);
    [player.player seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];}

// VIMVideoPlayView Delegate methods

- (void)videoPlayerView:(VIMVideoPlayerView *)videoPlayerView timeDidChange:(CMTime)cmTime {
    float position = CMTimeGetSeconds(cmTime)/CMTimeGetSeconds(duration);
    _playSliderBar.value = position;
    if ((_btnMarkBeginning.tag == 8 && CMTimeGetSeconds(cmTime) > CMTimeGetSeconds(markTime)) ||
        (_btnMarkYourself.tag == 9 && CMTimeGetSeconds(cmTime) > CMTimeGetSeconds(markYourselfTime))) {
        _btnSeekToBack.enabled = YES;
    }
    if (flagHighlightStart == NO) {
        [self convertPosition];
        [self markEnd];
        flagHighlightStart = YES;
    }
}

- (void)videoPlayerViewDidReachEnd:(VIMVideoPlayerView *)videoPlayerView {
    if (_btnMarkEnd.tag == 10) {
        endClipTime = duration;
    }else if (_btnMarkEnd.tag == MarkButtonsState_End && _btnMarkEnd.enabled == true)
    {
        endClipTime = duration;
    }
    [self btnPlayEnable:YES];
}

// show warning when happen error.
- (void) showAlertMessage: (NSString *) message {
    [player.player pause];
    [self btnPlayEnable:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) showWarningMessage: (NSString *) message {
    [player.player pause];
    [self btnPlayEnable:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",@"Cancel", nil];
    [alert show];
}

// Alert View Delegate methods implement
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self flagValueChange];
            break;
        case 1:
            [alertView setHidden:YES];
            break;
        default:
            break;
    }
}

- (void) flagValueChange {
    switch (flagValue) {
        case ClipTimeChange_Beginnig:
            [self unMarkBeginning];
            break;
        case ClipTimeChange_Yourself:
            [self unMarkHighlight];
            break;
        case ClipTimeChange_End:
            [self unMarkEnd];
            break;
        default:
            break;
    }
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction) btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
