//
//  AppDelegate.m
//  PageViewWithHeader
//
//  Created by PudgeMa on 2020/2/6.
//  Copyright © 2020 PudgeMa. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window = window;
    window.rootViewController = [ViewController new];
    [window makeKeyAndVisible];
    return YES;
}

@end
