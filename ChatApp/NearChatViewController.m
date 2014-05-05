//
//  ViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "NearChatViewController.h"
#import "JSMessage.h"
#import "SettingsViewController.h"
//#import "TWMessageBarManager.h"
#import "TSMessage.h"

static NSString* const kServiceName = @"multipeer";

#define CURRENTDEVICE [[UIDevice currentDevice] userInterfaceIdiom]
#define IPHONE UIUserInterfaceIdiomPhone


@interface NearChatViewController ()

@property (strong) NSMutableArray* chatMessagesArray;

// Required for both Browser and Advertiser roles
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;

// Browser using provided Apple UI
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

// Advertiser assistant for declaring intent to receive invitations
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (strong) NSArray* nearbyPeers;

//@property (strong) NSString* name;

@property (assign) BOOL foundPeer;

@property (strong) NSDate* lastShownTimeStamp;

@end

@implementation NearChatViewController

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    
    _chatMessagesArray = [NSMutableArray new];
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserFirstName], [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserLastName]];
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;

    self.messageInputView.textView.placeHolder = @"Type a message...";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsShow:)];
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    _foundPeer = false;
    [self startBrowsing];
}

-(void)settingsShow:(id)sender
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController* settVC = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settVC] animated:YES  completion:nil];
}

#pragma mark -

-(void)startBrowsing
{
    NSLog(@"browse");
    
    [TSMessage showNotificationInViewController:self title:@"No nearby users" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless canBeDismissedByUser:NO];
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kServiceName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchAdvertiser:) userInfo:nil repeats:NO];
}

- (void)launchAdvertiser:(id)sender {
    if (!_foundPeer) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:kServiceName];
        _advertiser.delegate = self;
        [_advertiser startAdvertisingPeer];
    }
}

#pragma mark - MCNearbyServiceBrowser Delegate

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"found");
    _foundPeer = YES;
    //    [_browser stopBrowsingForPeers];
    [self.browser invitePeer:peerID toSession:_session withContext:nil timeout:0];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"lost");
}

#pragma mark - MCNearbyServiceAdvertiser Delegate

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"recived invitation");
    invitationHandler(YES, _session);
}

#pragma mark - MCSession Delegate

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"changed to %d", state);
    switch (state) {
        case MCSessionStateConnected:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TSMessage dismissActiveNotification];
                [TSMessage showNotificationInViewController:self title:[NSString stringWithFormat:@"connected to %d users", [_session connectedPeers].count] subtitle:nil type:TSMessageNotificationTypeSuccess duration:1.0 canBeDismissedByUser:YES];
            });
        }
            break;
        case MCSessionStateNotConnected:
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [TSMessage dismissActiveNotification];
                [TSMessage showNotificationInViewController:self title:@"No nearby users" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless canBeDismissedByUser:NO];
            });
        }    break;
        default:
            break;
    }
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    JSMessage* messageObj = [[JSMessage alloc] initWithText:message sender:peerID.displayName date:[NSDate date]];
    [_chatMessagesArray addObject:messageObj];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self scrollToBottomAnimated:YES];
    });
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

#pragma mark -

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

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
        [attrs setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
        
        cell.bubbleView.textView.linkTextAttributes = attrs;
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
}

#pragma mark -

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage* message = _chatMessagesArray[indexPath.row];
    if ([message.sender isEqualToString:@"me"]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

//-(UIView *)inputView
//{
//    InputView *inputV = [[InputView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//    return inputV;
//}

#pragma mark - Message View Delegate: REQUIRED

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    NSLog(@"sent");
    NSString* message = text;
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    if (![self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:&error]) {
        NSLog(@"%@", error);
    } else {
        JSMessage* sentMessage = [[JSMessage alloc] initWithText:message sender:@"me" date:date];
        [_chatMessagesArray addObject:sentMessage];
        
        [self.tableView reloadData];
        [self scrollToBottomAnimated:YES];
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
    JSMessage* message = _chatMessagesArray[indexPath.row];
    if ([message.sender isEqualToString:@"me"]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}

-(BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        JSMessage* firstMessgae = _chatMessagesArray[0];
        _lastShownTimeStamp = firstMessgae.date;
        return YES;
    }
    JSMessage* message = _chatMessagesArray[indexPath.row];
    
    NSTimeInterval timeDiff = [message.date timeIntervalSinceDate:_lastShownTimeStamp];
    
    double mins = floor(timeDiff/60);
    NSLog(@"%@", message.date);
    NSLog(@"%@", _lastShownTimeStamp);
    NSLog(@"%f", mins);
    double secs = round(timeDiff - mins * 60);
    if (mins > 1) {
        _lastShownTimeStamp = message.date;
        return YES;
    }
    return NO;
}

@end
