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
#import "DropDownView.h"
#import <UINavigationBar+Addition/UINavigationBar+Addition.h>
#import "AppDelegate.h"
#import "InAppNotificationView.h"
#import "MenuViewController.h"
#import <StoreKit/StoreKit.h>
#import "VCinity-Swift.h"

@interface NearChatViewController ()

@property (strong) NSMutableArray* chatMessagesArray;
@property (strong) NSMutableArray* senderImageArray;

@property (strong) SessionController* sessionController;

@property (strong) NSDate* lastShownTimeStamp;

@property (strong) NSData* myImageData;

@end

@implementation NearChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"vCinity Chat", nil);
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _chatMessagesArray = [NSMutableArray new];
    _senderImageArray = [NSMutableArray new];
    
    //    _sessionController = [[SessionController alloc] initWithDelegate:self];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _sessionController = appDelegate.sessionController;
    
    self.senderDisplayName = _sessionController.displayName;
    self.senderId = _sessionController.displayName;
    
    //    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    PFFile *file = [PFUser currentUser][kPFUser_Picture];
    if (file) {
        _myImageData = [file getData];
    } else {
        _myImageData = UIImagePNGRepresentation([UIImage imageNamed:@"avatar-placeholder.png"]);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [GAI trackWithScreenName:kScreenNameNearChat];
    
    [self.navigationController.navigationBar hideBottomHairline];
    if (_sessionController.connectedPeers.count == 0 ) {
        [DropDownView showInViewController:self withText:[NSString stringWithFormat:NSLocalizedString(@"No users nearby", nil)] height:DropDownViewHeightDefault hideAfterDelay:0];
    } else {
        if (_sessionController.connectedPeers.count == 1) {
            [DropDownView showInViewController:self withText:[NSString stringWithFormat:NSLocalizedString(@"Connected to %d recipient", nil), [_sessionController connectedPeers].count] height:DropDownViewHeightDefault hideAfterDelay:0];
        } else {
            [DropDownView showInViewController:self withText:[NSString stringWithFormat:NSLocalizedString(@"Connected to %d recipients", nil), [_sessionController connectedPeers].count] height:DropDownViewHeightDefault hideAfterDelay:0];
        }
    }
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate displayAdMobInViewController:self];
    
    if (![NSUserDefaults isNearChatCoachmarkShown]) {
        DLog(@"show coachmark");
        NSArray* coachmarks = @[@{@"rect": [NSValue valueWithCGRect:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, DropDownViewHeightDefault)], @"caption": @"People around you using vCinity will be automatically connected."}, @{@"rect": [NSValue valueWithCGRect:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 60, 50)], @"caption" :@"Navigate to other options"}];
        WSCoachMarksView* cmView = [[WSCoachMarksView alloc] initWithFrame:self.view.frame coachMarks:coachmarks];
        [self.navigationController.view addSubview:cmView];
        [cmView start];
        [NSUserDefaults setNearChatCoachmarkShown];
    }
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
            if (_sessionController.connectedPeers.count == 1) {
                [DropDownView setNotificationText:[NSString stringWithFormat:NSLocalizedString(@"Connected to %d recipient", nil), [_sessionController connectedPeers].count]];
            } else {
                [DropDownView setNotificationText:[NSString stringWithFormat:NSLocalizedString(@"Connected to %d recipients", nil), [_sessionController connectedPeers].count]];
            }
            
        } else {
            [DropDownView setNotificationText:NSLocalizedString(@"No users nearby", nil)];
        }
    });
}

