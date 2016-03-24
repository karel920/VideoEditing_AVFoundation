//
//  VideoTransformationPolicy.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/16/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "VideoTransformationPolicy.h"

@implementation VideoTransformationPolicy
- (NSNumber *) convertUidType: (NSString *) uidString
{
    return [NSNumber numberWithInteger:[uidString integerValue]];
}
@end
