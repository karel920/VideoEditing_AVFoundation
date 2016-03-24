//
//  PHCamPreviewView.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/15/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PHCamPreviewView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}


@end
