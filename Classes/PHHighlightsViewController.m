//
//  PHHighlightsViewController.m
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHHighlightsViewController.h"
#import "PHRowVideoTableViewCell.h"
#import "PHClipVideoInfo.h"
#import "PHPlayVideoViewController.h"

#import <UIImageView+WebCache.h>


@interface PHHighlightsViewController (){
     NSInteger _selectedIndex;
}

@end

@implementation PHHighlightsViewController

- (void)viewDidLoad {
     [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.videoList.count == 0) {
        return 1;
    }
    return self.videoList.count;
}

# pragma mark - UITableViewDelegate

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.videoList count] == 0) {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No highlight videos are found currently available. ";
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

    PHRowVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RowTableView"];
    if (cell == nil) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"PHRowVideoTableViewCell" owner:self options:nil];
        cell = [nibArray objectAtIndex:0];
    }

    NSManagedObject *managed = [_videoList objectAtIndex:indexPath.row];
    NSString *videoPath = [managed valueForKey:@"videoPath"];
    NSString *thumbnailImagePath = [managed valueForKey:@"thumbnailImagePath"];
    NSURL *thumbnailImageUrl = [NSURL fileURLWithPath:thumbnailImagePath];
    [cell.videoPreView sd_setImageWithURL:thumbnailImageUrl];
    cell.playView.tag = indexPath.row;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
    [cell.playView addGestureRecognizer:recognizer];
    PHClipVideoInfo *clipedVideoInfo = [PHClipVideoInfo sharedInstance];
    NSArray *array = [clipedVideoInfo loadVideoList:ClipedVideos];
    for(NSDictionary *highlightsVideoList in array){
        NSArray *usedCipedVideo = [highlightsVideoList objectForKey:ClipedVideos];
        for (NSString *strUsedName in usedCipedVideo) {
            if ([strUsedName isEqualToString:videoPath]) {
                cell.tapDelet.hidden = NO;
            }else {
                cell.tapDelet.hidden = YES;
            }
        }
    }
    cell.btnDelete.tag = indexPath.row;
    cell.btnEdit.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(tappedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnEdit addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void) tapPlay:(UITapGestureRecognizer *) recognizer {
    NSInteger index = recognizer.view.tag;
    NSManagedObject *managedObject = [_videoList objectAtIndex:index];
    NSString *videoPath = [managedObject valueForKey:@"videoPath"];
    PHPlayVideoViewController *playerVC = [[PHPlayVideoViewController alloc] initWithNibName:@"PHPlayVideoViewController" bundle:nil];
    [playerVC setVideoPath:videoPath];
    [_segmentVC presentViewController:playerVC animated:YES completion:nil];
}

- (IBAction) tappedDeleteButton:(UIButton *)sender {
    NSManagedObjectContext *context = [[PHUtil sharedInstance] managedObjectContext];
    NSManagedObject *manageObject = [_videoList objectAtIndex:sender.tag];
    [context deleteObject:manageObject];
    [_videoList removeObjectAtIndex:sender.tag];
    [_segmentVC.control setCount:[NSNumber numberWithInteger:[_videoList count]] forSegmentAtIndex:2];
    PHClipVideoInfo *videoInfo = [PHClipVideoInfo sharedInstance];
    NSArray *videoInfoList = [videoInfo loadVideoList:PHHighLightsVideos];
    [videoInfo removeVideo:[videoInfoList objectAtIndex:sender.tag] fileName:@"HighlightsVideo"];
    
    [self.tableView reloadData];
}

- (IBAction)tappedEditButton:(UIButton *)sender {
    _selectedIndex = sender.tag;
    PHClipViewController *clipVC = [[PHClipViewController alloc] init];
    clipVC.videoData = [_videoList objectAtIndex:sender.tag];
    clipVC.segmentVC = _segmentVC;
    clipVC.tableVC = self;
    [_segmentVC presentViewController:clipVC animated:YES completion:nil];
}

- (void)removeSelectedHighlightVideo {
    NSManagedObjectContext *context = [[PHUtil sharedInstance] managedObjectContext];
    NSManagedObject *manageObject = [_videoList objectAtIndex:_selectedIndex];
    [context deleteObject:manageObject];
    [_videoList removeObjectAtIndex:_selectedIndex];
    [_segmentVC.control setCount:[NSNumber numberWithInteger:[_videoList count]] forSegmentAtIndex:2];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
