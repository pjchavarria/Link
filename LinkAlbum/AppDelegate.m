//
//  AppDelegate.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "AppDelegate.h"
#import "YoutubeAPIClient.h"
#import "SVWebViewController.h"
#import "LinkAPIClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[LinkAPIClient client] tokenWithRequest:^(NSURLSessionDataTask *task, id responseObject) {
        // Save access token
        [[LinkAPIClient client].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",responseObject[@"accessToken"]] forHTTPHeaderField:@"Authorization"];
    } error:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    [self personalizeAppearance];
   
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


#pragma mark -
#pragma mark WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *url = request.URL;
    if ((url.pathComponents.count<=1)) {
        if ([url.absoluteString containsString:@"http://localhost"]) {
            
            NSString *code = [url.absoluteString componentsSeparatedByString:@"="][1];            
            
            [[YoutubeAPIClient client] tokenWithCode:code success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSString *accessToken = responseObject[@"access_token"];
                NSString *refreshToken = responseObject[@"refresh_token"];
                
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"youtubeAccessToken"];
                [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:@"youtubeRefreshToken"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[YoutubeAPIClient client].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
                
            } error:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"%@",error);
            }];
            
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    
    return YES;
}

- (void)personalizeAppearance
{
    UIColor *color = [UIColor colorWithRed:68/255.0 green:74/255.0 blue:249/255.0 alpha:0.9];
    [[UINavigationBar appearance] setBarTintColor:color];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      nil]];
    
    [[UISearchBar appearance] setBackgroundImage:[UIImage new]];
    
    UIColor *color2 = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:255/255.0 alpha:0.9];
    [[UITabBar appearance] setBarTintColor:color2];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      nil] forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      nil] forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

@end
