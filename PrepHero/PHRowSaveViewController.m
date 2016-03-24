//
//  PHRowSaveViewController.m
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHRowSaveViewController.h"
#import <VIMVideoPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD.h>
#import "PHFileManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GVUserDefaults+PrepHero.h"
#import "PHClipViewController.h"
#import "PHClipVideoInfo.h"

@interface PHRowSaveViewController () <VIMVideoPlayerDelegate, VIMVideoPlayerViewDelegate, UIGestureRecognizerDelegate>
{
    NSURL *url;
    BOOL flag;
    VIMVideoPlayer *player;
}

@end

@implementation PHRowSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get cliped video which saved in local document.and Player, playview initialize
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [filePaths objectAtIndex:0];
    NSString *videoFilePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/result.mov"]];
    url = [NSURL fileURLWithPath:videoFilePath];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    player = [[VIMVideoPlayer alloc] init];
    player.delegate = self;
    [player setAsset:asset];
    [player enableTimeUpdates];
    _playView.delegate = self;
    [_playView setPlayer:player];
    [_playView setVideoFillMode: AVLayerVideoGravityResizeAspect];
    
    // tap gesture recognize initialize for looking cliped video preview
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay)];
    [_playView addGestureRecognizer:recognizer];
    
    [self viewSetupView];
}

- (void) viewSetupView {
    _lblClipName.text = _strClipName;
    _lblClipDescription.text = _strDescriptiom;
    _buttonView.layer.cornerRadius = 5.0f;
    
    UIImage *editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonBackGroundColor] cornerRadius:3.0f shadowColor:[UIColor darkGrayColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor darkGrayColor] cornerRadius:3.0f shadowColor:[UIColor blackColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *saveButtonBackgraoundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:GreenButtonBackgroundColor] cornerRadius:3 shadowColor:[UIColor colorFromHexCode:GreenButtonActiveColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *saveButtonActiveBackgraoundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:GreenButtonActiveColor] cornerRadius:3 shadowColor:[UIColor colorFromHexCode:GreenButtonBackgroundColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    [_btnEditAgain setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnEditAgain setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnEditAgain setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnEditAgain setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnSave setBackgroundImage:saveButtonBackgraoundImage forState:UIControlStateNormal];
    [_btnSave setBackgroundImage:saveButtonActiveBackgraoundImage forState:UIControlStateHighlighted];
    [_btnSave setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

}

// when user tapped preview , Cliped video is playing.
- (void) tapPlay {
    if (flag) {
        [player play];
        flag = NO;
    }else{
        [player pause];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)btnEditSaveVideoClicked:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
            [self editAgain];
            break;
        case 2:
            [self copyClipFileToCameraRoll:url groupName:_groupName];
            break;
        default:
            break;
    }
    
}

- (void) editAgain {
    PHClipViewController *clipVC = [[PHClipViewController alloc] init];
    clipVC.segmentVC = _segmentVC;
    [clipVC setVideoData:_videoData];
    [self presentViewController:clipVC animated:YES completion:nil];
}

// Copy cliped file from document to camera roll.
- (void)copyClipFileToCameraRoll:(NSURL *)fileURL groupName: (NSString *) groupName {
    [SVProgressHUD showWithStatus:@"Saving..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        NSLog(@"video incompatible with camera roll");
        //[SVProgressHUD showErrorWithStatus:@"video incompatible with camera roll"];
    }
    
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(error){
            NSLog(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
        } else if(assetURL == nil){
            
            NSLog(@"Error saving to camera roll: no error message, but no url returned");
            
        } else {
            //remove temp file
            NSError *error;
            
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            if(error){
                NSLog(@"error: %@", [error localizedDescription]);
            }
            
            // save file to Database
            NSManagedObjectContext *context = [[PHUtil sharedInstance] managedObjectContext];
            NSManagedObject *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
            NSDate *today = [NSDate date];
            [newVideo setValue:today forKey:@"creationDate"];
            [newVideo setValue:groupName forKey:@"status"];
            [newVideo setValue:[assetURL absoluteString] forKey:@"videoPath"];
            AVAsset *asset = [AVAsset assetWithURL:assetURL];
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
            CMTime time = CMTimeMake(0, 1);
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
            NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 3);
            NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [filePaths objectAtIndex:0];
            NSString *thumbnailImagePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@0.jpg",groupName]];
            NSInteger i = 0;
            while(filePath == nil || [[NSFileManager defaultManager] fileExistsAtPath:thumbnailImagePath]){
                thumbnailImagePath = [NSString stringWithFormat:@"%@/%@%ld.jpg", filePath, groupName, (long)i];
                i++;
            }
            [thumbnailData writeToFile:thumbnailImagePath atomically:YES];
            [newVideo setValue:thumbnailImagePath forKey:@"thumbnailImagePath"];

            NSData *videoData = [NSData dataWithContentsOfURL:assetURL];
            [newVideo setValue:videoData forKey:@"video"];
            NSNumber *uid = [GVUserDefaults standardUserDefaults].uid;
            [newVideo setValue:[uid stringValue] forKey:@"uid"];
            
            error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            NSLog(@"Trim Video Done for %@", [assetURL relativePath]);
            
            [self saveVideoInfo];
            [SVProgressHUD dismiss];
        }
    }];
}

// Save Information of Cliped video
- (void) saveVideoInfo {
    NSMutableDictionary *videoInfo = [[NSMutableDictionary alloc] init];
    [videoInfo setValue:_strClipName forKey:ClipedVideoName];
    [videoInfo setValue:_strDescriptiom forKey:ClipedDescription];
    [videoInfo setValue:_clipDate forKey:ClipedDate];
    [videoInfo setValue:_array forKey:ClipedVideos];
    PHClipVideoInfo *fileManager = [PHClipVideoInfo sharedInstance];
    [fileManager addVideoInfo:videoInfo fileName:_groupName];
    if (_groupName == PHCapturedVideos) {
        [_segmentVC.control setSelectedSegmentIndex:1];
    }
    else if (_groupName == PHHighLightsVideos) {
        [_segmentVC.control setSelectedSegmentIndex:2];
    }
    else {
        [_segmentVC.control setSelectedSegmentIndex:0];
    }
    [_segmentVC getVideoList];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
