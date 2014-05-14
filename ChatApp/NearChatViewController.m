//
//  ViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/1/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "NearChatViewController.h"
#import "SettingsViewController.h"
#import <JSQMessages.h>
#import "MenuButton.h"
#import <MFSideMenu.h>
#import <Parse/Parse.h>
#import "NotificationView.h"
#import <UINavigationBar+Addition/UINavigationBar+Addition.h>
#import "AppDelegate.h"

@interface NearChatViewController ()

@property (strong) NSMutableArray* chatMessagesArray;

@property (strong) SessionController* sessionController;

@property (strong) NSDate* lastShownTimeStamp;

@end

@implementation NearChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"vCinity Chat";
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _chatMessagesArray = [NSMutableArray new];
    
//    _sessionController = [[SessionController alloc] initWithDelegate:self];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _sessionController = appDelegate.sessionController;
    
    self.sender = _sessionController.displayName;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    [self.navigationController.navigationBar hideBottomHairline];
    
    if (_sessionController.connectedPeers.count == 0 ) {
        [NotificationView showInViewController:self withText:[NSString stringWithFormat:@"No users nearby"] hideAfterDelay:0];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)sessionDidChangeState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_sessionController.connectedPeers.count > 0) {
            [NotificationView hide];
            [NotificationView showInViewController:self withText:[NSString stringWithFormat:@"connected to %d users", [_sessionController connectedPeers].count] hideAfterDelay:3];
        } else {
            [NotificationView showInViewController:self withText:[NSString stringWithFormat:@"No users nearby"] hideAfterDelay:0];
        }
    });
}

-(void)sessionDidRecieveData:(NSData *)data fromPeer:(NSString *)peerName
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]== YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
    
    NSKeyedUnarchiver* unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //    unArchiver.requiresSecureCoding = YES;
    id object = [unArchiver decodeObject];
    [unArchiver finishDecoding];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString* message = object;
        
        JSQMessage* messageObj = [[JSQMessage alloc] initWithText:message sender:peerName date:[NSDate date]];
        [_chatMessagesArray addObject:messageObj];
    } else {
        UIImage* image = [UIImage imageWithData:object];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finishReceivingMessage];
        [self scrollToBottomAnimated:YES];
    });
}

#pragma mark - Sending Data

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    NSLog(@"sent");
    NSString* message = text;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }
    
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:message];
    [archiver finishEncoding];
    
    NSError* error = nil;
    if (![_sessionController sendData:data]) {
        NSLog(@"%@", error);
    } else {
        JSQMessage* sentMessage = [[JSQMessage alloc] initWithText:message sender:_sessionController.displayName date:date];
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
        
        BOOL sentSuccessful = [_sessionController sendData:data];
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
    if ([message.sender isEqualToString:self.sender]) {
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
    if ([message.sender isEqualToString:self.sender]) {
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
    JSQMessage* messgae = [_chatMessagesArray objectAtIndex:indexPath.item];
    return [[NSAttributedString alloc] initWithString:messgae.sender];
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

#pragma mark - JSQMessages collectionview flow layout delegate

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
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
