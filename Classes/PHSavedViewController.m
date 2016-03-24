//
//  PHSavedViewController.m
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHSavedViewController.h"
#import "PHSavedTableViewCell.h"
#import "PHClipVideoInfo.h"
#import "PHVideoMerge.h"
#import "GVUserDefaults+PrepHero.h"
#import "PHRowSaveViewController.h"
#import "PHPrimaryButton.h"

#import <UIImageView+WebCache.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SVProgressHUD.h>

@interface PHSavedViewController ()
{
}
@end

@implementation PHSavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _highlightVideos.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PHSavedTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"VideoSavedCell"];
    if (cell1 == nil) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"PHSavedTableViewCell" owner:self options:nil];
        cell1 = [nibArray objectAtIndex:0];
    }
    if (indexPath.row == 0) {
        cell1.btnUpward.enabled = NO;
    }
    if (indexPath.row == _highlightVideos.count-1){
        cell1.btnDownward.enabled = NO;
    }
    _videoData = [_highlightVideos objectAtIndex:indexPath.row];
    NSString *thumbnailImagePath = [_videoData valueForKey:@"thumbnailImagePath"];
    NSURL *thumbnailImageUrl = [NSURL fileURLWithPath:thumbnailImagePath];
    [cell1.imagePreView sd_setImageWithURL:thumbnailImageUrl];
    cell1.btnRemove.tag = indexPath.row;
    [cell1.btnRemove addTarget:self action:@selector(removeClipVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell1.btnUpward.tag = indexPath.row;
    [cell1.btnUpward addTarget:self action:@selector(videoPositionUp:) forControlEvents:UIControlEventTouchUpInside];
    cell1.btnDownward.tag = indexPath.row;
    [cell1.btnDownward addTarget:self action:@selector(videoPositionDown:) forControlEvents:UIControlEventTouchUpInside];
    return cell1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSave setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
        [btnSave setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btnSave addTarget:self action:@selector(btnSaveClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnSave.frame = CGRectMake(30, 30, tableView.frame.size.width - 60, 50);
        
        [footerView addSubview:btnSave];
        return footerView;
    }
    return nil;
}

- (IBAction) btnSaveClicked:(UIButton *) sender {
    
    NSString *strDescription = [_clipedVideo valueForKey:ClipedDescription];
    NSString *strName = [_clipedVideo valueForKey:ClipedVideoName];
    PHRowSaveViewController *rowSaveVC = [[PHRowSaveViewController alloc] init];
    rowSaveVC.strClipName = strName;
    rowSaveVC.strDescriptiom = strDescription;
    rowSaveVC.segmentVC = _segmentVC;
    rowSaveVC.groupName = ClipedVideos;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < _highlightVideos.count; i++) {
        [array addObject:[[_highlightVideos objectAtIndex:i] valueForKey:@"videoPath"]];
    }
    rowSaveVC.array = array;
    [SVProgressHUD showWithStatus:@"Saving..."];
    
    [PHVideoMerge mergeClipedVideos:array  completion:^(BOOL success) {
        NSLog(@"success");
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [SVProgressHUD dismiss];
                [self.navigationController pushViewController:rowSaveVC animated:YES];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(){
                [SVProgressHUD dismiss];
            });
        }
    }];
}

- (IBAction) removeClipVideo:(UIButton *) sender {
    
    [_highlightVideos removeObjectAtIndex:sender.tag];
    [_tableView reloadData];
}

- (IBAction) videoPositionUp:(UIButton *)sender {
    [_highlightVideos exchangeObjectAtIndex:sender.tag withObjectAtIndex:sender.tag-1];
    [_tableView reloadData];
}

- (IBAction) videoPositionDown:(UIButton *)sender {
    [_highlightVideos exchangeObjectAtIndex:sender.tag withObjectAtIndex:sender.tag+1];
    [_tableView reloadData];
}

@end
