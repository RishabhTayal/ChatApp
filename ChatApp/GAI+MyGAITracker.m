//
//  GAI+MyGAITracker.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/23/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "GAI+MyGAITracker.h"

@implementation GAI (MyGAITracker)

+(void)trackWithScreenName:(ScreenName)screenName
{
#ifdef DEBUG
    NSLog(@"GA Not trackking");
#else
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:ScreenNameString(screenName)];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
#endif
}

@end
