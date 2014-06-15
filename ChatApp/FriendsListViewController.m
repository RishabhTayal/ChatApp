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
#import "CreateGroupViewController.h"

@interface FriendsListViewController ()

@property (strong) NSMutableArray* groups;
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
    
    self.title = NSLocalizedString(@"Friends", nil);
    
    [MenuButton setupLeftMenuBarButtonOnViewController:self];
    
    _friendsUsingApp = [NSMutableArray new];
    
    [NSThread detachNewThreadSelector:@selector(getAllDeviceContacts) toTarget:self withObject:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New Group", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(createNewGroup:)];
    _reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [_reachability startNotifier];

    [self updateInterfaceWithReachabiltity:self.reachability];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GAI trackWithScreenName:kScreenNameFriendsList];
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

-(void)refreshTable:(UIRefreshControl*)refreshControl
{
    [refreshControl endRefreshing];
    [self updateInterfaceWithReachabiltity:_reachability];
}

#pragma mark - Internet Reachability Methods

-(void)reachabilityChanged:(NSNotification*)notif {
    Reachability* reach = [notif object];
    [self updateInterfaceWithReachabiltity:reach];
}

-(void)updateInterfaceWithReachabiltity:(Reachability*)reachability
{
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
                NSLog(@"Error: %@", error);
                _friendsUsingApp = [NSMutableArray arrayWithArray:result[@"data"]];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            
            //Get groups
            PFQuery* query = [PFQuery queryWithClassName:kPFTableGroup];
            [query whereKey:kPFGroupMembers equalTo:[PFUser currentUser]];
            [query orderByDescending:@"updatedAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                _groups = [[NSMutableArray alloc] initWithArray:objects];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
            break;
    }
}

#pragma mark -

-(void)createNewGroup:(id)sender
{
    NSLog(@"Create group");
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateGroupViewController* createGroupVC = [sb instantiateViewControllerWithIdentifier:@"CreateGroupViewController"];
    createGroupVC.friendsArray = _friendsUsingApp;
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:createGroupVC] animated:YES completion:nil];
}

#pragma mark -

-(void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

-(void)getAllDeviceContacts
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
    
    _friendsNotUsingApp = [NSMutableArray arrayWithArray:allcontacts];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Groups", nil);
    }
    if (section == 1) {
        return NSLocalizedString(@"Friends using vCinity", nil);
    }
    return NSLocalizedString(@"Friends not on vCinity", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return _groups.count;
    }
    if (section == 1) {
        return _friendsUsingApp.count;
    }
    return _friendsNotUsingApp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if (indexPath.section == 0) {
        FriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
        cell.friendName.text = _groups[indexPath.row][@"name"];
        PFFile* file = [_groups objectAtIndex:indexPath.row][@"photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [cell.profilePicture setImage:[UIImage imageWithData:data]];
        }];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 1) {
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
        chatVC.title = _groups[indexPath.row][@"name"];
        chatVC.friendDict = _groups[indexPath.row];
        chatVC.friendsImage = cell.profilePicture.image;
        chatVC.isGroupChat = YES;
        [self.navigationController pushViewController:chatVC animated:YES];
    }

    if (indexPath.section == 1) {
        
        FriendTableViewCell* cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
        chatVC.title = _friendsUsingApp[indexPath.row][@"name"];
        chatVC.friendDict = _friendsUsingApp[indexPath.row];
        chatVC.friendsImage = cell.profilePicture.image;
        chatVC.isGroupChat = NO;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCell Delegate


- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"More button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [_groups removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark -

-(void)inviteFriend:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSString* recipientEmail = _friendsNotUsingApp[indexPath.row][@"email"];
    if (DEBUGMODE) {
        recipientEmail = @"rtayal11@gmail.com";
    }
    NSString* recipientName = _friendsNotUsingApp[indexPath.row][@"name"];
    NSDictionary* params = @{@"toEmail": recipientEmail, @"toName": recipientName, @"fromEmail": [[PFUser currentUser] email], @"fromName": [[PFUser currentUser] username], @"text": @"Hey, \n\nI just downloaded vCinity Chat on my iPhone. \n\nIt is a chat app which lets me chat with people around me. Even if there is no Internet connection. The signup is very easy and simple. You don't have to remember anything. \n\nDownload it now on the AppStore to start chatting. https://itunes.apple.com/app/id875395391", @"subject":@"vCinity Chat App for iPhone"};
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:params block:^(id object, NSError *error) {
        NSLog(@"%@", object);
        if (!error) {
            //Show Success
            [NotificationView showInViewController:self withText:[NSString stringWithFormat:NSLocalizedString(@"Invitation sent to %@!", nil), recipientName] height:NotificationViewHeightTall hideAfterDelay:2];
            [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"success" value:nil];
        } else {
            //Show Error
            [NotificationView showInViewController:self withText:NSLocalizedString(@"Invitation could not be sent!", nil) height:NotificationViewHeightTall hideAfterDelay:2];
            [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"failed" value:nil];
        }
    }];
}

@end
