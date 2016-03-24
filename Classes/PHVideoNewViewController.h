//
//  PHVideoNewViewController.h
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHVideoSegmentsViewController.h"

@interface PHVideoNewViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) PHVideoSegmentsViewController *segmentVC;
@property (strong, nonatomic) NSMutableArray *videosList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *strClipedName;
@property (strong, nonatomic) NSString *strClipedDescription;

- (IBAction)btnMessageViewClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;

@end
