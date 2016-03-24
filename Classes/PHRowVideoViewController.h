//
//  PHRowVideoViewController.h
//  PrepHero
//
//  Created by admin on 2/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"

@interface PHRowVideoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PHVideoSegmentsViewController *segmentVC;
@property (nonatomic, strong) NSMutableArray *rowVideoArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)removeSelectedRowVideo;

@end
