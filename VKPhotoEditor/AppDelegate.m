//
//  AppDelegate.m
//  VKPhotoEditor
//
//  Created by asya on 9/21/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotosListController.h"
#import "StartViewController.h"
#import "InformationView.h"
#import "UIViewController+StatusBar.h"
#import "RepliesUpdateLoader.h"

@implementation AppDelegate {
    InformationView *informationView;
    RepliesUpdateLoader *repliesUpdateLoader;
}

@synthesize window, navigationController, connectionService, settings, imageCache;

+ (AppDelegate*)shared
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
    settings = [[Settings alloc] initWithDefaults:dict];
    connectionService = [[VKConnectionService alloc] initWithURL:settings.serviceRootURL];
    imageCache = [ImageCache new];
    
    repliesUpdateLoader = [RepliesUpdateLoader new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidFail:) name:VKRequestDidFailNotification object:connectionService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReplyUpdates) name:VKRequestDidLogin object:connectionService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopReplyUpdates) name:VKRequestDidLogout object:connectionService];
    
    if (connectionService.profile.accessToken) {
        [self startReplyUpdates];
    }
    
    self.navigationController.navigationBar.hidden = YES;
    navigationController.viewControllers = connectionService.profile.accessToken ? [NSArray arrayWithObjects: [StartViewController new], [PhotosListController new], nil] : [NSArray arrayWithObject:[StartViewController new]];
    
    informationView = [InformationView loadFromNIB];
    [self.window addSubview:informationView];
    [self.window bringSubviewToFront:informationView];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [settings setFirstLaunch:NO];
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

- (void)requestDidFail:(NSNotification*)n;
{
    NSError *error = [n.userInfo objectForKey:@"Error"];
    [informationView showMessage:error.localizedDescription];
}

- (void)startReplyUpdates
{
    [repliesUpdateLoader start];
}

- (void)stopReplyUpdates
{
    [repliesUpdateLoader stop];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController hideStatusBarIfNeed];
}

@end
