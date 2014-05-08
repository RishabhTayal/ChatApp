//
//  WLActivityView.m
//  ConferenceWL
//
//  Created by Rishabh Tayal on 4/18/14.
//
//

#import "ActivityView.h"

@interface ActivityView()

@property (strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (strong) IBOutlet UILabel* loadingMessageLabel;

@end

@implementation ActivityView

+(void)showInView:(UIView *)view loadingMessage:(NSString *)loadingMessage
{
    ActivityView* activity = [ActivityView sharedInstance];
    activity.frame = view.frame;
    [activity.activityIndicator startAnimating];
    if (loadingMessage.length) {
        activity.loadingMessageLabel.text = loadingMessage;
    }
    activity.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [view addSubview:activity];
        activity.alpha = 1;
    }];
}

+(void)hide
{
    ActivityView* activity = [ActivityView sharedInstance];
    [activity.activityIndicator stopAnimating];
    [activity removeFromSuperview];
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
//        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        [self addSubview:view];
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
