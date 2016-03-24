//
//  PHFileManager.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/18/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHFileManager.h"
#import "Video.h"
#import "GVUserDefaults+PrepHero.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>



@implementation PHFileManager
- (NSURL *)tempFileURL
{
    NSString *path = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSInteger i = 0;
    while(path == nil || [fm fileExistsAtPath:path]){
        path = [NSString stringWithFormat:@"%@prephero%ld.mov", NSTemporaryDirectory(), (long)i];
        i++;
    }
    return [NSURL fileURLWithPath:path];
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            NSLog(@"error removing file: %@", [error localizedDescription]);
        }
    }
}

- (void) copyFileToDocuments:(NSURL *)fileURL
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/prephero_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
    NSError	*error;
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){
        NSLog(@"error copying file: %@", [error localizedDescription]);
    }
}

- (void)copyFileToCameraRoll:(NSURL *)fileURL
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        NSLog(@"video incompatible with camera roll");
        //[SVProgressHUD showErrorWithStatus:@"video incompatible with camera roll"];
    }
    
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(error){
            NSLog(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
        } else if(assetURL == nil){
            
            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
            //Happens when disk is (almost) full
            NSLog(@"Error saving to camera roll: no error message, but no url returned");
            
        } else {
            //remove temp file
            NSError *error;
            
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            if(error){
                NSLog(@"error: %@", [error localizedDescription]);
            }
            
            // save file to Database
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
            NSDate *today = [NSDate date];
            [newVideo setValue:today forKey:@"creationDate"];
            [newVideo setValue:@"created" forKey:@"status"];
            [newVideo setValue:[assetURL absoluteString] forKey:@"videoPath"];
            AVAsset *asset = [AVAsset assetWithURL:assetURL];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
            CMTime time = CMTimeMake(0, 1);
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
            NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 3);
            NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [filePaths objectAtIndex:0];
            NSString *thumbnailImagePath = [filePath stringByAppendingString:@"/created0.jpg"];
            NSInteger i = 0;
            while(filePath == nil || [[NSFileManager defaultManager] fileExistsAtPath:thumbnailImagePath]){
                thumbnailImagePath = [NSString stringWithFormat:@"%@/created%ld.jpg", filePath, (long)i];
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
           
            // Post Notification PHVideoCreatedNotification
            // send Post in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                               [[NSNotificationCenter defaultCenter] postNotificationName:PHVideoCreatedNotification
                                                                object:newVideo];
                           });
            
            //return assetURL;
                       
        }
    }];
    
    //return finalURL;
    
}

- (void) removeFromCameraRoll:(NSURL *) fileURL{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        NSLog(@"video incompatible with camera roll");
        //[SVProgressHUD showErrorWithStatus:@"video incompatible with camera roll"];
    }
    [library enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            [result setVideoAtPath:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
            }];
        }];
    } failureBlock:^(NSError *error) {
        
    }];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
@end
