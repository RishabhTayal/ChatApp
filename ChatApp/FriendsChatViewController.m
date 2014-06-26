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
//#import "GroupInfoViewController.h"

@interface FriendsChatViewController ()

@property (strong) NSMutableArray* chatArray;

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
    if (_isGroupChat) {
        //TODO: Implement Group Info
//        UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//        [infoButton addTarget:self action:@selector(showGroupChatInfo:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    }
    
    if (_isGroupChat) {
        if ([Chat MR_findByAttribute:@"groupId" withValue:_groupObj.groupId].count == 0) {
            [self loadGroupChat];
        } else {
            _chatArray = [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"groupId" withValue:_groupObj.groupId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
            [self finishReceivingMessage];
            //TODO: Test Chat Loading Scenario
            [self loadGroupChat];
        }
    } else {
        if ([Chat MR_findByAttribute:@"friendId" withValue:_friendObj.fbId].count == 0) {
            [self loadFriendsChat];
        } else {
            _chatArray = [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"friendId" withValue:_friendObj.fbId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
            [self finishReceivingMessage];
        }
    }
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GAI trackWithScreenName:kScreenNameFriendsChat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushNotificationRecieved:(NSNotification*)notification
{
    if (notification.userInfo[kNotificationMessage] != NULL) {
        
        BOOL shouldAdd = NO;
        if (_isGroupChat) {
            if ([notification.userInfo[kNotificationPayload][kNotificationPayloadGroupId] isEqualToString:_groupObj.groupId]) {
                shouldAdd = true;
            }
        } else {
            if ([notification.userInfo[kNotificationSender][@"id"] isEqualToString:_friendObj.fbId] && ![notification.userInfo[kNotificationPayload][kNotificationPayloadIsGroupChat] boolValue]) {
                shouldAdd = true;
            }
        }
        
        if (shouldAdd) {
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppVibrate] boolValue]== YES) {
                [JSQSystemSoundPlayer jsq_playMessageReceivedAlert];
            } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            }

            JSQMessage* message = [[JSQMessage alloc] initWithText:notification.userInfo[kNotificationMessage] sender:notification.userInfo[kNotificationSender][@"id"] date:[NSDate date]];
            Chat* chatObj = [Chat MR_createEntity];
            chatObj.jsmessage = message;
            chatObj.updatedAt = message.date;
            [_chatArray addObject:chatObj];
            [self finishReceivingMessage];
        }
    }
}

-(void)loadFriendsChat
{
    PFQuery *innerQuery = [[PFQuery alloc] initWithClassName:kPFTableName_Chat];
    [innerQuery whereKey:kPFChatSender equalTo:[PFUser currentUser][kPFUser_FBID]];
    [innerQuery whereKey:kPFChatReciever equalTo:_friendObj.fbId];
    
    PFQuery* innerQuery2 = [[PFQuery alloc] initWithClassName:kPFTableName_Chat];
    [innerQuery2 whereKey:kPFChatSender equalTo:_friendObj.fbId];
    [innerQuery2 whereKey:kPFChatReciever equalTo:[PFUser currentUser][kPFUser_FBID]];
    
    PFQuery* query = [PFQuery orQueryWithSubqueries:@[innerQuery, innerQuery2]];
    query.limit = 20;
    
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_chatArray removeAllObjects];
        
        [Chat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"friendId = %@", _friendObj.fbId]];
        for (PFObject* object in objects) {
            JSQMessage* message = [[JSQMessage alloc] initWithText:object[kPFChatMessage] sender:object[kPFChatSender] date:object.createdAt];
            Chat* chatObj = [Chat MR_createEntity];
            chatObj.jsmessage = message;
            chatObj.friendId = _friendObj.fbId;
            chatObj.updatedAt = object.createdAt;
            [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
                _chatArray =  [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"friendId" withValue:_friendObj.fbId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
                [self finishReceivingMessage];
            }];
        }
    }];
}

