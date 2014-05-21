//
//  InAppNotificationView.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InAppNotificationView;

typedef void (^NoificationTouchBlock)(InAppNotificationView* view);

@interface InAppNotificationView : UIView

+(id)sharedInstance;

-(void)notifyWithText:(NSString*)text detail:(NSString*)detail image:(UIImage*)image duration:(CGFloat)duration andTouchBlock:(NoificationTouchBlock)block;

@end
