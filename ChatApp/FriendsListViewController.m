//
//  FriendsListViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FriendsChatViewController.h"
#import <UIImageView+AFNetworking.h>
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import "MenuButton.h"
#import <MFSideMenu.h>
#import "UIImage+Utility.h"
#import <Reachability/Reachability.h>
#import "NotificationView.h"

@interface FriendsListViewController ()

@property (strong) NSMutableArray* friendsUsingApp;
@property (strong) NSMutableArray* friendsNotUsingApp;

@property (strong) Reachability* reachability;

@end

@implementation FriendsListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Friends";
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _friendsUsingApp = [NSMutableArray new];
    
    _friendsNotUsingApp = [NSMutableArray arrayWithArray:[self getAllDeviceContacts]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GAI trackWithScreenName:kScreenNameFriendsList];
    
    _reachability = [Reachability reachabilityForInternetConnection];
    [self updateInterfaceWithReachabiltity:self.reachability];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [_reachability startNotifier];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internet Reachability Methods

-(void)reachabilityChanged:(NSNotification*)notif {
    Reachability* reach = [notif object];
    [self updateInterfaceWithReachabiltity:reach];
}

-(void)updateInterfaceWithReachabiltity:(Reachability*)reachability {
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:
        {
            [NotificationView showInViewController:self withText:@"Needs Internet to chat with friends. No Internet found." height:NotificationViewHeightDefault hideAfterDelay:0];
        }
            break;
        default:
        {
            [NotificationView hide];
            FBRequest* request = [FBRequest requestWithGraphPath:@"me/friends" parameters:@{@"fields":@"name,first_name"} HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSLog(@"Friends: %@", result[@"data"]);
                NSLog(@"Error: %@", error);
                _friendsUsingApp = [NSMutableArray arrayWithArray:result[@"data"]];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }];
        }
            break;
    }
}

#pragma mark -

-(void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

-(NSArray*)getAllDeviceContacts
{
    NSMutableArray* allcontacts = [NSMutableArray new];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        accessGranted = NO;
    }
    
    if (accessGranted) {
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        CFIndex numberOfPeople = CFArrayGetCount(people);
        for (int i = 0; i < numberOfPeople; i++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
            ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
            for (CFIndex j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)(ABMultiValueCopyValueAtIndex(emails, j));
                NSString* firstName = (__bridge NSString*)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
                NSString* lastName = (__bridge NSString*)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
                NSString* name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                NSData* imgData = (__bridge NSData*)(ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail));
                UIImage* img = [UIImage imageWithData:imgData];
                if (img == nil) {
                    img = [UIImage imageNamed:@"avatar-placeholder"];
                }
                NSDictionary* dict = @{@"name": name, @"email": email, @"image": img};
                [allcontacts addObject:dict];
            }
            CFRelease(emails);
        }
        CFRelease(addressBook);
        CFRelease(people);
    }
    
    return allcontacts;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Friends using vCinity";
    }
    return @"Friends not on vCinity";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return _friendsUsingApp.count;
    }
    return _friendsNotUsingApp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if (indexPath.section == 0) {
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.friendName.text = _friendsUsingApp[indexPath.row][@"name"];
        [cell.profilePicture setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200", _friendsUsingApp[indexPath.row][@"id"]]] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
        return cell;
    } else {
        FriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"friendNotUsingAppCell"];
        cell.friendName.text = _friendsNotUsingApp[indexPath.row][@"name"];
        cell.profilePicture.image = _friendsNotUsingApp[indexPath.row][@"image"];
        return cell;
    }
}

#pragma mark -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        FriendTableViewCell* cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
        chatVC.title = _friendsUsingApp[indexPath.row][@"name"];
        chatVC.friendDict = _friendsUsingApp[indexPath.row];
        chatVC.friendsImage = cell.profilePicture.image;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark -

-(void)inviteFriend:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSLog(@"Invite at path %d", indexPath.row);
    
    NSString* recipientEmail = _friendsNotUsingApp[indexPath.row][@"email"];
    if (DEBUG) {
        recipientEmail = @"rtayal11@gmail.com";
    }
    NSString* recipientName = _friendsNotUsingApp[indexPath.row][@"name"];
    NSDictionary* params = @{@"toEmail": recipientEmail, @"toName": recipientName, @"fromEmail": [[PFUser currentUser] email], @"fromName": [[PFUser currentUser] username], @"text": @"Hey, \n\nI just downloaded vCinity Chat on my iPhone. \n\nIt is a chat app which lets me chat with people around me. Even if there is no Internet connection. The signup is very easy and simple. You don't have to remember anything. \n\nDownload it now on the AppStore to start chatting. https://itunes.apple.com/app/id875395391", @"subject":@"vCinity Chat App for iPhone"};
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:params block:^(id object, NSError *error) {
        NSLog(@"%@", object);
        if (!error) {
            //Show Success
            [NotificationView showInViewController:self withText:[NSString stringWithFormat:@"Invitation sent to %@!", recipientName] height:NotificationViewHeightTall hideAfterDelay:2];
            [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"success" value:nil];
        } else {
            //Show Error
            [NotificationView showInViewController:self withText:@"Invitation could not be sent!" height:NotificationViewHeightTall hideAfterDelay:2];
            [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"failed" value:nil];
        }
    }];
}

@end