-(void)sessionDidRecieveData:(NSData *)data fromPeer:(NSString *)peerName
{
    NSKeyedUnarchiver* unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //    unArchiver.requiresSecureCoding = YES;
    id object = [unArchiver decodeObject];
    [unArchiver finishDecoding];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]== YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
    
    id message = [object objectForKey:@"data"];
    NSData* imageData = [object objectForKey:@"senderImage"];
    if (imageData == nil) {
        imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"avatar-placeholder"], 1.0);
    }
    //    NSMutableDictionary* dict = [NSMutableDictionary new];
    //    [dict setObject:imageData forKey:@"senderImage"];
    //    [dict setObject:peerName forKey:@"sender"];
    [_senderImageArray addObject:imageData];
    
    //    JSQMessage* messagObj = [[JSQMessage alloc] initWithText:message sender:peerName date:[NSDate date]];
    JSQMessage* messageObj = nil;
    if ([message isKindOfClass:[NSString class]]) {
        messageObj = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:peerName date:[NSDate date] text:message];
    } else {
        JSQPhotoMediaItem* media = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:message]];
        messageObj = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:peerName date:[NSDate date] media:media];
    }
//    JSQMessage* messageObj = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:peerName date:[NSDate date] text:message];
    [_chatMessagesArray addObject:messageObj];
    //    if ([object isKindOfClass:[NSString class]]) {
    //        NSString* message = object;
    //
    //        JSQMessage* messageObj = [[JSQMessage alloc] initWithText:message sender:peerName date:[NSDate date]];
    //        [_chatMessagesArray addObject:messageObj];
    //    } else {
    //        UIImage* image = [UIImage imageWithData:object];
    //    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self shouldShowInAppNotification]) {
            [self showInappNotificationWithText:peerName detail:message image:[UIImage imageWithData:imageData]];
        }
        [self finishReceivingMessage];
        [self scrollToBottomAnimated:YES];
    });
}

#pragma mark - Sending Data

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    
    [ReviewRequest showReview];
    [[self view] endEditing: true];
    DLog(@"sent");
    NSString* message = text;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }
    
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    NSMutableDictionary* messageDict = [[NSMutableDictionary alloc] init];
    [messageDict setObject:message forKey:@"data"];
    [messageDict setObject:_myImageData forKey:@"senderImage"];
    
    [archiver encodeObject:messageDict];
    [archiver finishEncoding];
    
    NSError* error = nil;
    if (![_sessionController sendData:data]) {
        DLog(@"%@", error);
    } else {
        
        //        NSMutableDictionary* dict = [NSMutableDictionary new];
        //        [dict setObject:_myImageData forKey:@"senderImage"];
        //        [dict setObject:_sessionController.displayName forKey:@"sender"];
        [_senderImageArray addObject:_myImageData];
        
        //        JSQMessage* sentMessage = [[JSQMessage alloc] initWithText:message sender:_sessionController.displayName date:date];
        JSQMessage* sentMessage = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:_sessionController.displayName date:date text:message];
        [_chatMessagesArray addObject:sentMessage];
        
        [self scrollToBottomAnimated:YES];
        [GAI trackEventWithCategory:kGAICategoryButton action:kGAIActionMessageSent label:@"near_chat" value:nil];
    }
    [self finishSendingMessage];
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    UIAlertController* photoSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [photoSheet addAction:[UIAlertAction actionWithTitle:@"Choose Exisiting Photo" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //Choose Photo
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [photoSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //Take photo
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];

    }]];
    [photoSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:photoSheet animated:true completion:nil];
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSData* imgData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.7);
        NSMutableData* data = [[NSMutableData alloc] init];
        NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:imgData, @"data", nil];
        [archiver encodeObject:dictionary];
        [archiver finishEncoding];
        
        BOOL sentSuccessful = [_sessionController sendData:data];
        if (sentSuccessful) {
            [_senderImageArray addObject:_myImageData];

            JSQPhotoMediaItem* mediaData = [[JSQPhotoMediaItem alloc] initWithImage:info[UIImagePickerControllerOriginalImage]];
            JSQMessage* sentMessage = [[JSQMessage alloc] initWithSenderId:@"" senderDisplayName:self.senderDisplayName date:[NSDate date] media:mediaData];
            [_chatMessagesArray addObject:sentMessage];
            
            [self scrollToBottomAnimated:YES];
            [self finishSendingMessage];

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

//-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    JSQMessage* message = _chatMessagesArray[indexPath.row];
//    if ([message.senderDisplayName isEqualToString:self.senderDisplayName]) {
//        return [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
//    }
//    return [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
//}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatMessagesArray[indexPath.row];
    JSQMessagesBubbleImageFactory* bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([message.senderDisplayName isEqualToString:self.senderDisplayName]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

//-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    iv.contentMode = UIViewContentModeScaleAspectFill;
//    iv.clipsToBounds = YES;
//    iv.layer.cornerRadius = iv.frame.size.height / 2;
//    iv.layer.masksToBounds = YES;
//
//    iv.image = [UIImage imageWithData:[_senderImageArray objectAtIndex:indexPath.item]];
//    return iv;
//}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesAvatarImage* avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:_senderImageArray[indexPath.item]] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return avatar;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatMessagesArray[indexPath.item];
    //Show Date if it's the first message
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage* previousMessage = _chatMessagesArray[indexPath.item - 1];
        NSTimeInterval interval = [message.date timeIntervalSinceDate:previousMessage.date];
        int mintues = floor(interval/60);
        if (mintues >= 1) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
    }
    return nil;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* messgae = [_chatMessagesArray objectAtIndex:indexPath.item];
    if (indexPath.item == 0) {
        return [[NSAttributedString alloc] initWithString:messgae.senderDisplayName];
    }
    
    if (indexPath.item - 1 >= 0) {
        JSQMessage *previousMessage = _chatMessagesArray[indexPath.item - 1];
        if ([previousMessage.senderDisplayName isEqualToString:messgae.senderDisplayName]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:messgae.senderDisplayName];;
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
    
    if ([msg.senderDisplayName isEqualToString:self.senderDisplayName]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - JSQMessages collectionview flow layout delegate

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldShowTitleAtIndex:indexPath isSenderName:YES]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return NO;
}

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldShowTitleAtIndex:indexPath isSenderName:NO]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0;
}

