//
//  AppDelegate.m
//  Magician
//
//  Created by Drew Fitzpatrick on 1/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "AppDelegate.h"
#import "MagicPacketSender.h"
#import "MACAddressManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    UIBackgroundTaskIdentifier watchkitBackgroundID;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        watchkitBackgroundID = 0;
    }
    return self;
}

-(void) registerNotifications:(UIApplication*)app {
    UIMutableUserNotificationAction* bootAction = [[UIMutableUserNotificationAction alloc] init];
    [bootAction setIdentifier:@"bootAction"];
    [bootAction setActivationMode:UIUserNotificationActivationModeBackground];
    [bootAction setTitle:@"Boot All"];
    
    UIMutableUserNotificationAction* snoozeAction = [[UIMutableUserNotificationAction alloc] init];
    [snoozeAction setIdentifier:@"snoozeAction"];
    [snoozeAction setActivationMode:UIUserNotificationActivationModeBackground];
    [snoozeAction setTitle:@"Snooze"];
    
    UIMutableUserNotificationCategory* category = [[UIMutableUserNotificationCategory alloc] init];
    [category setIdentifier:@"BootNetwork"];
    [category setActions:@[bootAction, snoozeAction] forContext:UIUserNotificationActionContextDefault];
    
    NSSet* categorySet = [NSSet setWithArray:@[category]];
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:categorySet];
    [app registerUserNotificationSettings:notificationSettings];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"launch options: %@", launchOptions);
    
    [self registerNotifications:application];
    
    [[MACAddressManager sharedManager] loadFromArchive];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    NSString* requestType = identifier;
    if ([requestType isEqualToString:@"bootAction"]) {
        [MagicPacketSender sendAll];
        
    } else if ([requestType isEqualToString:@"snoozeAction"]) {
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        notification.alertTitle = @"Title";
        notification.alertBody = @"Body";
//        NSTimeInterval interval = 60 * 10; // 60 seconds per minute * 10 minutes
        NSTimeInterval interval = 6; // test: 6 seconds
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        notification.category = @"BootNetwork";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    completionHandler();
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    completionHandler();
}

-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    watchkitBackgroundID = [application beginBackgroundTaskWithName:@"Watchkit Extension Request Task"
                                                  expirationHandler:^{
        reply(@{@"success": @NO});
        [application endBackgroundTask:watchkitBackgroundID];
    }];
    
//    [[MACAddressManager sharedManager] loadFromArchive];
    NSLog(@"%@", [[MACAddressManager sharedManager] getAll]);
    
    NSString* requestType = [userInfo valueForKey:@"requestType"];
    if ([requestType isEqualToString:@"bootAll"]) {
//        BOOL success = YES;
        BOOL success = [MagicPacketSender sendAll];
        
        reply(@{@"success" : [NSNumber numberWithBool:success]});
        
        
    } else if ([requestType isEqualToString:@"snooze"]) {
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        notification.alertTitle = @"Title";
        notification.alertBody = @"Body";
        NSTimeInterval interval = 60 * 10; // 60 seconds per minute * 10 minutes
//        NSTimeInterval interval = 6; // test: 6 seconds
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        notification.category = @"BootNetwork";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        reply(@{@"success": @YES});
    }
    
    [application endBackgroundTask:watchkitBackgroundID];
}

@end
