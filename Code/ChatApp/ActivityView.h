//
//  WLActivityView.h
//  ConferenceWL
//
//  Created by Rishabh Tayal on 4/18/14.
//
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView

+(void)showInView:(UIView*)view loadingMessage:(NSString*)loadingMessage;
+(void)hide;

@end
