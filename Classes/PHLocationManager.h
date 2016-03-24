//
//  PHLocationManager.h
//  PrepHero
//
//  Created by Xinjiang Shao on 7/14/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PHLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (instancetype)sharedLocationManager;
- (BOOL)startLocationUpdates;
- (void)stopLocationUpdates;
- (BOOL)isAuthorized;
@end
