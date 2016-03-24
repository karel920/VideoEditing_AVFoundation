//
//  PHPageViewController.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/19/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHPageViewController.h"
#import "UIColor+Helper.h"
#import "UIVIew+Helper.h"
#import "UIImage+Helper.h"
#import <pop/POP.h>

@interface PHPageViewController ()
@property (nonatomic, strong) UILabel *screenLabel;
@property (nonatomic, strong) UIButton *startNowButton;
@end

@implementation PHPageViewController
- (instancetype)initWithIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        self.index = index;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _screenLabel = [UILabel autolayoutView];
   
    _screenLabel.text =  [NSString stringWithFormat:@"Screen #%ld", (long)self.index+1];
    [_screenLabel setTextColor:[UIColor prepHeroYellowColor]];
    
    
   // NSLog(@"Screen #%ld", (long)self.index+1);
    [self.view addSubview:_screenLabel];
    
    
    // Start Using Now
    _startNowButton = [UIButton autolayoutView];

    UIImage *normalBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor] cornerRadius:10.0f shadowColor:[UIColor blackColor] shadowInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_startNowButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [_startNowButton setTitle:@"Let's Get Started" forState:UIControlStateNormal];
    [_startNowButton addTarget:self action:@selector(dismissJoyRide) forControlEvents:UIControlEventTouchDown];

//    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
//    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    anim.fromValue = @(0.0);
//    anim.toValue = @(1.0);
//   
//    [_startNowButton pop_addAnimation:anim forKey:@"fade"];

    [self.view addSubview:_startNowButton];
    
    _startNowButton.hidden = YES;
    if (self.index == 2) {
        _startNowButton.hidden = NO;
    }
    
}
- (void)dismissJoyRide {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        // Set Tutorial to false
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"ShowTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSNumber *showTutorialOnLaunch =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowTutorial"];
        NSLog(@"End of Tutor Tutorial: %@", showTutorialOnLaunch);
                
    }];
    

}

- (void) viewWillLayoutSubviews {
    // Give auto layout here
    NSDictionary *views = NSDictionaryOfVariableBindings(_startNowButton, _screenLabel);
    

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_screenLabel]-(10)-|" options: 0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_startNowButton]-(10)-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_screenLabel]-(5)-[_startNowButton(50)]|" options:0 metrics:nil views:views]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
