//
//  MenuButton.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "MenuButton.h"
#import <MFSideMenu.h>

@implementation MenuButton

+(void)setupLeftMenuBarButtonOnViewController:(UIViewController *)vc
{
    UIButton* barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setBackgroundImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
    [barButton setFrame:CGRectMake(0, 0, 20, 20)];
    SEL selector  = sel_registerName("leftSideMenuButtonPressed:");
    [barButton addTarget:vc action:selector forControlEvents:UIControlEventTouchUpInside];
    [vc.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:barButton]];
}

@end