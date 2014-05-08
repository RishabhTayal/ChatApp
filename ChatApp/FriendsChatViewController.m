//
//  FriendsChatViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "FriendsChatViewController.h"
//#import <JSMessage.h>
#import <Parse/Parse.h>

@interface FriendsChatViewController ()

@property (strong) NSMutableArray* chatArray;

@property (strong) NSTimer* timer;

@end

@implementation FriendsChatViewController

- (void)viewDidLoad
{
//    self.dataSource = self;
//    self.delegate = self;
    
    [super viewDidLoad];
    
    _chatArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"notification" object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadChat) userInfo:nil repeats:YES];
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
//
//-(void)pushNotificationRecieved:(NSNotification*)notification
//{
//    [JSMessageSoundEffect playMessageReceivedSound];
//    
//    NSLog(@"%@", notification.userInfo[@"aps"][@"alert"]);
//    JSMessage* message = [[JSMessage alloc] initWithText:notification.userInfo[@"aps"][@"alert"] sender:@"" date:nil];
//    [_chatArray addObject:message];
//    [self.tableView reloadData];
//    [self scrollToBottomAnimated:YES];
//}

-(void)loadChat
{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Wechat"];
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_chatArray removeAllObjects];
        
//        for (PFObject* object in objects) {
//            JSMessage* message = [[JSMessage alloc] initWithText:object[@"msg"] sender:object[@"name"] date:object.createdAt];
//            [_chatArray addObject:message];
//        }
//        _chatArray =  [[NSMutableArray alloc] initWithArray:[[_chatArray reverseObjectEnumerator] allObjects]];
//        [self.tableView reloadData];
//        [self scrollToBottomAnimated:YES];
    }];
    
}
//
//-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
//{
//    JSMessage* message = [[JSMessage alloc] initWithText:text sender:sender date:date];
//    [_chatArray addObject:message];
//    
//    [JSMessageSoundEffect playMessageSentSound];
//    
//    NSArray* recipients = @[_friendId];
//    PFQuery* pushQuery = [PFInstallation query];
//    [pushQuery whereKey:@"owner" containedIn:recipients];
//    
//    PFPush *push = [[PFPush alloc] init];
//    [push setQuery:pushQuery];
//    [push setMessage:text];
//    [push sendPushInBackground];
//    
//    PFObject *sendObjects = [PFObject objectWithClassName:@"Wechat"];
//    [sendObjects setObject:[NSString stringWithFormat:@"%@", text] forKey:@"msg"];
//    [sendObjects setObject:[PFUser currentUser].username forKey:@"name"];
//    [sendObjects saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"save");
//    }];
//    
//    [self.tableView reloadData];
//    [self scrollToBottomAnimated:YES];
//    [self finishSend];
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatArray.count;
}
//
//-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return JSBubbleMessageTypeOutgoing;
//}
//
//-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    JSMessage* message = _chatArray[indexPath.row];
//    return message;
//}
//
//-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
//{
//    return nil;
//}
//
//-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    JSMessage* message = _chatMessagesArray[indexPath.row];
//    //    if ([message.sender isEqualToString:@"me"]) {
//    //        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
//    //    }
//    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
//}
//
//-(JSMessageInputViewStyle)inputViewStyle
//{
//    return JSMessageInputViewStyleFlat;
//}

@end
