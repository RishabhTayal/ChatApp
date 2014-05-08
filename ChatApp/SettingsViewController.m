//
//  SettingsViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <UIScrollView+APParallaxHeader.h>
#import <MFSideMenu.h>
#import "MenuButton.h"
#import "ActivityView.h"

@interface SettingsViewController ()

@property (strong) IBOutlet UILabel* nameLabel;

@property (strong) IBOutlet UISwitch* inAppVibrateSwitch;
@property (strong) IBOutlet UISwitch* soundSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _nameLabel.text = [PFUser currentUser].username;
    
    PFFile* file = [PFUser currentUser][@"picture"];
    UIImage* img = [UIImage imageWithData:[file getData]];
    [self.tableView addParallaxWithImage:img andHeight:220];

    self.title = @"Settings";
    
    [_inAppVibrateSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]];
    [_soundSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

-(IBAction)toggleInAppVibrate:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.isOn] forKey:kUDInAppVibrate];
}

-(IBAction)toggleSound:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.isOn] forKey:kUDInAppSound];
}

-(void)logout:(id)sender
{
    [ActivityView showInView:self.navigationController.view loadingMessage:@"Logging out..."];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(performLogout) userInfo:nil repeats:NO];
}

-(void)performLogout
{
    [ActivityView hide];
    
    [PFUser logOut];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:kUDKeyUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setLoginView];
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            //Tell a friend
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail", @"Message", @"Facebook", @"Twitter", nil];
            [sheet showInView:self.view.window];
        }
    }
}

#pragma mark - UIAction Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Mail
    } else if (buttonIndex == 1) {
        //Message
    } else if (buttonIndex == 2) {
        //Facebook
    } else if (buttonIndex == 3) {
        //Twitter
    }
}

@end
