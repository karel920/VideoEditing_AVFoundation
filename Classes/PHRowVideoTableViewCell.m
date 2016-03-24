//
//  PHRowVideoTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/10/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHRowVideoTableViewCell.h"
#import "PHClipEditerViewController.h"
#import "PHClipViewController.h"
#import "PHClipVideoInfo.h"


@implementation PHRowVideoTableViewCell

- (void)awakeFromNib {
    
    UIImage *editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepheroGreenColor]
                                                          cornerRadius:5.0f
                                                           shadowColor:[UIColor prepheroGreenColor]
                                                          shadowInsets:UIEdgeInsetsZero];
    
    UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor blackColor]
                                                                cornerRadius:5.0f
                                                                 shadowColor:[UIColor blackColor]
                                                                shadowInsets:UIEdgeInsetsZero];
    
    UIImage *deleteButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepheroRedColor]
                                                            cornerRadius:5.0f
                                                             shadowColor:[UIColor prepheroRedColor]
                                                            shadowInsets:UIEdgeInsetsZero];
    
    UIImage *deleteButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor prepheroRedColor]
                                                                  cornerRadius:5.0f
                                                                   shadowColor:[UIColor prepheroRedColor]
                                                                  shadowInsets:UIEdgeInsetsZero];
    
    [_btnEdit setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnEdit setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnEdit setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateDisabled];
    
    [_btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [_btnDelete setBackgroundImage:deleteButtonBackgroundImage forState:UIControlStateNormal];
    [_btnDelete setBackgroundImage:deleteButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnDelete setBackgroundImage:deleteButtonActiveBackgroundImage forState:UIControlStateDisabled];
    
    [_btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
