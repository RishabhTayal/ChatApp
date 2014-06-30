//
//  AppDelegate.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NearChatViewController.h"
#import "FriendsChatViewController.h"
#import <MFSideMenu/MFSideMenu.h>
#import "IntroViewController.h"
#import <Parse/Parse.h>
#import "MenuViewController.h"
#import <iRate/iRate.h>
#import "SessionController.h"
#import "InAppNotificationTapListener.h"
#import "InAppNotificationView.h"

@interface AppDelegate()

@property (strong) GADInterstitial* interstitial;
@property (strong) UIViewController* adPresentingVC;

@end

@implementation AppDelegate

+(void)initialize
{
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    [iRate sharedInstance].eventsUntilPrompt = 5;
    
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].remindPeriod = 0;
    [iRate sharedInstance].previewMode = NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].trackUncaughtExceptions = !DEBUGMODE;
    
    [GAI sharedInstance].dispatchInterval = 20;
    
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-40631521-4"];
    
    //Use Development DB on Parse for Development mode.
    if (DEBUGMODE) {
        [Parse setApplicationId:@"WDzqlRDNdilFgPoLusTBKgmeY0FyFaHr6tCFvmgf" clientKey:@"MvV94eU6Z9r3GlrAEfNIhQsM00jDVWh076jKiUJ7"];
    } else {
        [Parse setApplicationId:@"BX9jJzuoXisUl4Jo0SfRWMBgo3SkR4aiUimg604X" clientKey:@"zx7SL9h2j97fSmlRdK23XLhpEdeqmrtr24jPawpm"];
    }
    
    [PFFacebookUtils initializeFacebook];
    
    if (!DEBUGMODE) {
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    //Don't add [[uiview apperance].tintcolor
    [UINavigationBar appearance].barTintColor = [UIColor redColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDInAppVibrate];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDInAppSound];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserLoggedIn] boolValue] && [PFUser currentUser][kPFUser_Name]) {
        [self setMainView];
    } else {
        [self setLoginView];
    }
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"VCinityModel"];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation* currentInstallation  = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setChannels:@[@"channel"]];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            DLog(@"Push Registration Error: %@", error);
            [GAI trackEventWithCategory:@"pf_installation" action:@"registration_error" label:error.description value:nil];
        }
    }];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (userInfo[kNotificationPayload]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil userInfo:userInfo];
        
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            [PFPush handlePush:userInfo];
            [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
        } else {
            [[InAppNotificationTapListener sharedInAppNotificationTapListener] startObserving];
            UIViewController* currentVC = ((UINavigationController*)((MFSideMenuContainerViewController*)self.window.rootViewController).centerViewController).visibleViewController;
            if (! [currentVC isKindOfClass:[FriendsChatViewController class]]) {
                
                if (userInfo[kNotificationSender]) {
                    [[InAppNotificationView sharedInstance] notifyWithUserInfo:userInfo andTouchBlock:^(InAppNotificationView *view) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationTapped" object:nil userInfo:userInfo];
                    }];
                }
            }
        }
    } else {
        [PFPush handlePush:userInfo];
    }
}

-(void)setLoginView
{
    NSArray* infoArray = @[@{@"Header": @"Hanging out with Friends", @"Label": @"Chat with your Facebook Friends when Internet available."}, @{@"Header": @"Camping with Family/Friends?", @"Label": @"Chat with nearby people even when Internet is not available."}, @{@"Header": @"Take it to the beach", @"Label": @"Make new friends at the beach."}, @{@"Header": @"Attending a Concert or a Game?", @"Label":@"Share your thoughts with others."}, @{@"Header":@"Going to a Conference?", @"Label":@"Connect with other people seemlessly."}];
    
    IntroViewController* intro = [[IntroViewController alloc] initWithBackgroundImages:@[@"Intro-bg", @"Intro-bg", @"Intro-bg", @"Intro-bg", @"Intro-bg"] andInformations:infoArray];
    
    [intro setHeaderImage:[UIImage imageNamed:@"logo"]];
    [intro setButtons:AOTutorialButtonLogin];
    
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [intro setLoginButton:loginButton];
    intro.loginButton.layer.cornerRadius = 10;
    
    self.window.rootViewController = intro;
    [self.window makeKeyAndVisible];
}

-(void)setMainView
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    MenuViewController* menuVC = [[MenuViewController alloc] init];
    MFSideMenuContainerViewController* vc = [MFSideMenuContainerViewController containerWithCenterViewController:nil leftMenuViewController:[[UINavigationController alloc] initWithRootViewController:menuVC] rightMenuViewController:nil];
    vc.menuSlideAnimationEnabled = YES;
    [menuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [menuVC tableView:menuVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    
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
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Register App Install on Facebook Ads Manager
    [FBAppEvents activateApp];
    
    [self updateInstallation];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)updateInstallation
{
    PFInstallation* currentInstallation  = [PFInstallation currentInstallation];
    //    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setChannels:@[@"channel"]];
    [currentInstallation saveInBackground];
}

-(void)displayAdMobInViewController:(UIViewController*)controller
{
    if ([self shouldDisplayAd]) {
        _interstitial = [[GADInterstitial alloc] init];
        _interstitial.delegate = self;
        
        _interstitial.adUnitID = kGADAdUnitId;
        [_interstitial loadRequest:[self request]];
        
        _adPresentingVC = controller;
    }
}

-(BOOL)shouldDisplayAd
{
    NSDate* lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUDAdLastShownAdMob];
    if (!lastDate) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUDAdLastShownAdMob];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastDate];
        int hours = (int)interval/3600;
        int minutes = (interval - (hours*3600)) / 60;
        DLog(@"Ad - Minutes since last shown: %d", minutes);
        if (minutes >= 2) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUDAdLastShownAdMob];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
    return NO;
}

#pragma mark - GADRequest implementation

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    request.testDevices = @[
                            // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
                            // the console when the app is launched.
                            GAD_SIMULATOR_ID,
                            @"4a4d13e777b61b0f28cb678991220815"
                            ];
    return request;
}

-(void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    DLog(@"Google Ads recieved");
    DLog(@"Presenting on VC: %@", self.window.rootViewController);

    [_interstitial presentFromRootViewController:self.window.rootViewController];
}

@end
