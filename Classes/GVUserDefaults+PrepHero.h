//
//  GVUserDefaults+PrepHero.h
//  PrepHero
//
//  Created by Xinjiang Shao on 9/18/15.
//  Copyright © 2015 PrepHero, Inc. All rights reserved.
//
#import <GVUserDefaults.h>
#import <Foundation/Foundation.h>

@interface GVUserDefaults (PrepHero)

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *gradyear;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic) BOOL showTutorial;
@property (nonatomic) BOOL loggedIn;

@end