#pragma mark -

-(BOOL)shouldShowInAppNotification
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    UIViewController* currentVC = ((UINavigationController*)((MFSideMenuContainerViewController*)window.rootViewController).centerViewController).visibleViewController;
    DLog(@"%@", currentVC);
    if ([currentVC isKindOfClass:[NearChatViewController class]]) {
        return NO;
    }
    return YES;
}

-(void)showInappNotificationWithText:(NSString*)text detail:(NSString*)detail image:(UIImage*)image
{
    [[InAppNotificationView sharedInstance] notifyWithText:text detail:detail image:image duration:3 andTouchBlock:^(InAppNotificationView *view) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        MFSideMenuContainerViewController* currentVC = ((MFSideMenuContainerViewController*)appDelegate.window.rootViewController);
        UINavigationController* navC = (UINavigationController*)currentVC.leftMenuViewController;
        MenuViewController* menuVC = (MenuViewController*)navC.topViewController;
        [menuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [menuVC tableView:menuVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }];
}

#pragma mark - Method checks if label should show

-(BOOL)shouldShowTitleAtIndex:(NSIndexPath*)index isSenderName:(BOOL)isSenderName
{
    if (index.item == 0) {
        return true;
    }
    
    JSQMessage* message = _chatMessagesArray[index.item];
    if (index.item - 1 >= 0) {
        JSQMessage* previousMessage = _chatMessagesArray[index.item - 1];
        
        if (isSenderName) {
            if ([message.senderDisplayName isEqualToString:previousMessage.senderDisplayName]) {
                return NO;
            }
        } else {
            NSTimeInterval interval = [message.date timeIntervalSinceDate:previousMessage.date];
            int mintues = floor(interval/60);
            if (mintues == 0) {
                return NO;
            }
        }
    }
    return YES;
}

@end
