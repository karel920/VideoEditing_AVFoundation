//
//  PHHighlightsViewController.h
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"

@interface PHHighlightsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *videoList;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;

- (void)removeSelectedHighlightVideo;

@end
