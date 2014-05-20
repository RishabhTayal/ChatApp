//
//  NotificationView.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

+(void)showInViewController:(UIViewController *)controller withText:(NSString *)text hideAfterDelay:(CGFloat)delay
{
    CGRect frame = CGRectMake(0, 0, 320, 25);
    frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame) - frame.size.height;
    NotificationView* view = [NotificationView sharedInstance];
    view.frame = frame;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor redColor];
    CGPoint center = CGPointMake(view.center.x, label.center.y);
    label.center = center;
    
    [view addSubview:label];
    [controller.navigationController.navigationBar.superview insertSubview:view belowSubview:controller.navigationController.navigationBar];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = view.frame;
        frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame);
        view.frame = frame;

    } completion:^(BOOL finished) {
        if (delay != 0) {
            [[NotificationView class] performSelector:@selector(hide) withObject:nil afterDelay:delay];
        }
    }];
}

+(void)hide
{
    NotificationView* view = [NotificationView sharedInstance];
    [UIView animateWithDuration:0.4 animations:^{
        view.frame = CGRectMake(0, -40, 320, 40);
    }];
}

+(id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

@end