//
//  CreateGroupViewController.m
//  VCinity
//
//  Created by Rishabh Tayal on 6/12/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "CreateGroupViewController.h"
#import <Parse/Parse.h>
#import "ActivityView.h"
#import "Friend.h"

@interface CreateGroupViewController ()
{
    CGFloat _keyboardHeight;
}

@property (strong) IBOutlet UITextField* groupNameTF;
@property (strong) IBOutlet UIButton* groupPhotoButton;

@property (strong) TITokenFieldView* tokenFieldView;
@property (strong) NSArray* friendsArray;

@property (assign) BOOL imagePicked;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(0, 160, 320, 300)];
    _friendsArray = [Friend MR_findAll];
    
    [_tokenFieldView setSourceArray:_friendsArray];
    [self.view addSubview:_tokenFieldView];
    
    _tokenFieldView.tokenField.delegate = self;
    [_tokenFieldView.tokenField setPromptText:NSLocalizedString(@"Add People:", nil)];
    _tokenFieldView.forcePickSearchResult = YES;
    
    _groupPhotoButton.layer.cornerRadius = _groupPhotoButton.frame.size.height/2;
    _groupPhotoButton.layer.masksToBounds = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
//TODO: Implement Group Info
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(createGroup:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _imagePicked = false;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
    //	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}

-(void)createGroup:(id)sender
{
    [self.view endEditing:NO];
    [ActivityView showInView:self.view loadingMessage:@"Creating Group..."];
    PFObject* groupObject = [PFObject objectWithClassName:kPFTableGroup];
    groupObject[kPFGroupName] = _groupNameTF.text;
    
    //Save Group Photo
    PFFile* file;
    if (_imagePicked) {
        file = [PFFile fileWithName:@"groupPhoto" data:UIImagePNGRepresentation(_groupPhotoButton.imageView.image)];
    } else {
        file = [PFFile fileWithName:@"groupPhoto" data:UIImagePNGRepresentation([UIImage imageNamed:@"logo-grey-scale"])];
    }
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        groupObject[kPFGroupPhoto] = file;
        [groupObject saveEventually:^(BOOL succeeded, NSError *error) {
            [ActivityView hide];            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    
    //Save Group Memebers
    PFQuery* query = [PFUser query];
    [query whereKey:kPFUser_FBID containedIn:[_tokenFieldView.tokenField.tokenObjects valueForKey:@"fbId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFRelation* relation = [groupObject relationForKey:kPFGroupMembers];
        for (PFUser* user in objects) {
            [relation addObject:user];
        }
        [relation addObject:[PFUser currentUser]];
        [groupObject saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            }
        }];
        
        //Send push notifications to group members
        PFQuery* pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" containedIn:[objects valueForKey:kPFUser_FBID]];
        [pushQuery whereKey:@"owner" notEqualTo:[PFUser currentUser][kPFUser_FBID]];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        
        [push setMessage:[NSString stringWithFormat:@"%@ invited you to group \"%@\".", [PFUser currentUser].username, _groupNameTF.text]];
        [push sendPushInBackground];
    }];
}

-(void)cancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)selectGroupPicture:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Exisiting Photo", nil), nil];
    [sheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Take photo
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else if (buttonIndex == 1) {
        //Choose from library
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Image size: %.2fMB", UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]).length/1024.0f/1024.0f);
        
        int imageSize = UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]).length/1024/1024;
        if (imageSize > 9) {
            [_groupPhotoButton setImage:[self downScaleImage:info[UIImagePickerControllerOriginalImage]] forState:UIControlStateNormal];
            
            NSLog(@"Reduced size: %.2fMB", UIImagePNGRepresentation(_groupPhotoButton.imageView.image).length/1024.0f/1024.0f);
        } else {
            [_groupPhotoButton setImage:info[UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
        }
        _imagePicked = YES;
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
    //	[self textViewDidChange:_messageView];
}

-(void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token
{
    if (tokenField.tokenObjects.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Custom Search

-(CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForRepresentedObject:(id)object
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Friend* friend = (Friend*)object;
    cell.textLabel.text = friend.name;
//    cell.detailTextLabel.text = friend
//    cell.imageView.image = [object objectForKey:@"photo"];
    
    return cell;
}

-(NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object
{
    //    [_contacts removeObject:object];
    Friend* friend = (Friend*)object;
    return friend.name;
}

-(BOOL)tokenField:(TITokenField *)field shouldUseCustomSearchForSearchString:(NSString *)searchString
{
    return YES;
}

-(void)tokenField:(TITokenField *)field performCustomSearchForSearchString:(NSString *)searchString withCompletionHandler:(void (^)(NSArray *))completionHandler
{
    NSLog(@"search");
    NSMutableArray* filteredArray;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
    filteredArray  = [[NSMutableArray alloc] initWithArray:[_friendsArray filteredArrayUsingPredicate:pred]];
    completionHandler(filteredArray);
}

-(UIImage*)downScaleImage:(UIImage*)image
{
    CGSize newSize = CGSizeMake(200, (200 * image.size.height) / image.size.width);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
