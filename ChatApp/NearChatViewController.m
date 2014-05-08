//
//  ViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "NearChatViewController.h"
#import "SettingsViewController.h"
#import "TSMessage.h"
#import <JSQMessages.h>
#import "MenuButton.h"
#import <MFSideMenu.h>
#import <Parse/Parse.h>

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
    [super viewDidLoad];
    
    self.title = @"vCinity Chat";
    
    self.sender = [[PFUser currentUser] username];
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _chatMessagesArray = [NSMutableArray new];
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserFirstName], [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyUserLastName]];
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    
    _foundPeer = false;
    [self startBrowsing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark -

-(void)startBrowsing
{
    NSLog(@"browse");
    
    [TSMessage showNotificationInViewController:self title:@"No nearby users" subtitle:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationEndless canBeDismissedByUser:NO];
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kServiceName];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchAdvertiser) userInfo:nil repeats:NO];
}

- (void)launchAdvertiser
{
    if (!_foundPeer) {
        
        NSLog(@"Advertise");
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
            _foundPeer = NO;
            [self launchAdvertiser];
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
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]== YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
    
    NSKeyedUnarchiver* unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //    unArchiver.requiresSecureCoding = YES;
    id object = [unArchiver decodeObject];
    [unArchiver finishDecoding];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString* message = object;
        
        JSQMessage* messageObj = [[JSQMessage alloc] initWithText:message sender:peerID.displayName date:[NSDate date]];
        [_chatMessagesArray addObject:messageObj];
    } else {
        UIImage* image = [UIImage imageWithData:object];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finishReceivingMessage];
        [self scrollToBottomAnimated:YES];
    });
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"recieve stream");
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"start recieve resource");
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"finish recieve resource");
}

#pragma mark - Sending Data

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    NSLog(@"sent");
    NSString* message = text;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }
    
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:message];
    [archiver finishEncoding];
    
    NSError* error = nil;
    if (![self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:&error]) {
        NSLog(@"%@", error);
    } else {
        JSQMessage* sentMessage = [[JSQMessage alloc] initWithText:message sender:[[PFUser currentUser] username] date:date];
        [_chatMessagesArray addObject:sentMessage];
        
        [self scrollToBottomAnimated:YES];
    }
    [self finishSendingMessage];
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    UIActionSheet* photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Exisiting Photo", nil];
    [photoSheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if (buttonIndex == 0) {
        //Take photo
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        //Choose Photo
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSData* imgData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.7);
        NSMutableData* data = [[NSMutableData alloc] init];
        NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:imgData];
        [archiver finishEncoding];
        
        BOOL sentSuccessful = [self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:nil];
        if (sentSuccessful) {
            //            JSQMessage* m = [[JSQMessage alloc] init];
            
            //            JSQMessage* sentMessage = [[JSQMessage alloc] initWithText:message sender:@"me" date:date];
            //            [_chatMessagesArray addObject:sentMessage];
            
            //            [self scrollToBottomAnimated:YES];
        }
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSQMessages CollectionView Datasource
-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_chatMessagesArray objectAtIndex:indexPath.item];
}

-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatMessagesArray[indexPath.row];
    if ([message.sender isEqualToString:[[PFUser currentUser] username]]) {
        return [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
    return [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    
    JSQMessage* message = _chatMessagesArray[indexPath.row];
    if ([message.sender isEqualToString:[PFUser currentUser].username]) {
        PFFile *file = [PFUser currentUser][@"picture"];
        iv.image = [UIImage imageWithData:[file getData]];
    } else {
        iv.image = [UIImage imageNamed:@"avatar-placeholder"];
//        iv.image = _friendsImage;
    }
    return iv;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _chatMessagesArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell* cell = (JSQMessagesCollectionViewCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage* msg = [_chatMessagesArray objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}
//
//-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
//        cell.bubbleView.textView.textColor = [UIColor whiteColor];
//
//        NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
//        [attrs setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
//
//        cell.bubbleView.textView.linkTextAttributes = attrs;
//    }
//
//    if (cell.timestampLabel) {
//        cell.timestampLabel.textColor = [UIColor lightGrayColor];
//        cell.timestampLabel.shadowOffset = CGSizeZero;
//    }
//
//    if (cell.subtitleLabel) {
//        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
//    }
//
//    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
//}
//
//-(BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 0) {
//        JSMessage* firstMessgae = _chatMessagesArray[0];
//        _lastShownTimeStamp = firstMessgae.date;
//        return YES;
//    }
//    JSMessage* message = _chatMessagesArray[indexPath.row];
//
//    NSTimeInterval timeDiff = [message.date timeIntervalSinceDate:_lastShownTimeStamp];
//
//    double mins = floor(timeDiff/60);
//    NSLog(@"%@", message.date);
//    NSLog(@"%@", _lastShownTimeStamp);
//    NSLog(@"%f", mins);
//    double secs = round(timeDiff - mins * 60);
//    if (mins > 1) {
//        _lastShownTimeStamp = message.date;
//        return YES;
//    }
//    return NO;
//}

@end
