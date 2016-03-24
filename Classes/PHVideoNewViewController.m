//
//  PHVideoNewViewController.m
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideoNewViewController.h"
#import "PHVideoClipTableViewCell.h"
#import "PHClipVideoInfo.h"
#import "PHSavedViewController.h"
#import "PHNewWarningTableViewCell.h"
#import "PHInfoTableViewCell.h"
#import "PHPrimaryButton.h"

@interface PHVideoNewViewController ()<UITextFieldDelegate, UITextViewDelegate>
{
    NSArray *videoList;
    NSMutableArray *array;
    UIButton *button;
    NSArray *videoInfoList;
    PHInfoTableViewCell *infoCell;
    int unclipVideoNumber;
}

@end

@implementation PHVideoNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    array = [[NSMutableArray alloc] init];
    unclipVideoNumber = [[_segmentVC.control countForSegmentAtIndex:1] intValue];
    [self getVideoList];
}

- (void) getVideoList {
    
    PHClipVideoInfo *videoInfoManager = [PHClipVideoInfo sharedInstance];
    videoInfoList = [videoInfoManager loadVideoList:PHHighLightsVideos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnMessageViewClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [_segmentVC setSegmentAtIndex:1];
}

- (IBAction)btnSaveClicked:(id)sender {
    
    _strClipedName = infoCell.txtVideoName.text;
    _strClipedDescription = infoCell.txtVideoDescription.text;
    NSMutableDictionary *clipedVideo = [[NSMutableDictionary alloc] init];
    [clipedVideo setObject:_strClipedDescription forKey:ClipedDescription];
    [clipedVideo setObject:_strClipedName forKey:ClipedVideoName];
    NSArray *arr = [NSArray arrayWithArray:array];
    [clipedVideo setObject:arr forKey:@"HighlightsVideos"];
    PHSavedViewController *savedVC = [[PHSavedViewController alloc] init];
    NSArray *array1 = [NSArray arrayWithArray:(NSArray *)[clipedVideo objectForKey:@"HighlightsVideos"]];
    savedVC.highlightVideos = [NSMutableArray arrayWithArray:array1];
    if (array1.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please select clip video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        savedVC.clipedVideo = clipedVideo;
        savedVC.segmentVC = _segmentVC;
        [self.navigationController pushViewController:savedVC animated:YES];

    }
}

// table View delegate methods implement
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (unclipVideoNumber == 0) {
                return 0;
            }
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return _videosList.count;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nibarray = [[NSBundle mainBundle] loadNibNamed:@"PHNewWarningTableViewCell" owner:self options:nil];
    PHNewWarningTableViewCell *warningCell = [nibarray objectAtIndex:0];
    
    NSArray *nibarray1 = [[NSBundle mainBundle] loadNibNamed:@"PHVideoClipTableViewCell" owner:self options:nil];
    PHVideoClipTableViewCell *clipCell = [nibarray1 objectAtIndex:0];
    
    NSArray *nibarray2 = [[NSBundle mainBundle] loadNibNamed:@"PHInfoTableViewCell" owner:self options:nil];
    PHInfoTableViewCell *infoTableCell = [nibarray2 objectAtIndex:0];
    
    if (indexPath.section == 0) {
        warningCell.lblUnClipVideo.text = [NSString stringWithFormat:@"%d",unclipVideoNumber];
        [warningCell.btnWarningMessage addTarget:self action:@selector(btnMessageViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        return warningCell;
    }else if (indexPath.section == 1){
        infoCell = infoTableCell;
        return infoTableCell;
    }else{
        NSManagedObject *managed = [_videosList objectAtIndex:indexPath.row];
        NSDictionary *videoInfo = [videoInfoList objectAtIndex:indexPath.row];
        [clipCell getdata:managed info:videoInfo];
        return clipCell;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 100;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == _tableView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, tableView.frame.size.width, 50)];
        
        UIImage *editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor]
                                                              cornerRadius:5.0f
                                                               shadowColor:[UIColor prepHeroYellowColor]
                                                              shadowInsets:UIEdgeInsetsZero];
        
        UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor blackColor]
                                                                    cornerRadius:5.0f
                                                                     shadowColor:[UIColor blackColor]
                                                                    shadowInsets:UIEdgeInsetsZero];
        
        UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSave setTitle:@"Next" forState:UIControlStateNormal];
        [btnSave setTitleColor:[UIColor prepHeroYellowColor] forState:UIControlStateNormal];
        [btnSave setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
        [btnSave setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btnSave addTarget:self action:@selector(btnSaveClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnSave.frame = CGRectMake(30, 30,tableView.frame.size.width - 60, 50);
        
        [footerView addSubview:btnSave];
        footerView.clipsToBounds = YES;
        return footerView;
    }
    return nil;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        [array addObject:[_videosList objectAtIndex:indexPath.row]];
    }    
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2){
        for (int i = 0; i < array.count; i ++) {
            if ([array objectAtIndex:i] == [_videosList objectAtIndex:indexPath.row]) {
                [array removeObjectAtIndex:i];
            }
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 100;
            break;
        case 1:
            return 215;
            break;
        case 2:
            return 100;
            break;
        default:
            break;
    }
    return 0;
}

@end
