//
//  AppDelegate.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionController.h"
//#import "GADInterstitial.h"
#import <GoogleMobileAds/GADInterstitial.h>
//#import <ChartboostSDK/Chartboost.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GADInterstitialDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SessionController* sessionController;

-(void)setLoginViewModal:(BOOL)modal;

-(void)displayAdMobInViewController:(UIViewController*)controller;

@end
