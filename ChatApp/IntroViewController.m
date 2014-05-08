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

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login:(id)sender
{
    NSLog(@"login");
    
    //    NSArray* permissions = @[@"user_friends"];
    
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        NSLog(@"%@", user);
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSLog(@"%@", result);
                [[PFUser currentUser] setObject:result[@"id"] forKey:@"fbID"];
                [[PFUser currentUser] setObject:result[@"name"] forKey:@"username"];
                [[PFUser currentUser] setObject:result[@"email"] forKey:@"email"];
                [[PFUser currentUser] saveInBackground];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500", result[@"id"]]]];
                    
                    PFFile* imageFile = [PFFile fileWithName:@"profile.jpg" data:imgData];
                    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        [[PFUser currentUser] setObject:imageFile forKey:@"picture"];
                                            [[PFUser currentUser] saveInBackground];
//                        PFObject* userPhoto = [PFObject objectWithClassName:@"ProfilePhoto"];
//                        [userPhoto setObject:imageFile forKey:@"image"];
                        
//                        userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                        
//                        [userPhoto setObject:[PFUser currentUser] forKey:@"user"];
//                        [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        
//                        }];
                    }];
                    
//                    [[PFUser currentUser] setObject:imgData forKey:@"picture"];

                });
                
                NSLog(@"%@", [PFUser currentUser][@"fbID"]);
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser][@"fbID"] forKey:@"owner"];
                [[PFInstallation currentInstallation] saveInBackground];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyUserLoggedIn];
                [[NSUserDefaults standardUserDefaults] setObject:user[@"first_name"] forKey:kUDKeyUserFirstName];
                [[NSUserDefaults standardUserDefaults] setObject:user[@"last_name"] forKey:kUDKeyUserLastName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                MFSideMenuContainerViewController* vc = [MFSideMenuContainerViewController containerWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:[[NearChatViewController alloc] init]] leftMenuViewController:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController alloc] init]] rightMenuViewController:nil];
                //    FriendsChatViewController* vc = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
                [UIView transitionWithView:self.view.window duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.view.window.rootViewController = vc;
                } completion:nil];
            }
        }];
    }];
}

@end
