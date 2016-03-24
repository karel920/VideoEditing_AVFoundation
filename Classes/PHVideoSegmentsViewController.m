//
//  PHVideoSegmentsViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 12/15/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "PHVideoSegmentsViewController.h"
#import "PHVideosViewController.h"
#import "PHRowVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "PHHighlightsViewController.h"
#import "PHClipVideoInfo.h"

@interface PHVideoSegmentsViewController () <DZNSegmentedControlDelegate, UITabBarControllerDelegate>{
    NSMutableArray *videoArray;
    NSMutableArray *rowVideoArray;
    NSMutableArray *videosArray;
    NSArray *clipedVideoInfoList;
    NSArray *vidoeList;
}

@property (nonatomic, strong) PHRowVideoViewController *rowVideoTableVC;
@property (nonatomic, strong) PHVideosViewController *videosTableVC;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) PHHighlightsViewController *highlightVC;


@end

@implementation PHVideoSegmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *items = @[@"Videos", @"Raw Clips", @"Finished Clips"];
    self.tabBarController.delegate =self;
    _control = [[DZNSegmentedControl alloc] initWithItems:items];
    _control.tintColor = [UIColor prepHeroBlueColor];
    _control.delegate = self;
    _control.selectedSegmentIndex = 0;
    [_control addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_control];
    [self setUpView];
//    [NSThread detachNewThreadSelector:@selector(getVideoList) toTarget:self withObject:nil];
    [self getVideoList];
}

- (void) setUpView {
    _videosTableVC = [[PHVideosViewController alloc] init];
    _highlightVC = [[PHHighlightsViewController alloc] init];
    _rowVideoTableVC = [[PHRowVideoViewController alloc] init];
    _videosTableVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _videosTableVC.view.frame = CGRectMake(0.0f, _control.height, self.view.frame.size.width , self.view.frame.size.height - _control.height);
    _highlightVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _highlightVC.view.frame = CGRectMake(0.0f, _control.height, self.view.frame.size.width, self.view.frame.size.height - _control.height);
    _rowVideoTableVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _rowVideoTableVC.view.frame = CGRectMake(0.0f, _control.height, self.view.frame.size.width, self.view.frame.size.height - _control.height);
    _videosTableVC.segmentVC = self;
    _highlightVC.segmentVC = self;
    _rowVideoTableVC.segmentVC = self;
    [self.view addSubview:_rowVideoTableVC.view];
    [self.view addSubview:_highlightVC.view];
    [self.view addSubview:_videosTableVC.view];
}

- (void) getVideoList {
    
    videoArray = [[NSMutableArray alloc] init];
    rowVideoArray = [[NSMutableArray alloc] init];
    videosArray = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *context = [[PHUtil sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Video" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    vidoeList = [context executeFetchRequest:request error:&error];
    
    if (vidoeList == nil) {
        [_control setCount:0 forSegmentAtIndex:SegmentSel_Highlights];
        [_control setCount:0 forSegmentAtIndex:SegmentSel_RowVideos];
        [_control setCount:0 forSegmentAtIndex:SegmentSel_Videos];
    }
    else{
        
        for(NSManagedObject * managed in vidoeList) {
            
            if([[managed valueForKey:@"status"]  isEqual:PHHighLightsVideos])
            {
                [videoArray addObject:managed];
            }
            else if ([[managed valueForKey:@"status"] isEqual:PHCapturedVideos])
            {
                [rowVideoArray addObject:managed];
            }else if ([[managed valueForKey:@"status"] isEqual:ClipedVideos])
            {
                [videosArray addObject:managed];
            }
        }
        
        NSNumber *count0 = [NSNumber numberWithInteger:videosArray.count];
        [_control setCount:count0 forSegmentAtIndex:SegmentSel_Videos];
        NSNumber *count1 = [NSNumber numberWithInteger:rowVideoArray.count];
        [_control setCount:count1 forSegmentAtIndex:SegmentSel_RowVideos];
        NSNumber *count2 = [NSNumber numberWithInteger:videoArray.count];
        [_control setCount:count2 forSegmentAtIndex:SegmentSel_Highlights];
    }
    
    PHClipVideoInfo *videoInfo = [PHClipVideoInfo sharedInstance];
    clipedVideoInfoList = [videoInfo loadVideoList:ClipedVideos];

    [self setUpVideosSegment];
    [self setUpRowVideoSegment];
    [self setUpHighlightsVideoSegment];
    [self selectedSegment:_control];
}

- (void) setSegmentAtIndex:(NSInteger) index {
    [self.control setSelectedSegmentIndex:index];
    [self selectedSegment:_control];
}

- (void)selectedSegment:(DZNSegmentedControl *)control {
    
    NSInteger section = _control.selectedSegmentIndex;
   
    switch (section) {
        case SegmentSel_Videos:
            _videosTableVC.view.hidden = NO;
            _rowVideoTableVC.view.hidden = YES;
            _highlightVC.view.hidden = YES;
            break;
        case SegmentSel_RowVideos:
            _videosTableVC.view.hidden = YES;
            _rowVideoTableVC.view.hidden = NO;
            _highlightVC.view.hidden = YES;
            break;
        case SegmentSel_Highlights:
            _videosTableVC.view.hidden = YES;
            _rowVideoTableVC.view.hidden = YES;
            _highlightVC.view.hidden = NO;
            break;
        default:
            break;
    }
}

- (void) setUpVideosSegment {
    _videosTableVC.videosList = videosArray;
    _videosTableVC.highlightList = videoArray;
    _videosTableVC.videoInfoList = clipedVideoInfoList;
    [_videosTableVC.videoTableView reloadData];
}

- (void) setUpHighlightsVideoSegment {
    _highlightVC.videoList = videoArray;
    [_rowVideoTableVC.tableView reloadData];
}

- (void) setUpRowVideoSegment {
    _rowVideoTableVC.rowVideoArray = rowVideoArray;
    [_highlightVC.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"PHVideoSegmentsViewController didReceiveMemoryWarning");

}

#pragma mark - UIBarPositioningDelegate Methods

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view {
    return UIBarPositionBottom;
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    switch (tabBarController.selectedIndex) {
        case 0:
            [self getVideoList];
            break;
        default:
            break;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
