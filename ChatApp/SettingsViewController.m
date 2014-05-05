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

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPress:)];
    // Do any additional setup after loading the view.
}

-(void)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logout:(id)sender
{
    [PFUser logOut];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:kUDKeyUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setLoginView];
}

//-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
//{
//    NSLog(@"logged out");
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:kUDKeyUserLoggedIn];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//    [appDelegate setLoginView];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
