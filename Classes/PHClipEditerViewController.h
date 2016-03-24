//
//  PHClipEditerViewController.h
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayerView.h>
#import <VIMVideoPlayer.h>
#import "PHVideoSegmentsViewController.h"
#import "PHPrimaryButton.h"

@interface PHClipEditerViewController : UIViewController<UITextFieldDelegate, VIMVideoPlayerViewDelegate, VIMVideoPlayerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtClipVideoName;
@property (strong, nonatomic) IBOutlet UITextField *txtClipDate;
@property (strong, nonatomic) IBOutlet UITextField *txtClipDescription;
@property (strong, nonatomic) IBOutlet UIView *dateView;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnSaveClip;
@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) NSManagedObject *videoData;
@property (strong, nonatomic) IBOutlet UIDatePicker *setDatePickerView;

- (IBAction)btnSelectDate:(id)sender;
- (IBAction)btnDateClicked:(id)sender;

@end
