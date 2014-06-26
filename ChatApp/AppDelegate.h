//
//  AppDelegate.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionController.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SessionController* sessionController;

/**
 *  Location Manager for MilleniaMedia Ads
 */
@property (strong, nonatomic) CLLocationManager* locationManager;

-(void)setLoginView;

-(void)displayMillenialAdInViewController:(UIViewController*)controller;

@end
