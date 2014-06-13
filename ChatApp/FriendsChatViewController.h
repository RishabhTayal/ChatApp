//
//  FriendsChatViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController.h>

@interface FriendsChatViewController:JSQMessagesViewController

@property (strong) UIImage* friendsImage;
@property (strong) NSDictionary* friendDict;

@property (assign) BOOL isGroupChat;
@property (strong) NSMutableArray* groupMembers;

@end
