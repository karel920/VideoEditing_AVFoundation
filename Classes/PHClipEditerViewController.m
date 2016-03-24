//
//  PHClipEditerViewController.m
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHClipEditerViewController.h"
#import <VIMVideoPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PHRowSaveViewController.h"

@interface PHClipEditerViewController ()<UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    NSMutableDictionary *date;
    NSDate *selectDate;
    NSCalendar *calendar;
    CMTime duration;
    CMTime startTime;
    VIMVideoPlayer *player;
}

@end

@implementation PHClipEditerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    date = [[NSMutableDictionary alloc] init];
    _txtClipVideoName.delegate = self;
    _txtClipDescription.delegate = self;
    _setDatePickerView.datePickerMode = UIDatePickerModeDate;
    [self setUpView];
}

- (void) setUpView {
    
    _dateView.hidden = YES;
    UIImage *editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonBackGroundColor]
                                                          cornerRadius:5.0f
                                                           shadowColor:[UIColor darkGrayColor]
                                                          shadowInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor darkGrayColor]
                                                                cornerRadius:5
                                                                 shadowColor:[UIColor blackColor]
                                                                shadowInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    
    [_btnSaveClip setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnSaveClip setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnSaveClip setTitleColor:[UIColor colorFromHexCode:@"313131"] forState:UIControlStateNormal];
    [_btnSaveClip setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [filePaths objectAtIndex:0];
    NSString *videoFilePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/result.mov"]];
    
    NSURL *url = [NSURL fileURLWithPath:videoFilePath];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    player = [[VIMVideoPlayer alloc] init];
    [player setAsset:asset];
    player.delegate = self;
    [player enableTimeUpdates];
    startTime = player.player.currentTime;
    _playView.delegate = self;
    [_playView setPlayer:player];
    [_playView setVideoFillMode: AVLayerVideoGravityResizeAspect];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay)];
    [_playView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tapPlay {
    if ([player isPlaying]) {
        [player pause];
    }else{
        [player play];
    }
}

- (IBAction)btnSelectDate:(id)sender {
    
    [_txtClipVideoName resignFirstResponder];
    [_txtClipDescription resignFirstResponder];
    _dateView.hidden = NO;
    [UIView animateWithDuration:3 animations:^{
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _dateView.frame = frame;
    }];
    
}

- (IBAction)btnDateClicked:(id)sender {
    
    NSDate *pickerDate = [_setDatePickerView date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString * dateString = [formatter stringFromDate:pickerDate];
    [_txtClipDate setText:dateString];
    [UIView animateWithDuration:3 animations:^{
        
        CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _dateView.frame = frame;
        _dateView.hidden = YES;
    }];
}

// VIMVideoPlayer Delegate methods for SliderBar

- (void)videoPlayerViewDidReachEnd:(VIMVideoPlayerView *)videoPlayerView
{
    [player.player seekToTime:startTime];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == _txtClipVideoName) {
        [textField resignFirstResponder];
    }
    else if (textField == _txtClipDescription)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)btnSaveClicked:(id)sender {
    selectDate = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    selectDate = [format dateFromString:_txtClipDate.text];
    PHRowSaveViewController * saveVideoVC = [[PHRowSaveViewController alloc] init];
    saveVideoVC.strClipName = _txtClipVideoName.text;
    saveVideoVC.strDescriptiom = _txtClipDescription.text;
    saveVideoVC.clipDate = selectDate;
    saveVideoVC.segmentVC = _segmentVC;
    saveVideoVC.groupName = PHHighLightsVideos;
    saveVideoVC.videoData = _videoData;
    [self.navigationController pushViewController:saveVideoVC animated:YES];
}

@end
