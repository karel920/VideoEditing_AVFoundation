//
//  PHSavedTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayerView.h>
#import <VIMVideoPlayer.h>
#import "PHVideoSegmentsViewController.h"
#import "PHSavedViewController.h"
#import "PHPrimaryButton.h"

@interface PHSavedTableViewCell : UITableViewCell<VIMVideoPlayerDelegate,VIMVideoPlayerViewDelegate, UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *tapGesture;
    VIMVideoPlayer *player;
    BOOL flag;
}

@property (strong, nonatomic) IBOutlet UIImageView *imagePreView;
@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnUpward;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnDownward;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnRemove;
@property (strong, nonatomic) NSManagedObject *videoData;
@property (strong, nonatomic) NSMutableDictionary *videoInfo;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) NSString *assetPath;
@property (strong, nonatomic) IBOutlet UIView *DownButtonView;
@property (strong, nonatomic) IBOutlet UIView *UpButtonView;

- (void) setPLayData: (NSString *) urlString;

@end
