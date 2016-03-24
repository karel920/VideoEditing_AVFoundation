//
//  PHRowVideoTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"
#import "PHClipViewController.h"
#import "PHPrimaryButton.h"
#import <MediaPlayer/MediaPlayer.h>


@interface PHRowVideoTableViewCell : UITableViewCell {
    NSLock* lock;
    CMTime startTime;
}

@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UIImageView *videoPreView;
@property (strong, nonatomic) IBOutlet UIView *tapDelet;
@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) IBOutlet UIView *playView;
@property (nonatomic) BOOL enableDelet;


@end
