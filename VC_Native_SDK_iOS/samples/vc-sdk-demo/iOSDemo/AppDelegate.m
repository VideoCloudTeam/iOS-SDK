//
//  AppDelegate.m
//  iOSDemo
//
//  Created by mac on 2019/6/26.
//  Copyright © 2019 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BaseNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    BaseNavigationController *navi = [[BaseNavigationController alloc]initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navi;
    NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
    //初始化会议状态
    [userDefault setObject:@"outmeeting" forKey:kScreenRecordMeetingState];
    //初始化屏幕录制状态
    [userDefault setObject:@"applaunch" forKey:kScreenRecordState];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //APP杀进程时,记录此时会议状态 和 屏幕录制状态
    NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
    [userDefault setObject:@"outmeeting" forKey:kScreenRecordMeetingState];
    [userDefault setObject:@"appfinsh" forKey:kScreenRecordState];
}


@end
