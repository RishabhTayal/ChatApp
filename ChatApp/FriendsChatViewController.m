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
    
    self.sender = [PFUser currentUser][@"fbID"];
    
    _chatArray = [NSMutableArray new];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"notification" object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    JSQMessage* message = [[JSQMessage alloc] initWithText:notification.userInfo[@"message"] sender:notification.userInfo[@"sender"] date:[NSDate date]];
    [_chatArray addObject:message];
    [self finishReceivingMessage];
    //    [self scrollToBottomAnimated:YES];
}

-(void)loadChat
{
    PFQuery *innerQuery = [[PFQuery alloc] initWithClassName:@"Wechat"];
    [innerQuery whereKey:@"sender" equalTo:[PFUser currentUser][@"fbID"]];
    [innerQuery whereKey:@"receiver" equalTo:_friendDict[@"id"]];
    
    PFQuery* innerQuery2 = [[PFQuery alloc] initWithClassName:@"Wechat"];
    [innerQuery2 whereKey:@"sender" equalTo:_friendDict[@"id"]];
    [innerQuery2 whereKey:@"receiver" equalTo:[PFUser currentUser][@"fbID"]];
    
    PFQuery* query = [PFQuery orQueryWithSubqueries:@[innerQuery, innerQuery2]];
    query.limit = 10;

    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_chatArray removeAllObjects];
        
        for (PFObject* object in objects) {
            JSQMessage* message = [[JSQMessage alloc] initWithText:object[@"msg"] sender:object[@"sender"] date:object.createdAt];
            [_chatArray addObject:message];
        }
        _chatArray =  [[NSMutableArray alloc] initWithArray:[[_chatArray reverseObjectEnumerator] allObjects]];
        [self finishReceivingMessage];
        //        [self scrollToBottomAnimated:YES];
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
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:@[text, _friendDict[@"name"]] forKeys:@[@"message", @"sender"]];
    [push setData:dict];
//    [push setMessage:text];
    [push sendPushInBackground];
    
    PFObject *sendObjects = [PFObject objectWithClassName:@"Wechat"];
    [sendObjects setObject:[NSString stringWithFormat:@"%@", text] forKey:@"msg"];
    [sendObjects setObject:[PFUser currentUser][@"fbID"] forKey:@"sender"];
    [sendObjects setObject:_friendDict[@"id"] forKey:@"receiver"];
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
    if ([message.sender isEqualToString:[PFUser currentUser][@"fbID"]]) {
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
    if ([message.sender isEqualToString:[PFUser currentUser][@"fbID"]]) {
        PFFile *file = [PFUser currentUser][@"picture"];
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
    return nil;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = _chatArray[indexPath.item];
    if ([message.sender isEqualToString:[PFUser currentUser][@"fbID"]]) {
        NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[PFUser currentUser].username];
        return attString;
    } else {
        NSAttributedString* attString = [[NSAttributedString alloc] initWithString:_friendDict[@"name"]];
        return attString;
    }
}

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

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

@end
