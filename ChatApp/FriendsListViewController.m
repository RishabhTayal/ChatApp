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
#import "DropDownView.h"
#import "CreateGroupViewController.h"
#import "Group.h"
#import "Friend.h"
#import "AppDelegate.h"

@interface FriendsListViewController ()

@property (strong) NSMutableArray* groups;
@property (strong) NSMutableArray* friendsUsingApp;
@property (strong) NSMutableArray* friendsNotUsingApp;

@property (strong) Reachability* reachability;

-(BOOL)NSStringIsValidEmail:(NSString*)checkString;

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
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate displayAdMobInViewController:self];
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
    [self loadGroupsFromServer];
    [self loadFriendsFromFacebook];
    //    [self updateInterfaceWithReachabiltity:_reachability];
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
            [DropDownView showInViewController:self withText:@"Needs Internet to chat with friends. No Internet found." height:DropDownViewHeightDefault hideAfterDelay:0];
        }
            break;
        default:
        {
            [DropDownView hide];
            
            NSArray* friendsArray = [Friend MR_findAll];
            if (friendsArray.count == 0) {
                [self loadFriendsFromFacebook];
            } else {
                _friendsUsingApp = [NSMutableArray arrayWithArray:friendsArray];
            }
            
            //Get groups
            NSArray* array = [Group MR_findAll];
            if (array.count == 0) {
                [self loadGroupsFromServer];
            } else {
                _groups = [NSMutableArray arrayWithArray:array];
            }
        }
            break;
    }
}

#pragma mark -

-(void)loadFriendsFromFacebook
{
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/friends?fields=installed" parameters:@{@"fields":@"name,first_name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DLog(@"Error: %@", error);
        [GAI trackEventWithCategory:@"ui_event" action:@"facebook_friends" label:[PFUser currentUser][kPFUser_FBID] value:[NSNumber numberWithInt:[result[@"data"] count]]];
        [Friend MR_truncateAll];
        for (NSDictionary* object in result[@"data"]) {
            Friend* friend = [Friend MR_createEntity];
            friend.fbId = object[@"id"];
            friend.name = object[@"name"];
        }
        [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
            if (success) {
                DLog(@"You successfully saved your context.");
                _friendsUsingApp = [NSMutableArray arrayWithArray:[Friend MR_findAll]];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (error) {
                DLog(@"Error saving context: %@", error.description);
            }
        }];
    }];
}

-(void)loadGroupsFromServer
{
    PFQuery* query = [PFQuery queryWithClassName:kPFTableGroup];
    [query whereKey:kPFGroupMembers equalTo:[PFUser currentUser]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [Group MR_truncateAll];
        
        for (PFObject* object in objects) {
            Group* group = [Group MR_createEntity];
            group.groupId = object.objectId;
            group.name = object[kPFGroupName];
            group.updatedAt = object.updatedAt;
            group.imageurl = ((PFFile*) object[kPFGroupPhoto]).url;
        }
        [CoreDataHelper savePersistentCompletionBlock:^(BOOL success, NSError *error) {
            if (success) {
                DLog(@"You successfully saved your context.");
                _groups = [[NSMutableArray alloc] initWithArray:[Group MR_findAllSortedBy:@"updatedAt" ascending:YES]];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (error) {
                DLog(@"Error saving context: %@", error.description);
            }
        }];
    }];
}

#pragma mark -

-(void)createNewGroup:(id)sender
{
    DLog(@"Create group");
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateGroupViewController* createGroupVC = [sb instantiateViewControllerWithIdentifier:@"CreateGroupViewController"];
    createGroupVC.friendsListVC = self;
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
    
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray* sortDescriptors = [NSArray arrayWithObject:descriptor];
    [allcontacts sortedArrayUsingDescriptors:sortDescriptors];
    _friendsNotUsingApp = [NSMutableArray arrayWithArray:[allcontacts sortedArrayUsingDescriptors:sortDescriptors]];
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
        if (_groups.count == 0) {
            return 1;
        }
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
        if (_groups.count == 0) {
            cell.friendName.text = NSLocalizedString(@"Create Group", nil);
            cell.friendName.textColor = [UIColor blueColor];
        } else {
            Group* group = _groups[indexPath.row];
            cell.friendName.text = group.name;
            [cell.profilePicture setImageWithURL:[NSURL URLWithString:group.imageurl]];
        }
        return cell;
    }
    if (indexPath.section == 1) {
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        Friend* friend = ((Friend*) _friendsUsingApp[indexPath.row]);
        cell.friendName.text = friend.name;
        [cell.profilePicture setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=200", friend.fbId]] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
        return cell;
    } else {
        FriendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"friendNotUsingAppCell"];
        cell.friendName.text = _friendsNotUsingApp[indexPath.row][@"name"];
        cell.profilePicture.image = _friendsNotUsingApp[indexPath.row][@"image"];
        
        NSArray* array = [PFUser currentUser][kPFUser_Invited];
        if ([array containsObject:_friendsNotUsingApp[indexPath.row][@"email"] ]) {
            cell.inviteButton.enabled = false;
            [cell.inviteButton setTitle:NSLocalizedString(@"Invited", nil) forState:UIControlStateDisabled];
        } else {
            cell.inviteButton.enabled = true;
        }
        
        return cell;
    }
}

