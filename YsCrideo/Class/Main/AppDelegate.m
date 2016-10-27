//
//  AppDelegate.m
//  YsCrideo
//
//  Created by weiying on 16/10/26.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "AppDelegate.h"
#import "SDWebImageManager.h"
#import "LeanCloudTool.h"
#import "HomeController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //leancloud
    [[LeanCloudTool shareInstance] setupLeanCloudWithOptions:launchOptions];
    
    //rootController
    HomeController *homeVC = [[HomeController alloc] init];
    self.window.rootViewController = homeVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DLog(@"收到内存警告");
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDImageCache sharedImageCache] clearDisk];
}

@end
