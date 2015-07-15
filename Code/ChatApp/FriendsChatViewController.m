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
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "DropDownView.h"

@interface FriendsChatViewController ()

@property (strong) NSMutableArray* chatArray;

@end

@implementation FriendsChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.senderId = [PFUser currentUser][kPFUser_FBID];
    
    _chatArray = [NSMutableArray new];
    
    //    self.inputToolbar.contentView.leftBarButtonItem = nil;
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
            [self loadFriendsChat];
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
    if (notification.userInfo[kNotificationMessage] != NULL || notification.userInfo[kNotificationMediaUrl]) {
        
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
            
            //            JSQMessage* message = [[JSQMessage alloc] initWithText:notification.userInfo[kNotificationMessage] sender:notification.userInfo[kNotificationSender][@"id"] date:[NSDate date]];
            __block JSQMessage* message = nil;
            Chat* chatObj = [Chat MR_createEntity];
            if ([notification.userInfo[kNotificationIsMedia] boolValue]) {
                AFHTTPRequestOperation* request = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:notification.userInfo[kNotificationMediaUrl]]]];
                request.responseSerializer = [AFImageResponseSerializer serializer];
                [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    JSQPhotoMediaItem* media = [[JSQPhotoMediaItem alloc] initWithImage:responseObject];
                    message = [[JSQMessage alloc] initWithSenderId:notification.userInfo[kNotificationSender][@"id"] senderDisplayName:notification.userInfo[kNotificationSender][@"name"] date:[NSDate date] media:media];
                    chatObj.jsmessage = message;
                    chatObj.updatedAt = message.date;
                    [_chatArray addObject:chatObj];
                    [self finishReceivingMessage];
                } failure:nil];
                [request start];
            } else {
                message = [[JSQMessage alloc] initWithSenderId:notification.userInfo[kNotificationSender][@"id"] senderDisplayName:notification.userInfo[kNotificationSender][@"name"] date:[NSDate date] text:notification.userInfo[kNotificationMessage]];
                chatObj.jsmessage = message;
                chatObj.updatedAt = message.date;
                [_chatArray addObject:chatObj];
                [self finishReceivingMessage];
            }
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
        //        [_chatArray removeAllObjects];
        //        _chatArray = [NSMutableArray new];
        
        [Chat MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"friendId = %@", _friendObj.fbId]];
        if (objects.count != 0) {
            for (int i = 0; i < objects.count; i++) {
                PFObject* object = objects[i];
                __block JSQMessage* message = nil;
                Chat* chatObj = [Chat MR_createEntity];
                chatObj.friendId = _friendObj.fbId;
                chatObj.updatedAt = object.createdAt;
                
                if (object[kPFChatIsMedia]) {
                    PFFile* mediaFile = object[kPFChatMedia];
                    [mediaFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        JSQPhotoMediaItem* mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:data]];
                        message = [[JSQMessage alloc] initWithSenderId:object[kPFChatSender] senderDisplayName:@"" date:object.createdAt media:mediaItem];
                        chatObj.jsmessage = message;
                        
                        [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
                            DLog(@"SAVED TO PERSISTENT - media");
                            if (i == objects.count - 1) {
                                _chatArray =  [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"friendId" withValue:_friendObj.fbId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
                                [self finishReceivingMessage];
                            }
                        }];
                    }];
                } else {
                    message = [[JSQMessage alloc] initWithSenderId:object[kPFChatSender] senderDisplayName:@"" date:object.createdAt text:object[kPFChatMessage]];
                    chatObj.jsmessage = message;
                    if (chatObj.jsmessage == nil) {
                        DLog(@"Nil found");
                    }
                    [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
                        DLog(@"SAVED TO PERSISTENT");
                        if (i == objects.count - 1) {
                            _chatArray =  [[NSMutableArray alloc] initWithArray:[[[Chat MR_findByAttribute:@"friendId" withValue:_friendObj.fbId andOrderBy:@"updatedAt" ascending:NO] reverseObjectEnumerator] allObjects]];
                            [self finishReceivingMessage];
                        }
                    }];
                }
            }
        } else {
            [DropDownView showInViewController:self withText:@"Start a conversation" height:DropDownViewHeightDefault hideAfterDelay:2.0];
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
                [dict setObject:member[kPFUser_Name] forKey:kPFUser_Name];
                
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
                //                JSQMessage* message = [[JSQMessage alloc] initWithText:chat[kPFChatMessage] sender:chat[kPFChatSender] date:chat.createdAt];
                JSQMessage* message = [[JSQMessage alloc] initWithSenderId:chat[kPFChatSender] senderDisplayName:@"" date:chat.createdAt text:chat[kPFChatMessage]];
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

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    //    JSQMessage* message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    JSQMessage* message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    
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
        [self sendChatToGroupWithJSQMessage:message];
    } else {
        [self sendChatToFriendWithJSMessage:message];
    }
    
    [GAI trackEventWithCategory:kGAICategoryButton action:kGAIActionMessageSent label:@"friends" value:nil];
    
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet* photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Exisiting Photo", nil), nil];
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
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:imgData, @"data", nil];
        [archiver encodeObject:dictionary];
        [archiver finishEncoding];
        
        JSQPhotoMediaItem* media = [[JSQPhotoMediaItem alloc] initWithImage:info[UIImagePickerControllerOriginalImage]];
        JSQMessage* message = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] media:media];
        
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
            [self sendChatToGroupWithJSQMessage:message];
        } else {
            [self sendChatToFriendWithJSMessage:message];
        }
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendChatToFriendWithJSMessage:(JSQMessage*)message
{
    NSArray* recipients = @[_friendObj.fbId];
    
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" containedIn:recipients];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    
    NSMutableDictionary* pushData = [NSMutableDictionary dictionaryWithObjects:@[@{@"name": [PFUser currentUser][kPFUser_Name], @"id":[PFUser currentUser][kPFUser_FBID]}] forKeys:@[kNotificationSender]];
    //    [pushData setObject:text forKey:kNotificationMessage];
    if (message.isMediaMessage) {
        [pushData setObject:[NSNumber numberWithBool:YES] forKey:kNotificationIsMedia];
        //        [pushData setObject:message.media forKey:kNotificationMessage];
        [pushData setObject:[NSString stringWithFormat:@"%@ sent you an attachment", [PFUser currentUser][kPFUser_Name]] forKey:kNotificationAlert];
    } else {
        [pushData setObject:[NSNumber numberWithBool:NO] forKey:kNotificationIsMedia];
        [pushData setObject:message.text forKey:kNotificationMessage];
        [pushData setObject:[NSString stringWithFormat:@"%@: %@", [PFUser currentUser][kPFUser_Name], message.text] forKey:kNotificationAlert];
    }
    
    [pushData setObject:[NSNumber numberWithBool:YES] forKey:@"groupMessage"];
    [pushData setObject:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO]] forKeys:@[kNotificationPayloadIsGroupChat]] forKey:kNotificationPayload];
    
    PFObject *sendObjects = [PFObject objectWithClassName:kPFTableName_Chat];
    [sendObjects setObject:[PFUser currentUser][kPFUser_FBID] forKey:kPFChatSender];
    [sendObjects setObject:_friendObj.fbId forKey:kPFChatReciever];
    if (message.isMediaMessage) {
        id<JSQMessageMediaData> copyMedia = message.media;
        NSData* data= UIImageJPEGRepresentation(((JSQPhotoMediaItem*) copyMedia).image, 1.0);
        PFFile* imageFile = [PFFile fileWithName:@"attachment.jpg" data:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [sendObjects setObject:[NSNumber numberWithBool:YES] forKey:kPFChatIsMedia];
            [sendObjects setObject:imageFile forKey:kPFChatMedia];
            [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [pushData setObject:imageFile.url forKey:kNotificationMediaUrl];
                [push setData:pushData];
                [push sendPushInBackground];
            }];
        }];
    } else {
        [sendObjects setObject:[NSString stringWithFormat:@"%@", message.text] forKey:kPFChatMessage];
        [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            DLog(@"save");
            [push setData:pushData];
            [push sendPushInBackground];
        }];
    }
}

