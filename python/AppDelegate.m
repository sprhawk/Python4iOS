//
//  AppDelegate.m
//  python
//
//  Created by YANG HONGBO on 2013-7-18.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "AppDelegate.h"

#import <Python.h>

static void test_python();

void test_python()
{
    NSString * name = [[NSBundle mainBundle] bundleIdentifier];
    Py_SetProgramName((char *)[name cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString * rootPath = [[NSBundle mainBundle] resourcePath];
    Py_SetPythonHome((char *)[rootPath cStringUsingEncoding:NSUTF8StringEncoding]);
//    char * p = Py_GetPath();
//    NSLog(@"PythonPath:%s", p);
    Py_OptimizeFlag = 1;
    Py_Initialize();
    PyRun_SimpleString("import sys\n"
                       "import uuid\n"
                       "import email\n"
                       "print('test')");
    Py_Finalize();
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    test_python();
    
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
