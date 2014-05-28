//
//  FriendsChatViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "FriendsChatViewController.h"
#import <Parse/Parse.h>
#import <JSQMessages.h>

@interface FriendsChatViewController ()

@property (strong) NSMutableArray* chatArray;

@property (strong) NSTimer* timer;

@end

@implementation FriendsChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sender = [PFUser currentUser][kPFUser_FBID];
    
    _chatArray = [NSMutableArray new];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"notification" object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GAI trackWithScreenName:kScreenNameFriendsChat];
    [self loadChat];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_timer invalidate];
}

-(void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushNotificationRecieved:(NSNotification*)notification
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]== YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
    
    JSQMessage* message = [[JSQMessage alloc] initWithText:notification.userInfo[kNotificationMessage] sender:notification.userInfo[kNotificationSender][@"name"] date:[NSDate date]];
    [_chatArray addObject:message];
    [self finishReceivingMessage];
    //    [self scrollToBottomAnimated:YES];
}

-(void)loadChat
{
    PFQuery *innerQuery = [[PFQuery alloc] initWithClassName:kPFTableName_Chat];
    [innerQuery whereKey:kPFChatSender equalTo:[PFUser currentUser][kPFUser_FBID]];
    [innerQuery whereKey:kPFChatReciever equalTo:_friendDict[@"id"]];
    
    PFQuery* innerQuery2 = [[PFQuery alloc] initWithClassName:kPFTableName_Chat];
    [innerQuery2 whereKey:kPFChatSender equalTo:_friendDict[@"id"]];
    [innerQuery2 whereKey:kPFChatReciever equalTo:[PFUser currentUser][kPFUser_FBID]];
    
    PFQuery* query = [PFQuery orQueryWithSubqueries:@[innerQuery, innerQuery2]];
    query.limit = 10;
    
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_chatArray removeAllObjects];
        
        for (PFObject* object in objects) {
            JSQMessage* message = [[JSQMessage alloc] initWithText:object[kPFChatMessage] sender:object[kPFChatSender] date:object.createdAt];
            [_chatArray addObject:message];
        }
        _chatArray =  [[NSMutableArray alloc] initWithArray:[[_chatArray reverseObjectEnumerator] allObjects]];
        [self finishReceivingMessage];
    }];
}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    JSQMessage* message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    [_chatArray addObject:message];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }
    
    NSArray* recipients = @[_friendDict[@"id"]];
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" containedIn:recipients];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    
    NSMutableDictionary* pushData = [NSMutableDictionary dictionaryWithObjects:@[_friendDict, @{@"name": [PFUser currentUser].username, @"id":[PFUser currentUser][kPFUser_FBID]}] forKeys:@[kNotificationReceiever, kNotificationSender]];
    [pushData setObject:text forKey:kNotificationMessage];
    [pushData setObject:[NSString stringWithFormat:@"%@: %@", [PFUser currentUser].username, text] forKey:kNotificationAlert];
    [push setData:pushData];
    [push sendPushInBackground];
    
    PFObject *sendObjects = [PFObject objectWithClassName:kPFTableName_Chat];
    [sendObjects setObject:[NSString stringWithFormat:@"%@", text] forKey:kPFChatMessage];
    [sendObjects setObject:[PFUser currentUser][kPFUser_FBID] forKey:kPFChatSender];
    [sendObjects setObject:_friendDict[@"id"] forKey:kPFChatReciever];
    [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"save");
    }];
    
    [self scrollToBottomAnimated:YES];
    [self finishSendingMessage];
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
}

#pragma mark - JSQMessages CollectionView Datasource

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_chatArray objectAtIndex:indexPath.item];
}

-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatArray[indexPath.row];
    if ([message.sender isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
        return [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
    return [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = iv.frame.size.height / 2;
    iv.layer.masksToBounds = YES;
    
    JSQMessage* message = _chatArray[indexPath.row];
    if ([message.sender isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
        PFFile *file = [PFUser currentUser][kPFUser_Picture];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            iv.image = [UIImage imageWithData:data];
        }];
    } else {
        iv.image = _friendsImage;
    }
    return iv;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatArray[indexPath.item];
    //Show Date if it's the first message
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage* previousMessage = _chatArray[indexPath.item - 1];
        NSTimeInterval interval = [message.date timeIntervalSinceDate:previousMessage.date];
        int mintues = floor(interval/60);
        if (mintues >= 1) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
    }
    return nil;
}

//-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [[NSAttributedString alloc] initWithString:@" "];
//    JSQMessage* message = _chatArray[indexPath.item];
//    
//    if (indexPath.item - 1 > 0) {
//        JSQMessage* previousMessage = _chatArray[indexPath.item - 1];
//        if ([previousMessage.sender isEqualToString:message.sender]) {
//            return nil;
//        }
//    }
//    
//    if ([message.sender isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
//        NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[PFUser currentUser].username];
//        return attString;
//    } else {
//        NSAttributedString* attString = [[NSAttributedString alloc] initWithString:_friendDict[@"name"]];
//        return attString;
//    }
//}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _chatArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell* cell = (JSQMessagesCollectionViewCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage* msg = [_chatArray objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - JSQMessages collectionview flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldShowTimeStampAtIndex:indexPath]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0;
}

//-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self shouldShowTitleAtIndex:indexPath isSenderName:YES]) {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }
//    return 1;
//}

#pragma mark - Method checks if label should show

-(BOOL)shouldShowTimeStampAtIndex:(NSIndexPath*)index
{
    if (index.item == 0) {
        return true;
    }
    
    JSQMessage* message = _chatArray[index.item];
    if (index.item - 1 > 0) {
        JSQMessage* previousMessage = _chatArray[index.item - 1];
        
        
        NSTimeInterval interval = [message.date timeIntervalSinceDate:previousMessage.date];
        int mintues = floor(interval/60);
        if (mintues == 0) {
            return NO;
        }
    }
    return YES;
}

@end
