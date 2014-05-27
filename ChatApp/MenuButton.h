//
//  MenuButton.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BBBadgeBarButtonItem.h>

@interface MenuButton : BBBadgeBarButtonItem

+(id)sharedInstance;

-(void)setBadgeNumber:(int)badge isNearBadge:(BOOL)nearBadge;
-(void)resetBadgeNumber;
-(void)increaseBadgeNumberIsNear:(BOOL)isNearBadge;

@end
