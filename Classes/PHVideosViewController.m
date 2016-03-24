//
//  PHVideosViewController.m
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideosViewController.h"
#import "PHVideoVideosTableViewCell.h"
#import "PHVideoNewViewController.h"
#import "PHVideoEditViewController.h"
#import "PHPlayVideoViewController.h"
#import "NSString+FontAwesome.h"

#import <UIImageView+WebCache.h>

@interface PHVideosViewController (){
    UIButton *btnNewVideos;
}

@end

@implementation PHVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewSetUp];
}

- (void)viewWillAppear:(BOOL)animated{
    [_videoTableView reloadData];
}

- (void) viewSetUp {
    
    UIImage *newButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor]
                                                         cornerRadius:5.0f
                                                          shadowColor:[UIColor prepHeroYellowColor]
                                                         shadowInsets:UIEdgeInsetsZero];
    
    UIImage *newButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroBlueColor]
                                                               cornerRadius:5.0f
                                                                shadowColor:[UIColor prepHeroBlueColor]
                                                               shadowInsets:UIEdgeInsetsZero];
    
    [_btnNewVideo setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
    [_btnNewVideo setBackgroundImage:newButtonActiveBackgroundImage forState:UIControlStateSelected];
    [_btnNewVideo setBackgroundImage:newButtonActiveBackgroundImage forState:UIControlStateReserved];
    
    [_btnNewVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnNewVideo setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
}

- (IBAction)btnNewVideos:(id)sender {
    
    PHVideoNewViewController *newVideoVC = [[PHVideoNewViewController alloc] init];
    newVideoVC.segmentVC = _segmentVC;
    newVideoVC.videosList = _highlightList;
    [_segmentVC.navigationController pushViewController:newVideoVC animated:YES];
}

#pragma mark - table View delegate methods implementation

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_videosList == nil || _videoInfoList.count == 0) {
        return 1;
    }else{
        return _videosList.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_videoInfoList.count == 0) {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No Edited Video are currently available. Please capture some amazing footages or edit your clips";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITableViewCell *emptyCell = [[UITableViewCell alloc] init];
        return emptyCell;
    }else {
        tableView.backgroundView = [[UIView alloc] initWithFrame:tableView.frame];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    PHVideoVideosTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:@"VideosCell"];
    if (videoCell == nil) {
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PHVideoVideosTableViewCell" owner:self options:nil];
        videoCell = [array objectAtIndex:0];
    }
    NSManagedObject *videoManaged =  [_videosList objectAtIndex:indexPath.row];
    NSString *thumbnailImagePath = [videoManaged valueForKey:@"thumbnailImagePath"];
    NSURL *thumbnailImageUrl = [NSURL fileURLWithPath:thumbnailImagePath];
    [videoCell.imagePreView sd_setImageWithURL:thumbnailImageUrl];
    videoCell.playView.tag = indexPath.row;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
    [videoCell.playView addGestureRecognizer:recognizer];
    videoCell.btnEdit.tag = indexPath.row;
    [videoCell.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    return videoCell;
}

- (void) tapPlay:(UITapGestureRecognizer *) recognizer {
    NSInteger index = recognizer.view.tag;
    NSManagedObject *managedObject = [_videosList objectAtIndex:index];
    NSString *videoPath = [managedObject valueForKey:@"videoPath"];
    PHPlayVideoViewController *playerVC = [[PHPlayVideoViewController alloc] initWithNibName:@"PHPlayVideoViewController" bundle:nil];
    [playerVC setVideoPath:videoPath];
    [_segmentVC presentViewController:playerVC animated:YES completion:nil];
}


- (IBAction) btnEditClicked:(UIButton *)sender {
    NSManagedObject *videoManaged =  [_videosList objectAtIndex:sender.tag];
    NSDictionary *videoInfo = [_videoInfoList objectAtIndex:sender.tag];
    PHVideoEditViewController *editVC = [[PHVideoEditViewController alloc] init];
    editVC.videoInfo = videoInfo;
    editVC.managed = videoManaged;
    [_segmentVC.navigationController pushViewController:editVC animated:YES];

}

- (void) viewWillDisappear:(BOOL)animated {
    [_videoTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
