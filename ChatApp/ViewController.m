//
//  ViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "ViewController.h"
#import "JSMessage.h"
#import "SettingsViewController.h"
#import "TWMessageBarManager.h"

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

@property (strong) NSString* name;

@property (assign) BOOL foundPeer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    
    _chatMessagesArray = [NSMutableArray new];
    
    _name = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserFirstName], [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserLastName]];
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:_name];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsShow:)];
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    //    if (CURRENTDEVICE != IPHONE) {
    
    _foundPeer = false;
    [self startBrowsing];
    //    } else {
    //    }
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
    
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Looking for friend..." description:nil type:TWMessageBarMessageTypeInfo duration:1000];
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kServiceName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    self.messageInputView.textView.placeHolder = @"browsing";
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchAdvertiser:) userInfo:nil repeats:NO];
//    [self launchAdvertiser:nil];

}

- (void)launchAdvertiser:(id)sender {
    if (!_foundPeer) {
        
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Looking for friend..." description:nil type:TWMessageBarMessageTypeInfo duration:1000];
    
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:kServiceName];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    self.messageInputView.textView.placeHolder = @"advertiser";
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TWMessageBarManager sharedInstance] hideAllAnimated:YES];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Connected" description:nil type:TWMessageBarMessageTypeSuccess];
            });
            break;
        case MCSessionStateNotConnected:
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TWMessageBarManager sharedInstance] hideAllAnimated:YES];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Not Connected" description:nil type:TWMessageBarMessageTypeError];
            });
            break;
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
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}

-(BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return YES;
    }
    JSMessage* message = _chatMessagesArray[indexPath.row];
    JSMessage* prevMessage = _chatMessagesArray[indexPath.row - 1];
    
    NSTimeInterval timeDiff = [message.date timeIntervalSinceDate:prevMessage.date];
    
    double mins = floor(timeDiff/60);
//    double secs = round(timeDiff - mins * 60);
    if (mins > 0) {
        return YES;
    }
    return NO;
}

@end
