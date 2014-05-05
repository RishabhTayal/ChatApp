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
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        NSLog(@"%@", user);
       
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSLog(@"%@", result);
                [[PFUser currentUser] setObject:result[@"id"] forKey:@"fbID"];
                [[PFUser currentUser] setObject:result[@"name"] forKey:@"username"];
                [[PFUser currentUser] setObject:result[@"email"] forKey:@"email"];
                [[PFUser currentUser] saveInBackground];
                
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyUserLoggedIn];
                [[NSUserDefaults standardUserDefaults] setObject:user[@"first_name"] forKey:kUDKeyUserFirstName];
                [[NSUserDefaults standardUserDefaults] setObject:user[@"last_name"] forKey:kUDKeyUserLastName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
//                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:NO, @"redirect", @"200", @"height", @"normal", @"type", @"200", @"width", nil];
                //    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", user[@"id"]] parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                //        NSLog(@"%@", result);
                //    }];
                
                //    PFUser* newUser = [PFUser user];
                //    newUser.email = user[@"email"];
                
                
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NearChatViewController* vc = [sb instantiateViewControllerWithIdentifier:@"NearChatViewController"];
                UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:vc];
                [UIView transitionWithView:self.view.window duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.view.window.rootViewController = navC;
                } completion:nil];
            }
        }];
    }];
}

//#pragma mark - FBLoginView Delegate
//
//-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
//{
//    NSLog(@"asdf");
//    NSLog(@"%@", error);
//}
//
//-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
//{
//    NSLog(@"fetch");
//    
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyUserLoggedIn];
//    [[NSUserDefaults standardUserDefaults] setObject:user[@"first_name"] forKey:kUDKeyUserFirstName];
//    [[NSUserDefaults standardUserDefaults] setObject:user[@"last_name"] forKey:kUDKeyUserLastName];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:NO, @"redirect", @"200", @"height", @"normal", @"type", @"200", @"width", nil];
//    //    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", user[@"id"]] parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//    //        NSLog(@"%@", result);
//    //    }];
//    
////    PFUser* newUser = [PFUser user];
////    newUser.email = user[@"email"];
//    
//    
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    ViewController* vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
//    UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:vc];
//    [UIView transitionWithView:self.view.window duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        self.view.window.rootViewController = navC;
//    } completion:nil];
//}
//
//-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
//{
//    NSLog(@"logg");
//}
//
//-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
//{
//    NSLog(@"out");
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
