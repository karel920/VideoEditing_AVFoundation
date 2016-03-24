//
//  PHRecordingControlls.h
//  PrepHero
//
//  Created by Xinjiang Shao on 8/14/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHRecordingControlls : UIView

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UISlider *zoomFactorSlider;

- (void)toggleRecordingControlls:(BOOL)stopped;
@end
