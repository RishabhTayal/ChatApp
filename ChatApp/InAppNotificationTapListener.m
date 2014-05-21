//
//  NotificationTapListener.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "InAppNotificationTapListener.h"
#import "FriendsListViewController.h"
#import "FriendsChatViewController.h"
#import <MFSideMenuContainerViewController.h>
#import "AppDelegate.h"
#import "MenuViewController.h"

@implementation InAppNotificationTapListener

+(id)sharedInAppNotificationTapListener
{
    static dispatch_once_t once;
    static InAppNotificationTapListener* sharedObserver = nil;
    
    dispatch_once(&once, ^{
        sharedObserver = [[self alloc] init];
    });
    return sharedObserver;
}

-(void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"notificationTapped" object:nil];
}

-(void)pushNotificationRecieved:(NSNotification*)notification
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    MFSideMenuContainerViewController* currentVC = ((MFSideMenuContainerViewController*)appDelegate.window.rootViewController);
    UINavigationController* navC = (UINavigationController*)currentVC.leftMenuViewController;
    MenuViewController* menuVC = (MenuViewController*)navC.topViewController;
    NSLog(@"%@", menuVC.tableView);
    [menuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [menuVC tableView:menuVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    FriendsListViewController* friendsList = (FriendsListViewController*)((UINavigationController*)currentVC.centerViewController).topViewController;
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
    chatVC.title = notification.userInfo[kNotificationSender][@"name"];
    
    chatVC.friendDict = notification.userInfo[kNotificationSender];
    [friendsList.navigationController pushViewController:chatVC animated:YES];
    NSLog(@"Notification tapped");
}

@end
