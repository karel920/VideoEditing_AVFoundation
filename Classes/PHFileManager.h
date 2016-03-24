//
//  PHFileManager.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/18/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHFileManager : NSObject
- (NSURL *) tempFileURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;
- (void) copyFileToCameraRoll:(NSURL *)fileURL;

@end
