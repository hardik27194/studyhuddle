//
//  SHAppDelegate.m
//  Study Huddle
//
//  Created by Jason Dimitriou on 6/8/14.
//  Copyright (c) 2014 StudyHuddle. All rights reserved.
//

#import "SHAppDelegate.h"
#import <Parse/Parse.h>
#import "SHStartUpViewController.h"
#import "Student.h"
#import "UIColor+HuddleColors.h"
#import "SHVisitorProfileViewController.h"
#import "SHLoginViewController.h"
#import "SHConstants.h"
#import "SHProfileViewController.h"
#import "SHSearchViewController.h"
#import "SHTutorialIntro.h"
#import "MBProgressHUD.h"
#import "SHCache.h"


@interface SHAppDelegate()

@property SHStartUpViewController* startUpViewController;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setupAppearance];
    
    [self setupParseWithOptions:launchOptions];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    
    self.isRunMoreThanOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRunMoreThanOnce"];
    if(!self.isRunMoreThanOnce){
        // Show the alert view
        // Then set the first run flag
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isRunMoreThanOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //at first only setup the startupcontroller. Once the user is loged in, we will instantiate all other classes that will go in the tab bar controller
    
    self.startUpViewController = [[SHStartUpViewController alloc]init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.startUpViewController];
    //self.navController.navigationBar.barTintColor = [UIColor huddleOrange];
    //[self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    if(![PFUser currentUser])
    {
        //show the tutorial thingy
        self.window.rootViewController = [[SHTutorialIntro alloc]init];
    }
    else
    {
        //do regular login
        [[Student currentUser] refreshInBackgroundWithTarget:self selector:nil];
        self.window.rootViewController = self.navController;
    }
    
    
    self.window.backgroundColor = [UIColor clearColor];
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}


#pragma mark - AppDelegate

/*
- (void)presentProfileViewController
{
    self.profileController = [[SHProfileViewController alloc]init];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.profileController];
    
    profileNavigationController.navigationBar.barTintColor = [UIColor redColor];
    [profileNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UITabBarController *tabBar = [[UITabBarController alloc]init];
    
    tabBar.viewControllers = @[profileNavigationController];

    [self.navController setViewControllers:@[tabBar] animated:NO];
}*/

- (void)presentProfileViewController
{
    self.profileController = [[SHProfileViewController alloc]init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:self.profileController];
    self.navController.navigationBar.barTintColor = [UIColor huddleOrange];
    [self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.window.rootViewController = self.navController;
    
    
}

-(void) doLogin
{
    [self instantiateViews];
    self.tabBarController = [[UITabBarController alloc]init];
    [[UITabBar appearance] setTintColor:[UIColor huddleOrange]];
    
    [self.profileController setStudent:(Student *)[Student currentUser]];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:self.profileNavigator, self.huddlesNavigator,self.searchNavigator,self.notificationNavigator ,nil];
    
    
    self.window.rootViewController = self.tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
}


- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    SHLoginViewController *loginViewController = [[SHLoginViewController alloc] init];
    
    [self.startUpViewController presentViewController:loginViewController animated:animated completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

-(void)logout
{
    [[SHCache sharedCache]clear];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SHUserDefaultsUserHuddlesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SHUserDefaultsUserClassesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SHUserDefaultsUserStudyFriendsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //[[PFInstallation currentInstallation] removeObjectForKey:]
    //[[PFInstallation currentInstallation] saveInBackground];
    
    [PFQuery clearAllCachedResults];

    
    [PFUser logOut];
    //self.startUpViewController = [[SHStartUpViewController alloc]init];
    //self.navController = [[UINavigationController alloc] initWithRootViewController:self.startUpViewController];
    //self.navController.navigationBar.barTintColor = [UIColor huddleOrange];
    //[self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  
    //self.window.rootViewController = self.navController;

    self.window.rootViewController = [[SHTutorialIntro alloc]init];
    self.window.backgroundColor = [UIColor clearColor];
}

-(void)instantiateViews
{

    //profile
    self.profileController = [[SHProfileViewController alloc]init];
    self.profileNavigator = [[UINavigationController alloc] initWithRootViewController:self.profileController];
    self.profileNavigator.navigationBar.barTintColor = [UIColor huddleOrange];
    [self.profileNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //huddles
    self.huddlesController = [[SHHuddleViewController alloc]init];
    self.huddlesNavigator = [[UINavigationController alloc] initWithRootViewController:self.huddlesController];
    self.huddlesNavigator.navigationBar.barTintColor = [UIColor huddleOrange];
    [self.huddlesNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.searchController = [[SHSearchViewController alloc]init]; //temporary for testing purposes
    self.searchNavigator = [[UINavigationController alloc] initWithRootViewController:self.searchController];
    self.searchNavigator.navigationBar.barTintColor = [UIColor huddleOrange];
    [self.searchNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //notification
    self.notificationController = [[SHNotificationViewController alloc]initWithStudent:(Student*)[PFUser currentUser]]; 
    self.notificationNavigator = [[UINavigationController alloc] initWithRootViewController:self.notificationController];
    self.notificationNavigator.navigationBar.barTintColor = [UIColor huddleOrange];
    [self.notificationNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    


}

#pragma mark - ()

- (void)setupParseWithOptions:(NSDictionary *)launchOptions
{
    [Student registerSubclass];
    
    [Parse setApplicationId:@"tYVLuBAkB3oeGEo8dQa0mQdW8AfyppZHI92DKvTk"
                  clientKey:@"BZ4boxrBIGK0dJKV47r7hVJ4D4C9bSensOhR46kN"];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //    PFACL *defaultACL = [PFACL ACL];
    //    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    //    [defaultACL setPublicReadAccess:YES];
    //    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

//Setup up all Study Huddle custom Appearance attributes
- (void)setupAppearance
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor huddleOrange]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                                forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
}

@end
