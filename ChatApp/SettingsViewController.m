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

@interface SettingsViewController ()

@property (strong) IBOutlet UILabel* nameLabel;

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
    [self.tableView addParallaxWithImage:img andHeight:200];

    self.title = @"Settings";
    
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

-(void)logout:(id)sender
{
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