-(void)loadGroupChat
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableGroup];
    [query getObjectWithId:_groupObj.groupId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject* groupObject = (PFObject*) [objects firstObject];
        //Get Members
        PFRelation* membersRelation = [groupObject relationForKey:kPFGroupMembers];
        [[membersRelation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSMutableArray* tempMembersArray = [NSMutableArray new];
            for (PFUser* member in objects) {
                NSMutableDictionary* dict = [NSMutableDictionary new];
                [dict setObject:member[kPFUser_FBID] forKey:kPFUser_FBID];
                [dict setObject:member[kPFUser_Username] forKey:kPFUser_Username];
                
                PFFile* file = member[kPFUser_Picture];
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    UIImage* img = [UIImage imageWithData:data];
                    [dict setObject:img forKey:kPFUser_Picture];
                    [tempMembersArray addObject:dict];
//                    [self finishReceivingMessage];
                    [self.collectionView reloadData];
                }];
            }
            
            _groupObj.members = tempMembersArray;
            [CoreDataHelper savePersistentCompletionBlock:nil];
        }];
        
        //Get Chats
        PFRelation* chatRelation = [groupObject relationForKey:@"chats"];
        
        PFQuery* chatQuery = [chatRelation query];
        chatQuery.limit = 20;
        
        [chatQuery orderByDescending:@"createdAt"];
        
        [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [Chat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"groupId = %@", _groupObj.groupId]];
            for (PFObject* chat in objects) {
                JSQMessage* message = [[JSQMessage alloc] initWithText:chat[kPFChatMessage] sender:chat[kPFChatSender] date:chat.createdAt];
                Chat* chatObj = [Chat MR_createEntity];
                chatObj.jsmessage = message;
                chatObj.groupId = _groupObj.groupId;
                chatObj.updatedAt = chat.createdAt;
                //chatObj.chatGroup
                [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
                    _chatArray = [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"groupId" withValue:_groupObj.groupId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
                    [self finishReceivingMessage];
                }];
            }
        }];
    }];
}

//TODO: uncomment to Implement Group Info Functionality
//-(void)showGroupChatInfo:(id)sender
//{
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    GroupInfoViewController* groupInfoVC = [sb instantiateViewControllerWithIdentifier:@"GroupInfoViewController"];
//    [self.navigationController pushViewController:groupInfoVC animated:YES];
//}

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    JSQMessage* message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    
    Chat* chatObj = [Chat MR_createEntity];
    chatObj.jsmessage = message;
    chatObj.groupId = _groupObj.groupId;
    chatObj.updatedAt = message.date;
    [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
        [_chatArray addObject:chatObj];
        [self scrollToBottomAnimated:YES];
        [self finishSendingMessage];
    }];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUDInAppSound] boolValue] == YES) {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
    }
    
    if (_isGroupChat) {
        [self sendChatToGroup:text];
    } else {
        [self sendChatToFriend:text];
    }
    
    [GAI trackEventWithCategory:kGAICategoryButton action:kGAIActionMessageSent label:@"friends" value:nil];
    
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    DLog(@"Camera pressed!");
}

-(void)sendChatToFriend:(NSString*)text
{
    NSArray* recipients = @[_friendObj.fbId];
    
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" containedIn:recipients];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    
    NSMutableDictionary* pushData = [NSMutableDictionary dictionaryWithObjects:@[@{@"name": [PFUser currentUser].username, @"id":[PFUser currentUser][kPFUser_FBID]}] forKeys:@[kNotificationSender]];
    [pushData setObject:text forKey:kNotificationMessage];
    [pushData setObject:[NSString stringWithFormat:@"%@: %@", [PFUser currentUser].username, text] forKey:kNotificationAlert];
    [pushData setObject:[NSNumber numberWithBool:YES] forKey:@"groupMessage"];
    [pushData setObject:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO]] forKeys:@[kNotificationPayloadIsGroupChat]] forKey:kNotificationPayload];
    [push setData:pushData];
    [push sendPushInBackground];
    
    PFObject *sendObjects = [PFObject objectWithClassName:kPFTableName_Chat];
    [sendObjects setObject:[NSString stringWithFormat:@"%@", text] forKey:kPFChatMessage];
    [sendObjects setObject:[PFUser currentUser][kPFUser_FBID] forKey:kPFChatSender];
    [sendObjects setObject:_friendObj.fbId forKey:kPFChatReciever];
    [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        DLog(@"save");
    }];
}

