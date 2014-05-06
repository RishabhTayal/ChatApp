//
//  FriendsListViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FriendsChatViewController.h"
#import <UIImageView+AFNetworking.h>

@interface FriendsListViewController ()

@property (strong) NSMutableArray* friendsUsingApp;
@property (strong) NSMutableArray* friendsNotUsingApp;

@end

@implementation FriendsListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _friendsUsingApp = [NSMutableArray new];
    
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/friends" parameters:@{@"fields":@"name,installed,first_name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", result[@"data"]);
        _friendsUsingApp = [NSMutableArray arrayWithArray:result[@"data"]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        FBRequest* allRequest = [FBRequest requestWithGraphPath:@"me/friendlists" parameters:nil HTTPMethod:@"GET"];
        [allRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSLog(@"%@", result);
        }];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Friends on ChatApp";
    }
    return @"Friends not on ChatApp";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return _friendsUsingApp.count;
    }
    return _friendsNotUsingApp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.friendName.text = _friendsUsingApp[indexPath.row][@"name"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: NO, @"redirect", @"50", @"height", @"normal", @"type", @"50", @"width", nil];
    
    /* make the API call */
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", _friendsUsingApp[indexPath.row][@"id"]] parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [cell.profilePicture setImageWithURL:connection.urlResponse.URL];
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
    chatVC.title = _friendsUsingApp[indexPath.row][@"name"];
    chatVC.friendId = _friendsUsingApp[indexPath.row][@"id"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
