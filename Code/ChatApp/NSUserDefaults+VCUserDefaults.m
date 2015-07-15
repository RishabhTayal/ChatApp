//
//  NSUserDefaults+VCUserDefaults.m
//  VCinity
//
//  Created by Rishabh Tayal on 7/15/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import "NSUserDefaults+VCUserDefaults.h"

@implementation NSUserDefaults (VCUserDefaults)

+(BOOL)isNearChatCoachmarkShown {
    return [[self standardUserDefaults] boolForKey:kCMNearChatShown];
}

+(void)setNearChatCoachmarkShown {
    [[self standardUserDefaults] setBool:true forKey:kCMNearChatShown];
    [[self standardUserDefaults] synchronize];
}

@end
