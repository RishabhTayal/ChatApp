//
//  Constants.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#ifndef ChatApp_Constants_h
#define ChatApp_Constants_h

//NSUserDefaults Keys
#define kUDKeyUserLoggedIn @"loggedin"
//#define kUDKeyUserFirstName @"first_name"
//#define kUDKeyUserLastName @"last_name"
//#define kUDKeyUserLocLongitude @"user_longitude"
//#define kUDKeyUserLocLatitude @"user_latitude"

//Setting UserDefaults
#define kUDInAppVibrate @"inAppVibrate"
#define kUDInAppSound @"inAppSound"
#define kUDBadgeNumberNear @"badgeNumberNear"
#define kUDBadgeNumberFriends @"badgeNumberFriends"

//PFUser currentUser Keys
#define kPFUser_Username @"username"
#define kPFUser_Email @"email"
#define kPFUser_FBID @"fbID"
#define kPFUser_Picture @"picture"

//Parse Table Names
#define kPFTableName_Chat @"Wechat"
#define kPFTableUser @"User"

//Chat Table Columns
#define kPFChatSender @"sender"
#define kPFChatReciever @"receiver"
#define kPFChatMessage @"msg"

//Notification Related Keys
#define kNotificationSender @"sender"
#define kNotificationReceiever @"reciever"
#define kNotificationMessage @"message"
#define kNotificationAlert @"alert"

#endif
