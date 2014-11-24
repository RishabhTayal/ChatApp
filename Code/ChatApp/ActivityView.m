//
//  WLActivityView.m
//  ConferenceWL
//
//  Created by Rishabh Tayal on 4/18/14.
//
//

#import "ActivityView.h"

@interface ActivityView()

@property (strong) IBOutlet UIView* containerView;
@property (strong) IBOutlet UIImageView* activityIndicator;
@property (strong) IBOutlet UILabel* loadingMessageLabel;

@property (assign) BOOL animating;

@end

@implementation ActivityView

+(void)showInView:(UIView *)view loadingMessage:(NSString *)loadingMessage
{
    ActivityView* activity = [ActivityView sharedInstance];
//    activity.frame = view.bounds;
    //    [activity.actisityIndicator startAnimating];
    activity.animating = YES;
    [activity spinWithOptions:UIViewAnimationOptionCurveEaseIn];
    if (loadingMessage.length) {
        activity.loadingMessageLabel.text = loadingMessage;
    }
    activity.alpha = 0;
    
    activity.containerView.layer.cornerRadius = 4;
    activity.containerView.layer.masksToBounds = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        [view addSubview:activity];
        activity.alpha = 1;
    }];
}

+(void)hide
{
    ActivityView* activity = [ActivityView sharedInstance];
    activity.animating = NO;
    [activity removeFromSuperview];
}

-(void)spinWithOptions:(UIViewAnimationOptions)options
{
    ActivityView* activity = [ActivityView sharedInstance];
    [UIView animateWithDuration:0.5f delay:0 options:options animations:^{
        activity.activityIndicator.transform = CGAffineTransformRotate(activity.activityIndicator.transform, M_PI_2);
    } completion:^(BOOL finished) {
        if (finished) {
            if (activity.animating) {
                [self spinWithOptions:UIViewAnimationOptionCurveLinear];
            } else if (options != UIViewAnimationOptionCurveEaseOut) {
                [self spinWithOptions:UIViewAnimationOptionCurveEaseOut];
            }
        }
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* view = [[[NSBundle mainBundle] loadNibNamed:@"ActivityView" owner:self options:nil] objectAtIndex:0];
        view.opaque = NO;
        view.frame = [UIScreen mainScreen].bounds;
        [self addSubview:view];
        // Initialization code
    }
    return self;
}

@end