-(void)sendChatToGroup:(NSString*)text
{
    //    PFObject* object = (PFObject*)_friendDict;
    PFQuery* query = [PFQuery queryWithClassName:kPFTableGroup];
    [query getObjectWithId:_groupObj.groupId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject* groupObject = (PFObject*)[objects firstObject];
        
        
        PFRelation* relation = [groupObject relationForKey:kPFGroupMembers];
        [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFQuery* pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"owner" containedIn:[objects valueForKey:kPFUser_FBID]];
            [pushQuery whereKey:@"owner" notEqualTo:[PFUser currentUser][kPFUser_FBID]];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            
            NSMutableDictionary* pushData = [NSMutableDictionary dictionaryWithObjects:@[@{@"name": [PFUser currentUser].username, @"id":[PFUser currentUser][kPFUser_FBID]}] forKeys:@[kNotificationSender]];
            [pushData setObject:text forKey:kNotificationMessage];
            [pushData setObject:[NSString stringWithFormat:@"%@ @ \"%@\": %@", [PFUser currentUser].username, groupObject[kPFGroupName] ,text] forKey:kNotificationAlert];
            [pushData setObject:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], _groupObj.groupId] forKeys:@[kNotificationPayloadIsGroupChat, kNotificationPayloadGroupId]] forKey:kNotificationPayload];
            [push setData:pushData];
            [push sendPushInBackground];
            
            PFObject* object = [PFObject objectWithClassName:kPFTableName_Chat];
            [object setObject:text forKey:kPFChatMessage];
            [object setObject:[PFUser currentUser][kPFUser_FBID] forKey:kPFChatSender];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //                PFObject* groupObject = (PFObject*) _friendDict;
                    PFRelation* relation = [groupObject relationForKey:@"chats"];
                    [relation addObject:object];
                    [groupObject saveEventually];
                }
            }];
        }];
    }];
}

#pragma mark - JSQMessages CollectionView Datasource

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = ((Chat*) _chatArray[indexPath.item]).jsmessage;
    return message;
}

-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = ((Chat*) _chatArray[indexPath.row]).jsmessage;
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
    
    JSQMessage* message = ((Chat*)_chatArray[indexPath.row]).jsmessage;
    if ([message.sender isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
        PFFile *file = [PFUser currentUser][kPFUser_Picture];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            iv.image = [UIImage imageWithData:data];
        }];
    } else {
        if (_isGroupChat) {
            for (NSDictionary* dict in _groupObj.members) {
                if ([dict[kPFUser_FBID] isEqualToString:message.sender]) {
                    iv.image = dict[kPFUser_Picture];
                }
            }
        } else {
            iv.image = _friendsImage;
        }
    }
    return iv;
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = ((Chat*) _chatArray[indexPath.item]).jsmessage;
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isGroupChat) {
        
        JSQMessage* message = ((Chat*)_chatArray[indexPath.item]).jsmessage;
        
        if ([message.sender isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
            NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[PFUser currentUser].username];
            return attString;
        } else {
            for (NSDictionary* dict in _groupObj.members) {
                if ([dict[kPFUser_FBID] isEqualToString:message.sender]) {
                    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:dict[kPFUser_Username]];
                    return attString;
                }
            }
        }
    }
    return nil;
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
    
    JSQMessage* msg = ((Chat*) [_chatArray objectAtIndex:indexPath.item]).jsmessage;
    
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

-(CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isGroupChat) {
        if ([self shouldShowTimeStampAtIndex:indexPath]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    return 0;
}

#pragma mark - Method checks if label should show

-(BOOL)shouldShowTitleAtIndex:(NSIndexPath*)index
{
    if (index.item == 0) {
        return true;
    }
    
    JSQMessage* message = ((Chat*) _chatArray[index.item]).jsmessage;
    if (index.item - 1 >= 0) {
        JSQMessage* previousMessage = ((Chat*) _chatArray[index.item - 1]).jsmessage;
        if ([message.sender isEqualToString:previousMessage.sender]) {
            return false;
        }
    }
    return true;
}

-(BOOL)shouldShowTimeStampAtIndex:(NSIndexPath*)index
{
    if (index.item == 0) {
        return true;
    }
    
    JSQMessage* message = ((Chat*)_chatArray[index.item]).jsmessage;
    if (index.item - 1 >= 0) {
        JSQMessage* previousMessage = ((Chat*) _chatArray[index.item - 1]).jsmessage;
        NSTimeInterval interval = [message.date timeIntervalSinceDate:previousMessage.date];
        int mintues = floor(interval/60);
        if (mintues < 5) {
            return NO;
        }
    }
    return YES;
}

@end
