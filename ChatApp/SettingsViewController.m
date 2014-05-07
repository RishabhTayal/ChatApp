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

@interface SettingsViewController ()

@property (strong) IBOutlet UILabel* nameLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    
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

-(void)logout:(id)sender
{
    [PFUser logOut];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:kUDKeyUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setLoginView];
}

@end
