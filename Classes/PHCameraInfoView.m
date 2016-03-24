//
//  PHCameraInfoView.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/14/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHCameraInfoView.h"
#import "UIColor+Helper.h"
#import "UIVIew+Helper.h"

@implementation PHCameraInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _timerLabel = [UILabel autolayoutView];
        _zoomcontrolLabel = [UILabel autolayoutView];
        _extraOutputLabel = [UILabel autolayoutView];
        [_timerLabel setTextColor:[UIColor prepHeroYellowColor]];
        [_timerLabel setTextAlignment:NSTextAlignmentRight];
        [_timerLabel setText:@"Timer: 00:00:00"];
        
        [_zoomcontrolLabel setTextColor:[UIColor prepHeroYellowColor]];
        [_zoomcontrolLabel setTextAlignment:NSTextAlignmentRight];
        [_zoomcontrolLabel setText:@"Zoom Control: Default"];
        
        [_extraOutputLabel setTextColor:[UIColor prepHeroYellowColor]];
        [_extraOutputLabel setTextAlignment:NSTextAlignmentRight];
        [_extraOutputLabel setText:@"Extra: None"];
        
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
        [self addSubview:_timerLabel];
        [self addSubview:_zoomcontrolLabel];
        [self addSubview:_extraOutputLabel];
        
        // Layout format
        [self autolayout];
        
    }
    return self;
}

- (void)autolayout
{

    NSDictionary *views = NSDictionaryOfVariableBindings(_timerLabel, _zoomcontrolLabel, _extraOutputLabel);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_timerLabel]-(>=10)-|" options: 0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_zoomcontrolLabel]-(>=10)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_extraOutputLabel]-(>=10)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=1,<=5)-[_timerLabel]-(3)-[_zoomcontrolLabel]-(3)-[_extraOutputLabel]-(>=1)-|" options:0 metrics:nil views:views]];
    
}



@end
