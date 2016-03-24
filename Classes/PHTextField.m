//
//  PHTextField.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/18/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "PHTextField.h"

@implementation PHTextField

// Ref: http://stackoverflow.com/questions/2694411/text-inset-for-uitextfield
// placeholder position override
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds , 10, 10);
}

// text position override
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds , 10, 10);
}

@end
