//
//  PHVideoClipTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideoClipTableViewCell.h"
#import "PHVideoSegmentsViewController.h"

#import <UIImageView+WebCache.h>

@implementation PHVideoClipTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void) getdata: (NSManagedObject *) videoData info:(NSDictionary *)videoInfo{
    _videoData = videoData;
    _videoInfo = videoInfo;
    NSString *thumbnailImagePath = [videoData valueForKey:@"thumbnailImagePath"];
    NSURL *thumbnailImageUrl = [NSURL fileURLWithPath:thumbnailImagePath];
    [_videoPreviewImage sd_setImageWithURL:thumbnailImageUrl];
    _lblVideoName.text = [_videoInfo valueForKey:ClipedVideoName];
    NSDate *date = [_videoInfo valueForKey:ClipedDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *strDate = [formatter stringFromDate:date];
    _lblClipTime.text = strDate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
