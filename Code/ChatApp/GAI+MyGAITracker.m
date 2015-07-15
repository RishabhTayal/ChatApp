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
    if (DEBUGMODE) {
        DLog(@"GA Not trackking");
    } else {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        [tracker set:kGAIScreenName value:ScreenNameString(screenName)];
//        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}

+(void)trackEventWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber*)value
{
    if (DEBUGMODE) {
        DLog(@"GA Not trackking");
    } else {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
    }
}

@end