//
//  PHVideosEditTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/23/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideosEditTableViewCell.h"

@implementation PHVideosEditTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _buttonView.layer.cornerRadius = 5.0f;
    _btnEdit.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnEdit.layer.borderWidth = 1;
    _btnEdit.layer.cornerRadius = 5.0f;
    _btnDelete.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnDelete.layer.borderWidth = 1;
    _btnDelete.layer.cornerRadius = 5.0f;
    _btnPositionUp.layer.cornerRadius = 5.0f;
    _btnPositionDown.layer.cornerRadius = 5.0f;
    _videoData = [[NSManagedObject alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
