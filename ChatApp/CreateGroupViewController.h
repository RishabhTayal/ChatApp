//
//  CreateGroupViewController.h
//  VCinity
//
//  Created by Rishabh Tayal on 6/12/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TITokenField/TITokenField.h>
#import "FriendsListViewController.h"

@interface CreateGroupViewController : UIViewController<TITokenFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong) FriendsListViewController* friendsListVC;

@end
