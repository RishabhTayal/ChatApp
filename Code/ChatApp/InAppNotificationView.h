//
//  InAppNotificationView.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InAppNotificationView;

typedef void (^NotificationTouchBlock)(InAppNotificationView* view);

@interface InAppNotificationView : UIView

+(id)sharedInstance;

-(void)notifyWithUserInfo:(NSDictionary*)userInfo andTouchBlock:(NotificationTouchBlock)block;
-(void)notifyWithText:(NSString*)text detail:(NSString*)detail image:(UIImage*)image duration:(CGFloat)duration andTouchBlock:(NotificationTouchBlock)block;

@end
