//
//  SettingsViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/2/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

typedef enum {
    ActionSheetTypeShare = 100,
    ActionSheetTypeLogout
}ActionSheetType;

@interface SettingsViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

-(IBAction)logout:(id)sender;

@end
