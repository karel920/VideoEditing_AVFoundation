//
//  PHVideoVideosTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideoVideosTableViewCell.h"
#import "PHVideoEditViewController.h"



@implementation PHVideoVideosTableViewCell

- (void)awakeFromNib {

    UIImage *buttonBackgroundImage = [UIImage buttonImageWithColor:[UIColor blackColor]
                                                      cornerRadius:3.0f
                                                       shadowColor:[UIColor blackColor]
                                                      shadowInsets:UIEdgeInsetsZero];
    
    UIImage *buttonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepHeroYellowColor]
                                                            cornerRadius:3.0f
                                                             shadowColor:[UIColor prepHeroYellowColor]
                                                            shadowInsets:UIEdgeInsetsZero];
    
    
     _btnFacebook.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:13];
    [_btnFacebook setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnFacebook setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnFacebook setTitleColor:[UIColor prepHeroYellowColor] forState:UIControlStateNormal];
    [_btnFacebook setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnFacebook setTitle:[NSString fontAwesomeIconStringForEnum:FAFacebook] forState:UIControlStateNormal];
    [_btnFacebook setTitle:[NSString fontAwesomeIconStringForEnum:FAFacebook] forState:UIControlStateHighlighted];
    
     _btnTwitter.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:13];
    [_btnTwitter setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnTwitter setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnTwitter setTitleColor:[UIColor prepHeroYellowColor] forState:UIControlStateNormal];
    [_btnTwitter setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnTwitter setTitle:[NSString fontAwesomeIconStringForEnum:FATwitter] forState:UIControlStateNormal];
    [_btnTwitter setTitle:[NSString fontAwesomeIconStringForEnum:FATwitter] forState:UIControlStateHighlighted];
   
    
    [_btnPreHero setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnPreHero setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnPreHero setTitleColor:[UIColor prepHeroYellowColor] forState:UIControlStateNormal];
    [_btnPreHero setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [_btnEdit setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [_btnEdit setBackgroundImage:buttonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnEdit setTitleColor:[UIColor prepHeroYellowColor] forState:UIControlStateNormal];
    [_btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnSharedClicked:(id)sender {
    NSLog(@"Tapped Shared Button");
}

- (IBAction)btnPreHeroClicked:(id)sender {
    NSLog(@"Tapped PrepHero");
}

@end