#pragma mark -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (_groups.count == 0) {
            [self createNewGroup:nil];
        } else {
            FriendTableViewCell* cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
            Group* group = (Group*)_groups[indexPath.row];
            chatVC.title = group.name;
            //        chatVC.friendDict = _groups[indexPath.row];
            chatVC.groupObj = group;
            chatVC.friendsImage = cell.profilePicture.image;
            chatVC.isGroupChat = YES;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        
        FriendTableViewCell* cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FriendsChatViewController* chatVC = [sb instantiateViewControllerWithIdentifier:@"FriendsChatViewController"];
        Friend* friend = (Friend*)_friendsUsingApp[indexPath.row];
        chatVC.title = friend.name;
        //        chatVC.friendDict = _friendsUsingApp[indexPath.row];
        chatVC.friendObj = friend;
        chatVC.friendsImage = cell.profilePicture.image;
        chatVC.isGroupChat = NO;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (NSArray *)rightButtons
//{
//    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                title:@"More"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Delete"];
//
//    return rightUtilityButtons;
//}
//
//#pragma mark - SWTableViewCell Delegate
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"Delete";
//}
//- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"More";
//}
//- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Called when "MORE" button is pushed.
//    DLog(@"MORE button pushed in row at: %@", indexPath.description);
//    // Hide more- and delete-confirmation view
//    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
//        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
//            [cell hideDeleteConfirmation];
//        }
//    }];
//}

//- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
//{
//    switch (state) {
//        case 0:
//            DLog(@"utility buttons closed");
//            break;
//        case 1:
//            DLog(@"left utility buttons open");
//            break;
//        case 2:
//            DLog(@"right utility buttons open");
//            break;
//        default:
//            break;
//    }
//}
//
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
//{
//    switch (index) {
//        case 0:
//            DLog(@"left button 0 was pressed");
//            break;
//        case 1:
//            DLog(@"left button 1 was pressed");
//            break;
//        case 2:
//            DLog(@"left button 2 was pressed");
//            break;
//        case 3:
//            DLog(@"left btton 3 was pressed");
//        default:
//            break;
//    }
//}
//
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
//{
//    switch (index) {
//        case 0:
//        {
//            DLog(@"More button was pressed");
//            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
//            [alertTest show];
//
//            [cell hideUtilityButtonsAnimated:YES];
//            break;
//        }
//        case 1:
//        {
//            // Delete button was pressed
//            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
//
//            [_groups removeObjectAtIndex:cellIndexPath.row];
//            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
//{
//    // allow just one cell's utility button to be open at once
//    return YES;
//}
//
//- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
//{
//    switch (state) {
//        case 1:
//            // set to NO to disable all left utility buttons appearing
//            return YES;
//            break;
//        case 2:
//            // set to NO to disable all right utility buttons appearing
//            return YES;
//            break;
//        default:
//            break;
//    }
//
//    return YES;
//}

#pragma mark -

-(void)inviteFriend:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSString* recipientEmail = _friendsNotUsingApp[indexPath.row][@"email"];
    if (DEBUGMODE) {
        recipientEmail = @"rtayal11@gmail.com";
    }
    
    if ([self NSStringIsValidEmail:recipientEmail]) {
        NSString* recipientName = _friendsNotUsingApp[indexPath.row][@"name"];
        NSDictionary* params = @{@"toEmail": recipientEmail, @"toName": recipientName, @"fromEmail": [[PFUser currentUser] email], @"fromName": [PFUser currentUser][kPFUser_Name], @"text": @"Hey, \n\nI just downloaded vCinity Chat on my iPhone. \n\nIt is a chat app which lets me chat with people around me. Even if there is no Internet connection. The signup is very easy and simple. You don't have to remember anything. \n\nDownload it now on the AppStore to start chatting. https://itunes.apple.com/app/id875395391", @"subject":@"vCinity Chat App for iPhone"};
        [PFCloud callFunctionInBackground:@"sendMail" withParameters:params block:^(id object, NSError *error) {
            DLog(@"%@", object);
            if (!error) {
                //Show Success
                [DropDownView showInViewController:self withText:[NSString stringWithFormat:NSLocalizedString(@"Invitation sent to %@!", nil), recipientName] height:DropDownViewHeightTall hideAfterDelay:2];
                [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"success" value:nil];
                
                //Save email to invited coloumn
                NSMutableArray* array = [PFUser currentUser][kPFUser_Invited];
                if (!array) {
                    array = [[NSMutableArray alloc] init];
                }
                if (![array containsObject:recipientEmail]) {
                    [array addObject:recipientEmail];
                    [[PFUser currentUser] setObject:array forKey:kPFUser_Invited];
                    [[PFUser currentUser] saveEventually];
                }
            } else {
                //Show Error
                [DropDownView showInViewController:self withText:NSLocalizedString(@"Invitation could not be sent!", nil) height:DropDownViewHeightTall hideAfterDelay:2];
                [GAI trackEventWithCategory:kGAICategoryButton action:@"invite" label:@"failed" value:nil];
            }
        }];
    } else {
        [DropDownView showInViewController:self withText:NSLocalizedString(@"Not a valid email address", nil) height:DropDownViewHeightTall hideAfterDelay:2];
    }   
}

-(BOOL)NSStringIsValidEmail:(NSString*)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
