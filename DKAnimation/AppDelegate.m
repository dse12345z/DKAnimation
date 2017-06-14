//
//  AppDelegate.m
//  DKAnimation
//
//  Created by daisuke on 2017/3/17.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navigationControlelr = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navigationControlelr;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
