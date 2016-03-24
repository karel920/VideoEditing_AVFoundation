//
//  PHSavedTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHSavedTableViewCell.h"
#import "PHClipViewController.h"
#import "PHVideoSegmentsViewController.h"

@implementation PHSavedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _UpButtonView.layer.cornerRadius = 5.0f;
    _DownButtonView.layer.cornerRadius = 5.0f;
    _btnRemove.layer.cornerRadius = 5.0f;
    _buttonView.layer.cornerRadius = 5.0f;
    // set button up and button down arrow
   
    _btnUpward.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    [_btnUpward setTitle:[NSString fontAwesomeIconStringForEnum:FASortDesc] forState:UIControlStateNormal];
    
    _btnDownward.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    [_btnDownward setTitle:[NSString fontAwesomeIconStringForEnum:FASortAsc] forState:UIControlStateNormal];
    
    UIImage *buttonBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor]
                                                      cornerRadius:1.0f
                                                       shadowColor:[UIColor prepHeroYellowColor]
                                                      shadowInsets:UIEdgeInsetsZero];
    
    UIImage *buttonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor blackColor]
                                                            cornerRadius:1.0f
                                                             shadowColor:[UIColor blackColor]
                                                            shadowInsets:UIEdgeInsetsZero];
    
    [_btnUpward setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnUpward setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnUpward setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateDisabled];
    [_btnUpward setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnUpward setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [_btnDownward setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnDownward setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnDownward setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateDisabled];
    [_btnDownward setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDownward setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [_btnRemove setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnRemove setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    
    player = [[VIMVideoPlayer alloc] init];
    player.delegate = self;
    _playView.delegate = self;
    [_playView setVideoFillMode: AVLayerVideoGravityResizeAspect];
    
    flag = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay)];
    [_playView addGestureRecognizer:tapGesture];

}

- (void) setPLayData: (NSString *) urlString {

    NSURL *url = [NSURL URLWithString:urlString];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    [player setAsset:asset];
    [_playView setPlayer:player];
}

- (void) tapPlay {
    if (flag) {
        [player play];
        flag = NO;
    }else{
        [player pause];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
