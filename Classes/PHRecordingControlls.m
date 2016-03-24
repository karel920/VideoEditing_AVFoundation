//
//  PHRecordingControlls.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/14/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHRecordingControlls.h"
#import "UIVIew+Helper.h"
#import "UIColor+Helper.h"
@interface PHRecordingControlls ()

@property (nonatomic, strong) UIImage *recStartImage;
@property (nonatomic, strong) UIImage *recStopImage;
@property (nonatomic, strong) UIImage *outerImage1;
@property (nonatomic, strong) UIImage *outerImage2;
@property (nonatomic, strong) UIImageView *outerImageView;

@end
@implementation PHRecordingControlls

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _zoomFactorSlider = [[UISlider alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 15.0f, frame.size.height)];
        
        
        [_zoomFactorSlider setMaximumValue:2.0f];
        [_zoomFactorSlider setMinimumValue:1.0f];
        [_zoomFactorSlider setTintColor:[UIColor prepHeroYellowColor]];
        
        [_zoomFactorSlider setContinuous:YES];
        
        [self addSubview:_zoomFactorSlider];
        
        _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
       
        
        UIImage *image;
        
        image = [UIImage imageNamed:@"shutter-button-start"];
        
        _recStartImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_captureButton setImage:_recStartImage
                        forState:UIControlStateNormal];
        
        image = [UIImage imageNamed:@"shutter-button-stop"];
        _recStopImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [_captureButton setTintColor:[UIColor colorWithRed:245./255.
                                                         green:51./255.
                                                          blue:51./255.
                                                         alpha:.8]];
       
        _outerImage1 = [UIImage imageNamed:@"shutter-button-outer1"];
        _outerImage2 = [UIImage imageNamed:@"shutter-button-outer2"];
        _outerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _outerImage1.size.width, _outerImage1.size.height)];
        _outerImageView.image = _outerImage1;
        [_captureButton addSubview:_outerImageView];
         _captureButton.frame = CGRectMake(40.0f, (frame.size.height  - _outerImage1.size.height)/2.0f, _outerImage1.size.width, _outerImage1.size.height);
        
        [self addSubview:_captureButton];
        
        // Comment Background when done
        //[self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
        // Layout setup
        //[self autolayout];
        
        // make it veritical. UISlider Vertical Doesn't work well with autolayout. Ref http://stackoverflow.com/questions/2377030/how-to-put-uislider-vertical/11261831#11261831
        //[_zoomFactorSlider removeFromSuperview];
        //[_zoomFactorSlider removeConstraints:_zoomFactorSlider.constraints];
        //[_zoomFactorSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
        _zoomFactorSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        //[self addSubview:_zoomFactorSlider];
        
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _captureButton.frame = CGRectMake(40.0f, (self.frame.size.height - _outerImage1.size.height)/2.0f, _outerImage1.size.width, _outerImage1.size.height);
    _zoomFactorSlider.frame = CGRectMake(5.0f, 0.0f, 15.0f, self.frame.size.height);
}

- (void)toggleRecordingControlls:(BOOL)stopped
{
    if (stopped) {
        [_captureButton setImage:_recStartImage forState:UIControlStateNormal];
    }else{
        [_captureButton setImage:_recStopImage forState:UIControlStateNormal];
    }
    
    
}
- (void)autolayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_zoomFactorSlider, _captureButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10)-[_zoomFactorSlider]-(10)-[_captureButton]-(5)-|" options: 0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[_zoomFactorSlider]-(10)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[_captureButton(70)]-(>=10)-|" options:0 metrics:nil views:views]];
}
 
@end
