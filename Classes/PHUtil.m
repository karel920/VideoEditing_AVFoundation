//
//  PHUtil.m
//  PrepHero
//
//  Created by Xinjiang Shao on 7/17/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHUtil.h"

@implementation PHUtil


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static PHUtil *_sharedClient = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[[self class] alloc] init];
    });
    
    return _sharedClient;
}

- (NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSString *) getVersion
{
   NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ build %@", version, build];
    
}
@end
