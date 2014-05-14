//
//  SessionController.h
//  VCinity
//
//  Created by Rishabh Tayal on 5/14/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol SessionControllerDelegate;

@interface SessionController : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, weak) id<SessionControllerDelegate> delegate;

@property (nonatomic, readonly) NSArray *connectedPeers;
@property (nonatomic, readonly) NSString *displayName;

// Helper method for human readable printing of MCSessionState. This state is per peer.

-(id)initWithDelegate:(id<SessionControllerDelegate>)delegate;
-(NSString *)stringForPeerConnectionState:(MCSessionState)state;
-(BOOL)sendData:(NSData*)data;

@end

// Delegate methods for SessionController
@protocol SessionControllerDelegate <NSObject>

// Session changed state - connecting, connected and disconnected peers changed
- (void)sessionDidChangeState;
-(void)sessionDidRecieveData:(NSData*)data fromPeer:(NSString*)peerName;

@end
