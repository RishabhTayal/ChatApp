//
//  NotificationView.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/8/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "DropDownView.h"

@implementation DropDownView

+(void)showInViewController:(UIViewController *)controller withText:(NSString *)text height:(DropDownViewHeight)height hideAfterDelay:(CGFloat)delay
{
    CGRect frame = CGRectMake(0, 0, [DropDownView getDeviceWidth], height);
    frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame) - frame.size.height;
    DropDownView* view = [DropDownView sharedInstance];
    view.frame = frame;
    
    for (UIView* subviews in view.subviews) {
        [subviews removeFromSuperview];
    }
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [DropDownView getDeviceWidth], frame.size.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    CGFloat fontSize;
    switch (height) {
        case DropDownViewHeightShort:
            fontSize = 12;
            break;
        case DropDownViewHeightTall:
            fontSize = 16;
            break;
        default:
            fontSize = 12;
            break;
    }
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor redColor];
    CGPoint center = CGPointMake(view.center.x, label.center.y);
    label.center = center;
    
    [view addSubview:label];
    [controller.navigationController.navigationBar.superview insertSubview:view belowSubview:controller.navigationController.navigationBar];
    
    
    POPSpringAnimation* anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.velocity = @(100.0);
    anim.springBounciness = 15.0;
    anim.toValue = @(76);
    [view.layer pop_addAnimation:anim forKey:@"slide"];
    
    if (delay != 0) {
        [[DropDownView class] performSelector:@selector(hide) withObject:nil afterDelay:delay];
    }
//    [UIView animateWithDuration:0.4 animations:^{
//        CGRect frame = view.frame;
//        frame.origin.y = CGRectGetMaxY(controller.navigationController.navigationBar.frame);
//        view.frame = frame;
//        
//    } completion:^(BOOL finished) {
//        if (delay != 0) {
//            [[DropDownView class] performSelector:@selector(hide) withObject:nil afterDelay:delay];
//        }
//    }];
}

+(void)setNotificationText:(NSString*)text
{
    DropDownView* view = [DropDownView sharedInstance];
    UILabel* label;
    
    if (view.subviews.count > 0) {
        label = [[view subviews] objectAtIndex:0];
    }
    
    CATransition* animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.75;
    
    [label.layer addAnimation:animation forKey:kCATransitionFade];
    label.text = text;
}

+(void)hide
{
    DropDownView* view = [DropDownView sharedInstance];
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

+(CGFloat)getDeviceWidth
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds;
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    //implicitly in Portrait orientation.
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    if(!statusBarHidden){
        CGFloat statusBarHeight = 20;//Needs a better solution, FYI statusBarFrame reports wrong in some cases..
        fullScreenRect.size.height -= statusBarHeight;
    }
    
    return fullScreenRect.size.width;
}

@end
