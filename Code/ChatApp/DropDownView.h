//
//  NotificationView.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DropDownViewHeightTall = 50,
    DropDownViewHeightShort = 25,
    DropDownViewHeightDefault = DropDownViewHeightShort
}DropDownViewHeight;

@interface DropDownView : UIView

+(void)showInViewController:(UIViewController *)controller withText:(NSString *)text height:(DropDownViewHeight)height hideAfterDelay:(CGFloat)delay;
+(void)setNotificationText:(NSString*)text;
+(void)hide;

@end
