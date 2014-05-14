//
//  ViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController.h"
#import "SessionController.h"

@interface NearChatViewController : JSQMessagesViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SessionControllerDelegate>

@end
