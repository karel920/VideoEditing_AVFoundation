//
//  PHVideosViewController.h
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"

#import "PHPrimaryButton.h"

@interface PHVideosViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnNewVideo;
@property (strong, nonatomic) IBOutlet UITableView *videoTableView;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) NSMutableArray *videosList;
@property (strong, nonatomic) NSMutableArray *highlightList;
@property (strong, nonatomic) NSArray *videoInfoList;

- (IBAction)btnNewVideos:(id)sender;

@end
