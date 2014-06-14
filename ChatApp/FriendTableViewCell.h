//
//  FriendTableViewCell.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@interface FriendTableViewCell : SWTableViewCell

@property (strong) IBOutlet UILabel* friendName;
@property (strong) IBOutlet UIImageView* profilePicture;
@property (strong) IBOutlet UIButton* inviteButton;

@end
