//
//  PHClipViewController.h
//  PrepHero
//
//  Created by admin on 1/13/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayer.h>
#import <VIMVideoPlayerView.h>
#import "PHVideoSegmentsViewController.h"
#import "PHPrimaryButton.h"

@interface PHClipViewController : UIViewController<VIMVideoPlayerDelegate, VIMVideoPlayerViewDelegate>

@property (strong, nonatomic) VIMVideoPlayerView *playView;
@property (strong, nonatomic) IBOutlet UIView *clipView;
@property (strong, nonatomic) IBOutlet UISlider *playSliderBar;
@property (strong, nonatomic) IBOutlet UIButton *btnSeekToBack;
@property (strong, nonatomic) IBOutlet UIButton *btnSeekToForword;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnPlay;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnSlow;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnSlower;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnPause;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnMarkBeginning;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnMarkYourself;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnMarkEnd;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) NSManagedObject *videoData;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) UIViewController *tableVC;


- (IBAction)btnCancelClicked:(id)sender;

@end
