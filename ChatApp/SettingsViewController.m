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
#import <IDMPhotoBrowser.h>

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
    
    PFFile* file = [PFUser currentUser][kPFUser_Picture];
    UIImage* img = [UIImage imageWithData:[file getData]];
    [self.tableView addParallaxWithImage:img andHeight:220];
    
    //Add tap gesture to Parallax View
    UITapGestureRecognizer* tapGestuere = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parallaxHeaderTapped:)];
    [self.tableView.parallaxView addGestureRecognizer:tapGestuere];
    
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

-(void)parallaxHeaderTapped:(UIGestureRecognizer*)reco
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Profile Photo", @"Take Photo", @"Choose From Photos", @"Import from Facebook", nil];
    sheet.tag = ActionSheetTypeHeaderPhoto;
    [sheet showInView:self.view.window];
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [tableView numberOfSections] - 1) {
        return 80;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == [tableView numberOfSections] - 1) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        label.text = @"Made with love by Appikon Mobile";
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //Tell a friend
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message", @"Mail", @"Facebook", @"Twitter", nil];
            sheet.tag = ActionSheetTypeShare;
            [sheet showInView:self.view.window];
        } else if (indexPath.row == 1) {
            MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
            mailVC.mailComposeDelegate = self;
            mailVC.view.tintColor = [UIColor whiteColor];
            [mailVC setSubject:@"Help me."];
            [mailVC setToRecipients:@[@"contact@appikon.com"]];
            //            [mailVC setMessageBody:@"" isHTML:NO];
            [self presentViewController:mailVC animated:YES completion:nil];
        }
    }
    if (indexPath.section == 2) {
        MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        mailVC.view.tintColor = [UIColor whiteColor];
        [mailVC setSubject:@"Feedback for vCinity App."];
        [mailVC setToRecipients:@[@"contact@appikon.com"]];
        [self presentViewController:mailVC animated:YES completion:nil];
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
                messageVC.body = @"Download vCinity app on AppStore to chat even with no Internet connection. https://itunes.apple.com/app/id875395391";
                [self presentViewController:messageVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 1) {
            //Message
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
                mailVC.view.tintColor = [UIColor whiteColor];
                [mailVC setSubject:@"vCinity App for iPhone"];
                [mailVC setMessageBody:@"Download vCinity app on AppStore to chat even with no Internet connection. https://itunes.apple.com/app/id875395391" isHTML:NO];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
        } else if (buttonIndex == 2) {
            //Facebook
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [sheet setInitialText:@"Download vCinity app on AppStore to chat even with no Internet connection. https://itunes.apple.com/app/id875395391"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        } else if (buttonIndex == 3) {
            //Twitter
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController* sheet = [[SLComposeViewController alloc] init];
                sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [sheet setInitialText:@"Download vCinity app on AppStore to chat even with no Internet connection. https://itunes.apple.com/app/id875395391"];
                [self presentViewController:sheet animated:YES completion:nil];
            }
        }
    } else if (actionSheet.tag == ActionSheetTypeHeaderPhoto) {
        if (buttonIndex == 0) {
            //View
            
            IDMPhoto* photo = [IDMPhoto photoWithImage:self.tableView.parallaxView.imageView.image];
            IDMPhotoBrowser* photoBrowser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:self.tableView.parallaxView];
            photoBrowser.scaleImage = self.tableView.parallaxView.imageView.image;
            [self presentViewController:photoBrowser animated:YES completion:nil];
            
        } else if (buttonIndex == 1) {
            //Take photo
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        } else if (buttonIndex == 2) {
            //Choose from library
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else if (buttonIndex == 3) {
            //Import from Facebook
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", [PFUser currentUser][kPFUser_FBID]]]];

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableView.parallaxView.imageView.image = [UIImage imageWithData:imgData];
                });
                
                PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
                    [[PFUser currentUser] saveInBackground];
                }];
            });
        }
    }
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.tableView.parallaxView.imageView.image = info[UIImagePickerControllerOriginalImage];
        
        NSData* imgData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.7);
        PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
            [[PFUser currentUser] saveInBackground];
        }];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
