//
//  PHVideoPickerViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/30/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHVideoPickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PHVideoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *camera;
@end

@implementation PHVideoPickerViewController

- (instancetype)init
{
    self = [super init];
    if(self){
        _camera = [self setupImagePicker];
    }
    return self;
}

- (UIImagePickerController *)cameraVC
{
    return _camera;
}

#pragma mark - Private methods

- (UIImagePickerController *)setupImagePicker
{
    UIImagePickerController *camera;
    
    camera = [UIImagePickerController new];
    camera.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    camera.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    camera.delegate = self;
    camera.editing = NO;
    return camera;
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    //NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a video picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
