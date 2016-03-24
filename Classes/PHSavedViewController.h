//
//  PHSavedViewController.h
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"

@interface PHSavedViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *clipedVideo;
@property (nonatomic, strong) NSMutableArray *highlightVideos;
@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObject *videoData;

@end
