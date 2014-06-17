//
//  Constants.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#ifndef ChatApp_Constants_h
#define ChatApp_Constants_h

#ifdef DEBUG
#define DEBUGMODE YES
#else
#define DEBUGMODE NO
#endif

//NSUserDefaults Keys
#define kUDKeyUserLoggedIn @"loggedin"

//Setting UserDefaults
#define kUDInAppVibrate @"inAppVibrate"
#define kUDInAppSound @"inAppSound"
#define kUDSyncContactsToServer @"syncContactsToServer"

//PFUser currentUser Keys
#define kPFUser_Username @"username"
#define kPFUser_Email @"email"
#define kPFUser_FBID @"fbID"
#define kPFUser_Picture @"picture"

//Parse Table Names
#define kPFTableName_Chat @"Wechat"
#define kPFTableUser @"User"
#define kPFTableGroup @"Groups"

//Chat Table Columns
#define kPFChatSender @"sender"
#define kPFChatReciever @"receiver"
#define kPFChatMessage @"msg"

#define kPFGroupName @"name"
#define kPFGroupPhoto @"photo"
#define kPFGroupMembers @"members"

//Notification Related Keys
#define kNotificationSender @"sender"
//#define kNotificationReceiever @"reciever"
#define kNotificationMessage @"message"
#define kNotificationAlert @"alert"
#define kNotificationPayload @"payload"
#define kNotificationPayloadIsGroupChat @"isGroupChat"
#define kNotificationPayloadGroupId @"groupId"

#endif
