//
//  AppDelegate.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Spotify/Spotify.h>
#import "MoodViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // set the api_host
    [[NSUserDefaults standardUserDefaults] setValue:@"http://127.0.0.1:8000/api/" forKey:@"api_host"];
    // set the spotify client ID
    [[NSUserDefaults standardUserDefaults] setValue:@"be36ff5a78084c0c8c8af109cdbb284a" forKey:@"spotify_client_id"];
    [[NSUserDefaults standardUserDefaults] setValue:@"sunny-rainy-app-login://callback" forKey:@"spotify_client_callback"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
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
    // Trigger MoodViewController viewDidAppear
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    
    // Call the -loginUsingSession: method to login SDK
    UINavigationController *naviController = [[((UINavigationController *) self.window.rootViewController) viewControllers] objectAtIndex:0];
    MoodViewController *rootViewController = (MoodViewController*) naviController.visibleViewController;
    if([rootViewController respondsToSelector:@selector(toggleButtons)]) {
        [rootViewController toggleButtons];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"Spotify Auth error: %@", error);
                return;
            }
            
            // Call the -loginUsingSession: method to login SDK
            UINavigationController *naviController = [[((UINavigationController *) self.window.rootViewController) viewControllers] objectAtIndex:0];
            MoodViewController *rootViewController = (MoodViewController*) naviController.visibleViewController;
            [rootViewController loginUsingSession:session];
        }];
        return YES;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
