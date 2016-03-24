//
//  PHRowSaveViewController.h
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayerView.h>
#import <AVFoundation/AVFoundation.h>
#import <VIMVideoPlayer.h>
#import "PHVideoSegmentsViewController.h"
#import "PHPrimaryButton.h"

@interface PHRowSaveViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblClipName;
@property (strong, nonatomic) IBOutlet UITextView *lblClipDescription;
@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) IBOutlet UISwitch *swichPublished;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnEditAgain;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnSave;

@property (strong, nonatomic) NSString *strClipName;
@property (strong, nonatomic) NSString *strDescriptiom;
@property (strong, nonatomic) NSDate *clipDate;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSManagedObject *videoData;

- (IBAction)btnEditSaveVideoClicked:(UIButton *)sender;

@end
