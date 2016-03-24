//
//  PHRowVideoViewController.m
//  PrepHero
//
//  Created by admin on 2/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHRowVideoViewController.h"
#import "PHRowVideoTableViewCell.h"
#import "PHPlayVideoViewController.h"
#import "PHFileManager.h"
#import "PHClipVideoInfo.h"
#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>

@interface PHRowVideoViewController ()
{
    NSInteger _selectedIndex;
}

@end

@implementation PHRowVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.rowVideoArray count] == 0) {
        return 1;
    }
    return [self.rowVideoArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rowVideoArray count] == 0) {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No raw clips are currently available. Please go to capture tab to add some amazing clips!";
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
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PHRowVideoTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    
    NSManagedObject *videoData = [self.rowVideoArray objectAtIndex:indexPath.row];    
    NSString *thumbnailImagePath = [videoData valueForKey:@"thumbnailImagePath"];
    NSURL *thumbnailImageUrl = [NSURL fileURLWithPath:thumbnailImagePath];
    [cell.videoPreView sd_setImageWithURL:thumbnailImageUrl];
    cell.playView.tag = indexPath.row;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
    [cell.playView addGestureRecognizer:recognizer];
    cell.btnDelete.tag = indexPath.row;
    cell.btnEdit.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(tappedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnEdit addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void) tapPlay:(UITapGestureRecognizer *) recognizer {
    NSInteger index = recognizer.view.tag;
    NSManagedObject *managedObject = [_rowVideoArray objectAtIndex:index];
    NSString *videoPath = [managedObject valueForKey:@"videoPath"];
    PHPlayVideoViewController *playerVC = [[PHPlayVideoViewController alloc] initWithNibName:@"PHPlayVideoViewController" bundle:nil];
    [playerVC setVideoPath:videoPath];
    [_segmentVC presentViewController:playerVC animated:YES completion:nil];
}

- (IBAction)tappedDeleteButton:(UIButton *)sender {
    _selectedIndex = sender.tag;
    [self removeSelectedRowVideo];
}

- (IBAction)tappedEditButton:(UIButton *)sender {
    _selectedIndex = sender.tag;
    PHClipViewController *clipVC = [[PHClipViewController alloc] init];
    clipVC.videoData = [self.rowVideoArray objectAtIndex:sender.tag];
    clipVC.segmentVC = _segmentVC;
    clipVC.tableVC = self;
    [_segmentVC presentViewController:clipVC animated:YES completion:nil];
}

- (void)removeSelectedRowVideo {
    NSManagedObjectContext *context = [[PHUtil sharedInstance] managedObjectContext];
    NSManagedObject *manageObject = [_rowVideoArray objectAtIndex:_selectedIndex];
    [context deleteObject:manageObject];
    [_rowVideoArray removeObjectAtIndex:_selectedIndex];
    [_segmentVC.control setCount:[NSNumber numberWithInteger:[_rowVideoArray count]] forSegmentAtIndex:1];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.tableView reloadData];
}

@end
