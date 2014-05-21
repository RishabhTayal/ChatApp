//
//  InAppNotificationView.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/21/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "InAppNotificationView.h"

@interface InAppNotificationView()

@property (strong) NoificationTouchBlock block;

@property (strong) IBOutlet UIImageView* mainImageView;
@property (strong) IBOutlet UILabel* headingLabel;
@property (strong) IBOutlet UILabel* detailLabel;

@end

@implementation InAppNotificationView

+(id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
//        _sharedObject = [[self alloc] init];
        _sharedObject = [[NSBundle mainBundle] loadNibNamed:@"InAppNotificationView" owner:self options:nil][0];
    });
    return _sharedObject;
}

-(void)notifyWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image duration:(CGFloat)duration andTouchBlock:(NoificationTouchBlock)block
{
    self.frame = CGRectMake(0, -80, 320, 80);
    
    _headingLabel.text = text;
    
    _detailLabel.text = detail;
    
    _mainImageView.image = image;
    
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    
    [mainWindow setWindowLevel:UIWindowLevelStatusBar + 1];
    
    [mainWindow addSubview:self];
    
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
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow setWindowLevel:UIWindowLevelNormal];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, -80, 320, 80);
    }];
}

@end
