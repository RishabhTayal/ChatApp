//
//  InterfaceController.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/1/15.
//  Copyright (c) 2015 Rishabh Tayal. All rights reserved.
//

#import "InterfaceController.h"
#import "MyRowController.h"
//#import <UIImageView+AFNetworking.h>

@interface InterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceTable* tableView;
@property (strong, nonatomic) NSMutableArray* datasourceArray;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self loadContacts];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [self presentTextInputControllerWithSuggestions:@[@"Ok", @"Thank you.", @"Talk later?", @"Sorry, I can't talk right now.", @"What's up?"] allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        NSLog(@"Text: %@", results[0]);
        NSString* facebookID = self.datasourceArray[rowIndex][@"id"];
        
        [WKInterfaceController openParentApplication:@{@"request": @"sendMessage", @"recipientFBID": facebookID, @"message": results[0]} reply:^(NSDictionary *replyInfo, NSError *error) {
            NSLog(@"Message sending result: %d", [replyInfo[@"success"] boolValue]);
        }];
    }];
}

-(void)loadContacts {
    [WKInterfaceController openParentApplication:@{@"request": @"contacts"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"Contacts: %@", replyInfo);
        self.datasourceArray = [NSMutableArray new];
        self.datasourceArray = replyInfo[@"data"];
        
        [self.tableView setNumberOfRows:self.datasourceArray.count withRowType:@"default"];
        
        for (int i = 0; i < self.datasourceArray.count; i++) {
            NSString* friendName = self.datasourceArray[i][@"name"];
            MyRowController* rowController = [self.tableView rowControllerAtIndex:i];
            [rowController.nameLabel setText:friendName];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=50", self.datasourceArray[i][@"id"]]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [rowController.profileImage setImageData:data];
                });
            });
        }
    }];
}

@end