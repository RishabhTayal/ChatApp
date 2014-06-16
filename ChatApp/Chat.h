//
//  Chat.h
//  VCinity
//
//  Created by Rishabh Tayal on 6/16/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <JSQMessagesViewController/JSQMessage.h>

@interface Chat : NSManagedObject

@property (retain) id jsmessage;
//@property (retain) NSString* sender;
@property (retain) NSString* groupId;

@end

@interface JSMessage : NSValueTransformer

@end