-(void)sendChatToGroupWithJSQMessage:(JSQMessage*)message
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
            
            NSMutableDictionary* pushData = [NSMutableDictionary dictionaryWithObjects:@[@{@"name": [PFUser currentUser][kPFUser_Name], @"id":[PFUser currentUser][kPFUser_FBID]}] forKeys:@[kNotificationSender]];
            //            [pushData setObject:text forKey:kNotificationMessage];
            if (message.isMediaMessage) {
                [pushData setObject:[NSNumber numberWithBool:YES] forKey:kNotificationIsMedia];
                [pushData setObject:[NSString stringWithFormat:@"%@ @ \"%@\" sent you an attachment", [PFUser currentUser][kPFUser_Name], groupObject[kPFGroupName]] forKey:kNotificationAlert];
            } else {
                [pushData setObject:[NSNumber numberWithBool:NO] forKey:kNotificationIsMedia];
                [pushData setObject:message.text forKey:kNotificationMessage];
                [pushData setObject:[NSString stringWithFormat:@"%@ @ \"%@\": %@", [PFUser currentUser][kPFUser_Name], groupObject[kPFGroupName] , message.text] forKey:kNotificationAlert];
            }
            [pushData setObject:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], _groupObj.groupId] forKeys:@[kNotificationPayloadIsGroupChat, kNotificationPayloadGroupId]] forKey:kNotificationPayload];
            [push setData:pushData];
            
            PFObject* object = [PFObject objectWithClassName:kPFTableName_Chat];
            [object setObject:[PFUser currentUser][kPFUser_FBID] forKey:kPFChatSender];
            if (message.isMediaMessage) {
                id<JSQMessageMediaData> copyMedia = message.media;
                NSData* data= UIImageJPEGRepresentation(((JSQPhotoMediaItem*) copyMedia).image, 1.0);
                PFFile* imageFile = [PFFile fileWithName:@"attachment.jpg" data:data];
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [object setObject:[NSNumber numberWithBool:YES] forKey:kPFChatIsMedia];
                    [object setObject:imageFile forKey:kPFChatMedia];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            PFRelation* relation = [groupObject relationForKey:@"chats"];
                            [relation addObject:object];
                            [groupObject saveEventually];
                        }
                        [pushData setObject:imageFile.url forKey:kNotificationMediaUrl];
                        [push setData:pushData];
                        [push sendPushInBackground];
                    }];
                }];
                
            } else {
                [object setObject:message.text forKey:kPFChatMessage];
                [object setObject:[NSNumber numberWithBool:NO] forKey:kPFChatIsMedia];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFRelation* relation = [groupObject relationForKey:@"chats"];
                        [relation addObject:object];
                        [groupObject saveEventually];
                    }
                    [push sendPushInBackground];
                }];
            }
        }];
    }];
}

