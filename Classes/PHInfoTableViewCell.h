//
//  PHInfoTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/26/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHInfoTableViewCell : UITableViewCell<UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtVideoName;
@property (strong, nonatomic) IBOutlet UITextView *txtVideoDescription;

@end
