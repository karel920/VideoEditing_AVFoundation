//
//  AppDelegate.m
//  PrepHero
//
//  Created by Xinjiang Shao on 6/12/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//


#import "AppDelegate.h"
#import "UIColor+Helper.h"
#import "UINavigationController+StatusBarStyle.h"
#import "PHCaptureViewController.h"
#import "PHSettingsViewController.h"
#import "PHMainTabBarController.h"
#import "PHTutorialViewController.h"
#import "PHApiClient.h"
#import "GVUserDefaults+PrepHero.h"
#import "LogInViewController.h"
#import "PHForcedOrientationNavController.h"
#import "PHVideoSegmentsViewController.h"
#import "PHClipViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AFNetworkActivityIndicatorManager.h>
#import <SafariServices/SafariServices.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[NewRelicAgent startWithApplicationToken:@"AA7b290b3ff4c3785f88e0c402283893733c1c5dc1"];
    [[Twitter sharedInstance] startWithConsumerKey:@"XJuwQewYB4mr4Bo8Z3DN40jsY" consumerSecret:@"DumsqXHUfJqfSp6fuWG1kIPzqEgHIcTj9hJf8zhiQEtCmagsHH"];

    [Fabric with:@[CrashlyticsKit, DigitsKit, [Twitter sharedInstance]]];
    

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Parse setApplicationId:@"B3dpNmcvw8jfeKYZ2L8yWpX5I62oJa02vd6KZ4rF" clientKey:@"oroIq3UHQggIaxrqca9B8zHJJBCx3mdwSvWEoJz2"];
    
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced in iOS 7).
        // In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    // Custimize Gloabl UI
    [[UINavigationBar appearance] setBarTintColor:[UIColor prepHeroBlueColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
   
    // Set HUD Color Globally
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    // Detect Network Activity By Default and Cache for URLs for bad connection
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    // Check if API endpoints are available now
    [[PHApiClient sharedClient] isApiServerAvailable];
    
    // register notifications for login and logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeApplication:)
                                                 name:PHUserLoggedInSuccessfulNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeApplication:)
                                                 name:PHUserLoggedOutNotification
                                               object:nil];
    NSLog(@"LoggedIn Status : %@", [GVUserDefaults standardUserDefaults].loggedIn  ? @"YES": @"NO");
    if(![GVUserDefaults standardUserDefaults].loggedIn)
    {   // If user is not logged in, assign root view controller to be login
        [self routeToMainView];
    }else{
        
        [self routeToMainView];
    }
    [self.window makeKeyAndVisible];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark Route App
- (void)routeApplication:(NSNotification *)notification
{
    if ([notification.name isEqualToString:PHUserLoggedInSuccessfulNotification]) {
        //[PFUser logOut];
        [self routeToMainView];
    } else if ([notification.name isEqualToString:PHUserLoggedOutNotification]) {
        [self routeToLogin];
    }

}

- (void)routeToMainView
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    //installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    NSMutableArray *listOfViewControllers = [[NSMutableArray alloc] init];
    
    PHVideoSegmentsViewController *highlightvc = [[PHVideoSegmentsViewController alloc] init];
    highlightvc.title = NSLocalizedString(@"Highlight Video", nil);
    UIImage *starButton = [UIImage imageNamed:@"star-button"];
    highlightvc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Highlights" image:starButton tag:0];
   
    [listOfViewControllers addObject:[[PHForcedOrientationNavController alloc] initWithRootViewController:highlightvc]];
    
    PHCaptureViewController *capturevc = [[PHCaptureViewController alloc] init];
    capturevc.title = NSLocalizedString(@"Capture", nil);
    UIImage *captureButton = [UIImage imageNamed:@"capture-button"];
    capturevc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Capture" image:captureButton tag:1];
    
    [listOfViewControllers addObject:capturevc];
    
    PHSettingsViewController *settingsvc = [[PHSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsvc.title = NSLocalizedString(@"Settings", nil);
    settingsvc.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];
    
    [listOfViewControllers addObject:[[PHForcedOrientationNavController alloc] initWithRootViewController:settingsvc]];

    PHMainTabBarController *tabBarController = [[PHMainTabBarController alloc] init];
   
    tabBarController.viewControllers = listOfViewControllers;
    tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
   
    
    // Uncomment following line before release a new version
    tabBarController.selectedIndex = 1;
    
    [self.window setRootViewController:tabBarController];

}

- (void)routeToLogin
{
    LogInViewController *logInViewController = [[LogInViewController alloc] init];
    // Present the log in view controller
    [self.window setRootViewController:logInViewController];
    
}


#pragma mark Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"PrepHero successfully subscribed to push notifications on the broadcast channel.");
        } else {
            NSLog(@"PrepHero failed to subscribe to push notifications on the broadcast channel.");
        }
    }];
}

#pragma mark Facebook SDK Integration


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // ... other Parse setup logic here
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:[notification userInfo]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.prephero.PrepHero" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PrepHero" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PrepHero.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"com.prephero.PrepHero" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
