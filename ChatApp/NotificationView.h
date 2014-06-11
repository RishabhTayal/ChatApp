//
//  NotificationView.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NotificationViewHeightTall = 50,
    NotificationViewHeightShort = 25,
    NotificationViewHeightDefault = NotificationViewHeightShort
}NotificationViewHeight;

@interface NotificationView : UIView

+(void)showInViewController:(UIViewController *)controller withText:(NSString *)text height:(NotificationViewHeight)height hideAfterDelay:(CGFloat)delay;
+(void)setNotificationText:(NSString*)text;
+(void)hide;

@end
