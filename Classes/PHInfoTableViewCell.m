//
//  PHInfoTableViewCell.m
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHInfoTableViewCell.h"

@implementation PHInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _txtVideoName.delegate = self;
    _txtVideoName.backgroundColor = [UIColor prepheroGrayColor];
    _txtVideoName.tintColor = [UIColor prepHeroYellowColor];
    _txtVideoName.textColor = [UIColor prepHeroYellowColor];
    
    _txtVideoDescription.delegate = self;
    _txtVideoDescription.backgroundColor = [UIColor prepheroGrayColor];
    _txtVideoDescription.tintColor = [UIColor prepHeroYellowColor];
    _txtVideoDescription.textColor = [UIColor prepHeroYellowColor];
    _txtVideoDescription.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text  isEqual: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
}

@end
