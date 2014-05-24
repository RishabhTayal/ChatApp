//
//  GAI+MyGAITracker.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/23/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "GAI.h"

typedef enum
{
    kScreenNameNearChat,
    kScreenNameFriendsList,
    kScreenNameFriendsChat,
    kScreenNameSettings,
    kScreenNameLogin
} ScreenName;

#define ScreenNameString(enum) [@[@"NearChat",@"FriendsList",@"FriendsChat", @"Settings", @"Login"] objectAtIndex:enum]

@interface GAI (MyGAITracker)

+(void)trackWithScreenName:(ScreenName)screenName;

@end
