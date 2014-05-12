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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)toggleSound:(UISwitch*)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.isOn] forKey:kUDInAppSound];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)logout:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    sheet.tag = ActionSheetTypeLogout;
    [sheet showInView:self.view.window];
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
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message", @"Mail", @"Facebook", @"Twitter", nil];
            sheet.tag = ActionSheetTypeShare;
            [sheet showInView:self.view.window];
        }
    }
}

#pragma mark - UIAction Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ActionSheetTypeShare) {
        
        if (buttonIndex == 0) {
            //Mail
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController* messageVC = [[MFMessageComposeViewController alloc] init];
                messageVC.messageComposeDelegate = self;
                messageVC.view.tintColor = [UIColor whiteColor];
                messageVC.body = @"Share with friends";
                [self presentViewController:messageVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 1) {
            //Message
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
                mailVC.view.tintColor = [UIColor whiteColor];
                [mailVC setSubject:@"vCinity App"];
                [mailVC setToRecipients:@[@"email@example.com"]];
                [mailVC setMessageBody:@"share the app with friends" isHTML:NO];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 2) {
            //Facebook
        } else if (buttonIndex == 3) {
            //Twitter
        }
    } else if (actionSheet.tag == ActionSheetTypeLogout) {
        if (buttonIndex == 0) {
            [ActivityView showInView:self.navigationController.view loadingMessage:@"Logging out..."];
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(performLogout) userInfo:nil repeats:NO];
        }
    }
}

#pragma mark -

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
