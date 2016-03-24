//
//  PHPlayVideoViewController.m
//  PrepHero
//
//  Created by admin on 2/11/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHPlayVideoViewController.h"

@interface PHPlayVideoViewController ()
{
    AVURLAsset *asset;
    CGRect frameRect;
    CMTime duration;
    CGSize size;
}
@end

@implementation PHPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:_videoPath];
    asset = [AVURLAsset assetWithURL:url];
    
    // video player init
    _player = [[VIMVideoPlayer alloc] init];
    [_player setAsset:asset];
    _player.delegate = self;
    
    // player view init
    [self getPlayViewFrame];
    [self playerViewSetUp];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void) playerViewSetUp {
    
    _playView = [[VIMVideoPlayerView alloc] initWithFrame:frameRect];
    _playView.clipsToBounds = YES;
    [_playView setPlayer:_player];
    _playView.delegate = self;
    [_playView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    UITapGestureRecognizer *recognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
    [_playView addGestureRecognizer:recognize];
    [self.view addSubview:_playView];
}

- (void) getPlayViewFrame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    size = asset.naturalSize;
    float sizeRate = screenSize.width/size.width;
    CGPoint originPoint = CGPointMake(0, screenSize.height/2 - size.height*sizeRate/2);
    frameRect =  CGRectMake(originPoint.x, originPoint.y, size.width*sizeRate, size.height*sizeRate);
}

- (void) playViewChangeFrame {
    _playView.frame = frameRect;
}

- (void) checkOrientation:(NSNotification *)notification {
    [self getPlayViewFrame];
    [self playViewChangeFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setVideoData:(NSString *)videoPath {
    _videoPath = videoPath;
}

- (void) tapPlay:(UITapGestureRecognizer *)recognize {
    if (_playView.player.isPlaying) {
        [_player pause];
    } else {
        [_player play];
    }
}

- (IBAction)btnButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark - VIMVideoPlayView delegate
- (void)videoPlayerViewDidReachEnd:(VIMVideoPlayerView *)videoPlayerView {
    [_player seekToTime:0];
}

@end