#pragma mark - JSQMessages CollectionView Datasource

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Chat* chat = _chatArray[indexPath.item];
    JSQMessage* message = chat.jsmessage;
    if (message == nil) {
        NSLog(@"nil found");
        message = [[JSQMessage alloc] initWithSenderId:@"1" senderDisplayName:@"" date:[NSDate date] text:@""];
    }
    return message;
}


//-(UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    JSQMessage* message = ((Chat*) _chatArray[indexPath.row]).jsmessage;
//    JSQMessagesBubbleImageFactory* bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
//    if ([message.senderId isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
////        return [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
//        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
//    }
//    return [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
//}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = ((Chat*) _chatArray[indexPath.row]).jsmessage;
    JSQMessagesBubbleImageFactory* bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([message.senderId isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
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
//    JSQMessage* message = ((Chat*)_chatArray[indexPath.row]).jsmessage;
//    if ([message.senderId isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
//        PFFile *file = [PFUser currentUser][kPFUser_Picture];
//        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            iv.image = [UIImage imageWithData:data];
//        }];
//    } else {
//        if (_isGroupChat) {
//            for (NSDictionary* dict in _groupObj.members) {
//                if ([dict[kPFUser_FBID] isEqualToString:message.senderId]) {
//                    iv.image = dict[kPFUser_Picture];
//                }
//            }
//        } else {
//            iv.image = _friendsImage;
//        }
//    }
//    return iv;
//}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage* message = ((Chat*) _chatArray[indexPath.row]).jsmessage;
    __block JSQMessagesAvatarImage* avatar;
    
    if ([message.senderId isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
        PFFile* file = [PFUser currentUser][kPFUser_Picture];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:data] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        }];
    } else {
        if (_isGroupChat) {
            for (NSDictionary* dict in _groupObj.members) {
                if ([dict[kPFUser_FBID] isEqualToString:message.senderId]) {
                    avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:dict[kPFUser_Picture] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                }
            }
        } else {
            avatar =  [JSQMessagesAvatarImageFactory avatarImageWithImage:_friendsImage diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        }
    }
    return avatar;
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
        
        if ([message.senderId isEqualToString:[PFUser currentUser][kPFUser_FBID]]) {
            NSAttributedString* attString = [[NSAttributedString alloc] initWithString:[PFUser currentUser][kPFUser_Name]];
            return attString;
        } else {
            for (NSDictionary* dict in _groupObj.members) {
                if ([dict[kPFUser_FBID] isEqualToString:message.senderId]) {
                    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:dict[kPFUser_Name]];
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
    
    if ([msg.senderId isEqualToString:self.senderId]) {
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

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
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
        if ([message.senderId isEqualToString:previousMessage.senderId]) {
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
