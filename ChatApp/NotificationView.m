//
//  NotificationView.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

+(void)showInViewController:(UIViewController *)controller withText:(NSString *)text hide:(BOOL)hide
{
    CGRect frame = CGRectMake(0, 0, 320, 25);
    frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame) - frame.size.height;
    NotificationView* view = [[NotificationView alloc] init];
    view.frame = frame;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16e0, frame.size.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    CGPoint center = CGPointMake(view.center.x, label.center.y);
    label.center = center;
    
    [view addSubview:label];
    [controller.navigationController.navigationBar.superview insertSubview:view belowSubview:controller.navigationController.navigationBar];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:0 animations:^{
        CGRect frame = view.frame;
        frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame);
        view.frame = frame;

    } completion:^(BOOL finished) {
        if (hide) {
            [[NotificationView class] performSelector:@selector(hide:) withObject:view afterDelay:5];
        }
    }];
}

+(void)hide:(UIView*)view
{
    [UIView animateWithDuration:0.4 animations:^{
        view.frame = CGRectMake(0, -40, 320, 40);
    }];
}

@end
