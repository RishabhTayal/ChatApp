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

-(void)setBadgeNumber:(int)badge
{
    BBBadgeBarButtonItem* barButton = self;
    barButton.badgeValue = [NSString stringWithFormat:@"%d", badge];
    [[NSUserDefaults standardUserDefaults] setObject:barButton.badgeValue forKey:kUDBadgeNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)resetBadgeNumber
{
    BBBadgeBarButtonItem* barButton = self;
    barButton.badgeValue = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kUDBadgeNumber]];
}

-(void)increaseBadgeNumber
{
    BBBadgeBarButtonItem* barButton = self;
    barButton.badgeValue = [NSString stringWithFormat:@"%d", [[[NSUserDefaults standardUserDefaults] objectForKey:kUDBadgeNumber] intValue] + 1];
    
    [[NSUserDefaults standardUserDefaults] setObject:barButton.badgeValue forKey:kUDBadgeNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end