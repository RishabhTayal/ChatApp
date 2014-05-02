//
//  ViewController.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

@end
