//
//  PHVideoEditViewController.h
//  PrepHero
//
//  Created by admin on 1/23/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHPrimaryButton.h"

@interface PHVideoEditViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnAbout;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnClips;
@property (strong, nonatomic) IBOutlet UITextField *txtVideoName;
@property (strong, nonatomic) IBOutlet UITextView *txtDescription;
@property (strong, nonatomic) IBOutlet UISwitch *swichPublish;
@property (strong, nonatomic) IBOutlet UITableView *tableClipView;
@property (strong, nonatomic) IBOutlet UIView *aboutView;
@property (strong, nonatomic) IBOutlet UIView *clipView;
@property (strong, nonatomic) NSManagedObject *managed;
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (strong, nonatomic) IBOutlet PHPrimaryButton *btnUpdate;

- (IBAction)btnUpdateInfoClicked:(id)sender;
- (IBAction)btnActionClicked:(UIButton *)sender;

@end
