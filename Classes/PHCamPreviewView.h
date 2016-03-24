//
//  PHCamPreviewView.h
//  PrepHero
//
//  Created by Xinjiang Shao on 6/15/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVCaptureSession;
@interface PHCamPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
