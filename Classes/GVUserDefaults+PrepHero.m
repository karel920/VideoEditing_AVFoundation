//
//  GVUserDefaults+PrepHero.m
//  PrepHero
//
//  Created by Xinjiang Shao on 9/18/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//

#import "GVUserDefaults+PrepHero.h"

@implementation GVUserDefaults (PrepHero)
@dynamic email;
@dynamic showTutorial;
@dynamic uname;
@dynamic uid;
@dynamic loggedIn;
@dynamic firstname;
@dynamic lastname;
@dynamic gradyear;
@dynamic phone;
@dynamic gender;
@dynamic profileImageURL;
- (NSDictionary *)setupDefaults {
    return @{
             @"uname": @"Guest",
             @"uid": @1,
             @"showTutorial": @YES,
             @"loggedIn": @NO
             };
}

- (NSString *)suitName {
    return @"com.prephero.iOS";
}
@end
