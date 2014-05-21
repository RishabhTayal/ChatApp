//
//  NotificationTapListener.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppNotificationTapListener : NSObject

+(id)sharedInAppNotificationTapListener;
-(void)startObserving;

@end
