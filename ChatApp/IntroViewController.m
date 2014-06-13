//
//  IntroViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "IntroViewController.h"
#import "NearChatViewController.h"
#import <Parse/Parse.h>
#import "MenuViewController.h"
#import <MFSideMenu.h>
#import "NearChatViewController.h"
#import "ActivityView.h"

@interface IntroViewController ()
@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GAI trackWithScreenName:kScreenNameLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithTwitter:(id)sender
{
}

-(void)loginWithFacebook:(id)sender
{
    NSLog(@"login with facebook");
    [ActivityView showInView:self.view loadingMessage:@"Please Wait..."];
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        [ActivityView hide];
        if (user == nil) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:@"To use you Facebook account with this app, open Settings > Facebook and make sure this app is turned on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    
                    if ([[PFUser currentUser] objectForKey:kPFUser_FBID] == NULL) {
                        //First Time user
                        NSLog(@"First Time");
                        [self notifyFriendsViaPushThatIJoined];
                    }
                    
                    [[PFUser currentUser] setObject:result[@"id"] forKey:kPFUser_FBID];
                    [[PFUser currentUser] setObject:result[@"name"] forKey:kPFUser_Username];
                    [[PFUser currentUser] setObject:result[@"email"] forKey:kPFUser_Email];
                    [[PFUser currentUser] saveInBackground];
                    
                    //If there is no picture for user, download it from Facebook
                    if (![PFUser currentUser][kPFUser_Picture]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", result[@"id"]]]];
                            
                            PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
                            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                [[PFUser currentUser] setObject:imageFile forKey:kPFUser_Picture];
                                [[PFUser currentUser] saveInBackground];
                            }];
                        });
                    }
                    
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser][kPFUser_FBID] forKey:@"owner"];
                    [[PFInstallation currentInstallation] saveInBackground];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyUserLoggedIn];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    MFSideMenuContainerViewController* sideMenuVC = [MFSideMenuContainerViewController containerWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:[[NearChatViewController alloc] init]] leftMenuViewController:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController alloc] init]] rightMenuViewController:nil];
                    sideMenuVC.menuSlideAnimationEnabled = YES;
                    [self.view addSubview:sideMenuVC.view];
                    CATransition* anim = [CATransition animation];
                    [anim setDelegate:self];
                    [anim setDuration:1.5];
                    [anim setTimingFunction:UIViewAnimationCurveEaseInOut];
                    [anim setType:@"rippleEffect"];
                    [anim setFillMode:kCAFillModeRemoved];
                    anim.endProgress = 0.99;
                    [anim setRemovedOnCompletion:NO];
                    
                    [self.view.layer addAnimation:anim forKey:nil];
                }
            }];
        }
    }];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    MFSideMenuContainerViewController* sideMenuVC = [MFSideMenuContainerViewController containerWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:[[NearChatViewController alloc] init]] leftMenuViewController:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController alloc] init]] rightMenuViewController:nil];
    sideMenuVC.menuSlideAnimationEnabled = YES;
    self.view.window.rootViewController = sideMenuVC;
}

-(void)notifyFriendsViaPushThatIJoined
{
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/friends" parameters:@{@"fields":@"name,first_name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"Error: %@", error);
        
        NSArray* friendsUsingApp = [NSMutableArray arrayWithArray:result[@"data"]];

        NSArray* recipients = [friendsUsingApp valueForKey:@"id"];
        PFQuery* pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" containedIn:recipients];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        
        [push setMessage:[NSString stringWithFormat:@"Your friend %@ just joined vCinity! Start Chatting with them now.", [PFUser currentUser].username]];
        [push sendPushInBackground];
    }];
    
}

@end