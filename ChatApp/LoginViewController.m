//
//  LoginViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{


    [super viewDidLoad];
    [self showIntroView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showIntroView
{
    EAIntroPage* page1 = [EAIntroPage page];
    page1.title = @"a title";
    [page1 setBgImage:[UIImage imageNamed:@"bg1"]];
    
    EAIntroPage* page2 = [EAIntroPage page];
    page2.title = @"second title";
    page2.titlePositionY = 30;
     [page2 setBgImage:[UIImage imageNamed:@"bg2"]];
    
    EAIntroView* introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2]];
    introView.delegate = self;
    introView.skipButton = nil;
    [introView setUseMotionEffects:YES];
    [introView setMotionEffectsRelativeValue:40];
    [introView showInView:self.view animateDuration:0.3];
}
//
//-(UIImage*)imageFromColor:(UIColor*)color
//{
//    CGRect rect = CGRectMake(0, 0, 1, 1);
//    // Create a 1 by 1 pixel context
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
//    [color setFill];
//    UIRectFill(rect);   // Fill it with your color
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}

#pragma mark - FBLoginView Delegate

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"asdf");
    NSLog(@"%@", error);
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"fetch");
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUDKeyUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:user[@"first_name"] forKey:kUDKeyUserFirstName];
    [[NSUserDefaults standardUserDefaults] setObject:user[@"last_name"] forKey:kUDKeyUserLastName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:NO, @"redirect", @"200", @"height", @"normal", @"type", @"200", @"width", nil];
//    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", user[@"id"]] parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NSLog(@"%@", result);
//    }];
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController* vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:vc];
    [UIView transitionWithView:self.view.window duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.view.window.rootViewController = navC;
    } completion:nil];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"logg");
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"out");
}

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
