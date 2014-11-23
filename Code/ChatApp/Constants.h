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

#ifndef DLog
#ifdef DEBUG
#define DLog(_format_, ...) NSLog(_format_, ## __VA_ARGS__)
#else
#define DLog(_format_, ...)
#endif
#endif

//NSUserDefaults Keys
#define kUDKeyUserLoggedIn @"loggedin"
#define kUDKeyLoginSkipped @"loginSkipped"

//Setting UserDefaults
#define kUDInAppVibrate @"inAppVibrate"
#define kUDInAppSound @"inAppSound"
//#define kUDAdLastShowniAd @"adLastShowniAd"
#define kUDAdLastShown @"adLastShown"

#define kGADAdUnitId @"ca-app-pub-8353175505649532/7101209039"

//PFUser currentUser Keys
#define kPFUser_Name @"name"
#define kPFUser_Email @"email"
#define kPFUser_FBID @"fbID"
#define kPFUser_Picture @"picture"
#define kPFUser_Invited @"invited"

//Parse Table Names
#define kPFTableName_Chat @"Wechat"
#define kPFTableUser @"User"
#define kPFTableGroup @"Groups"

//Chat Table Columns
#define kPFChatSender @"sender"
#define kPFChatReciever @"receiver"
#define kPFChatMessage @"msg"
#define kPFChatIsMedia @"isMedia"
#define kPFChatMedia @"media"

#define kPFGroupName @"name"
#define kPFGroupPhoto @"photo"
#define kPFGroupMembers @"members"

//Notification Related Keys
#define kNotificationSender @"sender"
//#define kNotificationReceiever @"reciever"
#define kNotificationMessage @"message"
#define kNotificationMediaUrl @"mediaurl"
#define kNotificationAlert @"alert"
#define kNotificationPayload @"payload"
#define kNotificationIsMedia @"isMedia"
#define kNotificationPayloadIsGroupChat @"isGroupChat"
#define kNotificationPayloadGroupId @"groupId"

#endif
