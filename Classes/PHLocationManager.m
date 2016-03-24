//
//  PHLocationManager.m
//  PrepHero
//
//  Created by Xinjiang Shao on 7/14/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHLocationManager.h"

@implementation PHLocationManager

+ (instancetype)sharedLocationManager {
   
    static PHLocationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.delegate = self;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
                [_locationManager requestWhenInUseAuthorization];
            }
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
        }
        
    }
    return self;
}
- (BOOL)startLocationUpdates {
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        return YES;
    }else{
        return NO;
    }
}

- (void)stopLocationUpdates {
    
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
    
}
- (BOOL)isAuthorized {
    BOOL authorized = NO;
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
            {
                
                break;
            }
            case kCLAuthorizationStatusNotDetermined:
            {
                
                break;
            }
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusAuthorizedAlways:
            {
                authorized = YES;
                break;
            }
            default:
                break;
        }
    }
        
    return authorized;
}

#pragma mark - 🔌 CLLocationManagerDelegate Method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //get didUpdateCoordinate
    _currentLocation = [locations objectAtIndex:0];
    
    //NSLog(@"Location: %@", loc);
}


- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error {
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            NSLog(@"Location Service Denied");
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}

@end
