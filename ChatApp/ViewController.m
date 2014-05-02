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

@property (strong) NSMutableArray* chatMessagesArray;

// Required for both Browser and Advertiser roles
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;

// Browser using provided Apple UI
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

// Advertiser assistant for declaring intent to receive invitations
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (strong) NSArray* nearbyPeers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    
    _chatMessagesArray = [NSMutableArray new];
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    
//    [self setBackgroundColor:[UIColor whiteColor]];
    
//    MultiPeerConnector* mcManager = [[MultiPeerConnector alloc] init];
//    [mcManager startFinding:self];

//    if (CURRENTDEVICE != IPHONE) {
        [self startBrowsing];
//    } else {
//        [self launchAdvertiser:nil];
//    }
}

-(void)startBrowsing
{
    NSLog(@"browse");
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kServiceName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    self.messageInputView.textView.placeHolder = @"browser";
}

- (void)launchAdvertiser:(id)sender {
    
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:kServiceName];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    self.messageInputView.textView.placeHolder = @"advertiser";
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"found");
    
//    MCSession* session = [[MCSession alloc] initWithPeer:peerID];
    [self.browser invitePeer:peerID toSession:_session withContext:nil timeout:0];
    
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"lost");
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"recived invitation");
    invitationHandler(YES, _session);
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"changed to %d", state);
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
//    NSPropertyListFormat format;
//    NSDictionary* recievedData = [NSPropertyListSerialization propertyListWithData:data options:0 format:&format error:NULL];
//    NSString* message = recievedData[@"message"];
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    JSMessage* messageObj = [[JSMessage alloc] initWithText:message sender:@"sender" date:[NSDate date]];
    [_chatMessagesArray addObject:messageObj];
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    NSLog(@"%@", message);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource: REQUIRED

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatMessagesArray.count;
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
    NSString* message = text;
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"%@", [_session connectedPeers]);
    NSError* error = nil;
    if (![self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:&error]) {
        NSLog(@"%@", error);
    }
    [self finishSend];
}

#pragma mark - Messages view data source: REQUIRED

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage* message = _chatMessagesArray[indexPath.row];
    
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
