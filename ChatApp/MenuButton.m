//
//  MenuButton.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "MenuButton.h"
#import <MFSideMenu.h>
#import <BBBadgeBarButtonItem.h>
#import "MenuViewController.h"

@implementation MenuButton

+(id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        UIButton* barButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [barButton setBackgroundImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
        [barButton setFrame:CGRectMake(0, 0, 20, 20)];
        //        SEL selector  = sel_registerName("leftSideMenuButtonPressed:");
        _sharedObject = [[self alloc] initWithCustomUIButton:barButton];
        [barButton addTarget:_sharedObject action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_sharedObject setUI];
    });
    return _sharedObject;
}

-(void)setUI
{
    self.badgeBGColor = [UIColor whiteColor];
    self.badgeTextColor = [UIColor redColor];
    self.badgeValue = @"2";
}

-(void)leftSideMenuButtonPressed:(id)sender
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    MFSideMenuContainerViewController* side = (MFSideMenuContainerViewController*) window.rootViewController;
    [side.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

-(void)setBadgeNumber:(int)badge isNearBadge:(BOOL)nearBadge
{
    BBBadgeBarButtonItem* barButton = self;
    barButton.badgeValue = [NSString stringWithFormat:@"%d", badge];
    if (nearBadge) {
        [[NSUserDefaults standardUserDefaults] setObject:barButton.badgeValue forKey:kUDBadgeNumberNear];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:barButton.badgeValue forKey:kUDBadgeNumberFriends];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self postNotification];
}

-(void)resetBadgeNumber
{
    BBBadgeBarButtonItem* barButton = self;
    barButton.badgeValue = [NSString stringWithFormat:@"%d", [[[NSUserDefaults standardUserDefaults] objectForKey:kUDBadgeNumberNear] intValue] + [[[NSUserDefaults standardUserDefaults] objectForKey:kUDBadgeNumberFriends] intValue]];
}

-(void)increaseBadgeNumberIsNear:(BOOL)isNearBadge
{
    BBBadgeBarButtonItem* barButton = self;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    barButton.badgeValue = [NSString stringWithFormat:@"%d", [[defaults objectForKey:kUDBadgeNumberNear] intValue]  + [[defaults objectForKey:kUDBadgeNumberFriends] intValue]+ 1];
    
    if (isNearBadge) {
        [defaults setObject:[NSNumber numberWithInteger:[[defaults objectForKey:kUDBadgeNumberNear] intValue] + 1] forKey:kUDBadgeNumberNear];
    } else {
        [defaults setObject:[NSNumber numberWithInteger:[[defaults objectForKey:kUDBadgeNumberFriends] intValue] + 1] forKey:kUDBadgeNumberFriends];
    }
    
    [defaults synchronize];
    [self postNotification];
}

-(void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgeModified" object:nil];
}

@end