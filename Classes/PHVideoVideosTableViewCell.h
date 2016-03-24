//
//  PHVideoVideosTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"
#import <VIMVideoPlayerView.h>
#import <VIMVideoPlayer.h>
#import <MediaPlayer/MediaPlayer.h>


@interface PHVideoVideosTableViewCell : UITableViewCell<UIGestureRecognizerDelegate, VIMVideoPlayerDelegate>
{
    UITapGestureRecognizer *tapGesture;
}
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnPreHero;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreView;
@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;

- (IBAction)btnSharedClicked:(id)sender;
- (IBAction)btnPreHeroClicked:(id)sender;

@end
