//
//  AppDelegate.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MPNotificationView.h>
#import "SessionController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MPNotificationViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)SessionController* sessionController;

-(void)setLoginView;

@end
