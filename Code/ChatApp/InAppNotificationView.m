//
//  InAppNotificationView.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "InAppNotificationView.h"
#import "Group.h"
#import "Friend.h"
#import "UIImage+Utility.h"

@interface InAppNotificationView()

@property (strong) NotificationTouchBlock block;
@property (strong) UIWindow* myWindow;

@property (strong) IBOutlet UIImageView* mainImageView;
@property (strong) IBOutlet UILabel* headingLabel;
@property (strong) IBOutlet UILabel* detailLabel;

@end

@implementation InAppNotificationView

+(id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[NSBundle mainBundle] loadNibNamed:@"InAppNotificationView" owner:self options:nil][0];
    });
    return _sharedObject;
}

-(void)notifyWithUserInfo:(NSDictionary *)userInfo andTouchBlock:(NotificationTouchBlock)block
{
    if ([userInfo[kNotificationPayload][kNotificationPayloadIsGroupChat] boolValue] == TRUE) {
        Group* group = [[Group MR_findByAttribute:@"groupId" withValue:userInfo[kNotificationPayload][kNotificationPayloadGroupId]] firstObject];
        [UIImage imageForURL:[NSURL URLWithString:group.imageurl] imageDownloadBlock:^(UIImage *image, NSError *error) {
            [self notifyWithText:[NSString stringWithFormat:@"%@ @ \"%@\":", userInfo[kNotificationSender][@"name"], group.name] detail:userInfo[kNotificationMessage] image:image duration:3 andTouchBlock:block];
        }];
    } else {
        [UIImage imageForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200", userInfo[kNotificationSender][@"id"]]] imageDownloadBlock:^(UIImage *image, NSError *error) {
            [[InAppNotificationView sharedInstance] notifyWithText:userInfo[kNotificationSender][@"name"] detail:userInfo[kNotificationMessage] image:image duration:3 andTouchBlock:block];
        }];
    }
}

-(void)notifyWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image duration:(CGFloat)duration andTouchBlock:(NotificationTouchBlock)block
{
    self.frame = CGRectMake(0, -80, 320, 80);
    
    _headingLabel.text = text;
    _detailLabel.text = detail;
    _mainImageView.image = image;
    
    _myWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _myWindow.windowLevel = UIWindowLevelStatusBar + 1;
    _myWindow.hidden = NO;
    [_myWindow addSubview:self];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:gesture];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = 0;
        self.frame = frame;
    }];
    
    if (duration != 0) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:duration];
    }
    
    _block = block;
}

-(void)tapped
{
    [self hide];
    _block(self);
}

-(void)hide
{
    [_myWindow setHidden:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, -80, 320, 80);
    }];
}

@end