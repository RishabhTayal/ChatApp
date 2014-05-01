//
//  ViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "ViewController.h"
#import "JSMessage.h"



static NSString* const kServiceName = @"multipeer";

#define CURRENTDEVICE [[UIDevice currentDevice] userInterfaceIdiom]
#define IPHONE UIUserInterfaceIdiomPhone


@interface ViewController ()

// Required for both Browser and Advertiser roles
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;

// Browser using provided Apple UI
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

// Advertiser assistant for declaring intent to receive invitations
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

@property (strong) NSArray* nearbyPeers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.delegate = self;
//    self.dataSource = self;
    
//    [self setBackgroundColor:[UIColor whiteColor]];
    
//    MultiPeerConnector* mcManager = [[MultiPeerConnector alloc] init];
//    [mcManager startFinding:self];

    if (CURRENTDEVICE == IPHONE) {
        [self startBrowsing];
    } else {
        [self launchAdvertiser:nil];
    }// Do any additional setup after loading the view, typically from a nib.
}

-(void)startBrowsing
{
    NSLog(@"browse");
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Browser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kServiceName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    self.messageInputView.textView.placeHolder = @"browser";
//    [self presentViewController:_browserView animated:YES completion:nil];
}

- (void)launchAdvertiser:(id)sender {
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Advertiser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceName discoveryInfo:nil session:_session];
    [_advertiserAssistant start];
    self.messageInputView.textView.placeHolder = @"advertiser";
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"found");
    
//    self.nearbyPeers = @[@{@"peerID": peerID, @"peerInfo": info}];
    MCSession* session = [[MCSession alloc] initWithPeer:peerID];
    [self.browser invitePeer:peerID toSession:session withContext:nil timeout:0];
    
//    [browser startBrowsingForPeers];
}

-(void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"change");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource: REQUIRED

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

#pragma mark -

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageTypeIncoming;
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleClassic;
}

#pragma mark - Message View Delegate: REQUIRED

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    NSLog(@"sent");
}

#pragma mark - Messages view data source: REQUIRED

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage* message = [[JSMessage alloc] initWithText:@"a" sender:@"sender" date:[NSDate date]];
    return message;
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor whiteColor]];
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}

@end
