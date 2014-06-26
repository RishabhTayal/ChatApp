//
//  FriendsListViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADInterstitial.h"

@interface FriendsListViewController : UITableViewController<GADInterstitialDelegate>

-(IBAction)inviteFriend:(id)sender;
-(void)loadGroupsFromServer;

@end
