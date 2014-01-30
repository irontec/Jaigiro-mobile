//
//  AppDelegate.m
//  jaigiro
//
//  Created by Asier Fernandez on 02/10/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "Login.h"
#import "AFNetworking.h"
#import <BugSense-iOS/BugSenseController.h>

#define appStoreUrl @"https://itunes.apple.com/us/app/jaigiro/id808070360?l=es&ls=1&mt=8"



@implementation AppDelegate
{
    BOOL firstLaunch;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"API_FOR_BUGSENSE"];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    } else {
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
    }
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //Manage de notifications
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
		}
	}
    
    firstLaunch = YES;
    return YES;
}

- (void) loadFirstController
{
    firstLaunch = NO;
    AppDelegate *appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *UUID = [prefs stringForKey:@"uuid"];
    NSString *first = [prefs stringForKey:@"firstBoot"];
    if(UUID.length>0 && first.length>0){
        [appDelegate loadMainController];
    }else{
        [appDelegate loadLoginController];
    }
}

- (void) setFirstLaunch:(BOOL) state
{
    firstLaunch = state;
}

#pragma mark PUSH notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)newDeviceToken
{
    NSString* deviceToken = [[[[newDeviceToken description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"%@",deviceToken);
    
    NSLog(@"My token is: %@", deviceToken);
    [Login setID:deviceToken];
   [self loadFirstController];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    
    NSString *NO_PUSH_CHAR = @"-";
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *finalUUID = [NSString stringWithFormat:@"%@%@",NO_PUSH_CHAR, UUID];
    [Login setID:finalUUID];
    NSLog(@"%@",finalUUID);
  [self loadFirstController];

}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    
    if (application.applicationState == UIApplicationStateActive ) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:5];
        localNotification.userInfo = userInfo;
        localNotification.alertBody = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
        NSLog(@"%@",localNotification.alertBody);
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Jaia abisua!"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Itxi", nil];
    [alert show];
}



#pragma mark facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // add app-specific handling code here
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadLoginController
{
    LoginViewController *mainViewController = [[LoginViewController alloc] init];
    self.window.rootViewController = mainViewController;
}

- (void)loadMainController
{
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = mainViewController;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:@"nofirst" forKey:@"firstBoot"];
    [prefs synchronize];
}


@end
