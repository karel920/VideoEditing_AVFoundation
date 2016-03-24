//
//  PHPlayVideoViewController.h
//  PrepHero
//
//  Created by admin on 2/11/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayerView.h>
#import <VIMVideoPlayer.h>

@interface PHPlayVideoViewController : UIViewController <VIMVideoPlayerDelegate, VIMVideoPlayerViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) VIMVideoPlayer *player;
@property (strong, nonatomic) NSString *videoPath;

- (IBAction)btnButtonClicked:(UIButton *)sender;
- (void)setVideoData:(NSString *)videoPath;

@end
