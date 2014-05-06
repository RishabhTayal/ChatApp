//
//  MenuViewController.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/5/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "MenuViewController.h"
#import "FriendsListViewController.h"
#import "NearChatViewController.h"
#import "SettingsViewController.h"
#import <MFSideMenu.h>

@interface MenuViewController ()

@property (strong) NearChatViewController* near;
@property (strong) FriendsListViewController* friends;
@property (strong) SettingsViewController* settings;

@end

@implementation MenuViewController

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
    
    UIImage* img = [UIImage imageNamed:@"chicago1.jpg"];
    UIImage* blurImage = [self gaussianBlur:img];
    UIImageView* iv = [[UIImageView alloc] initWithImage:blurImage];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.frame = self.tableView.frame;
    self.tableView.backgroundView = iv;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIImage*)gaussianBlur:(UIImage*)img
{
    CIFilter* gaussianBLurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBLurFilter setDefaults];
    [gaussianBLurFilter setValue:[CIImage imageWithCGImage:[img CGImage]] forKey:kCIInputImageKey];
    [gaussianBLurFilter setValue:@10 forKey:kCIInputRadiusKey];
    
    CIImage* outImage = [gaussianBLurFilter outputImage];
    CIContext* context = [CIContext contextWithOptions:nil];
    CGRect rect = [outImage extent];
    
    rect.origin.x += (rect.size.width - img.size.width) / 2;
    rect.origin.y += (rect.size.height - img.size.height) / 2;
    rect.size = img.size;
    
    CGImageRef cgimg = [context createCGImage:outImage fromRect:rect];
    UIImage* image = [UIImage imageWithCGImage:cgimg];
    return image;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [UIView new];

    }
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.backgroundColor = [UIColor clearColor];
  
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Offline Chat";
            break;
        case 1:
            cell.textLabel.text = @"Friends";
            break;
        default:
            cell.textLabel.text = @"Settings";
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* array;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (indexPath.row) {
        case 0:
        {
            if (!_near)
                _near = [sb instantiateViewControllerWithIdentifier:@"NearChatViewController"];
            array = [[NSMutableArray alloc] initWithObjects:_near, nil];
        }
            break;
        case 1:
        {
            if (!_friends)
                _friends = [sb instantiateViewControllerWithIdentifier:@"FriendsListViewController"];
            array = [[NSMutableArray alloc] initWithObjects:[[UINavigationController alloc] initWithRootViewController:_friends], nil];
        }
            break;
        default:
        {
            if (!_settings)
                _settings = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            array = [[NSMutableArray alloc] initWithObjects:_settings, nil];
        }
            break;
    }
//    UINavigationController* nav = self.menuContainerViewController.centerViewController;
//    nav.viewControllers = array;
    self.menuContainerViewController.centerViewController = array[0];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end
