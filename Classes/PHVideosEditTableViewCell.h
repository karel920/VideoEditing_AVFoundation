//
//  PHVideosEditTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/23/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VIMVideoPlayerView.h>

@interface PHVideosEditTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UIButton *btnPositionUp;
@property (strong, nonatomic) IBOutlet UIButton *btnPositionDown;
@property (strong, nonatomic) IBOutlet VIMVideoPlayerView *playView;
@property (strong, nonatomic) IBOutlet UIImageView *preVideoView;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) NSManagedObject *videoData;
@property (strong, nonatomic) NSDictionary *dict;

@end
