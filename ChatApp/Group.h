//
//  Group.h
//  VCinity
//
//  Created by Rishabh Tayal on 6/15/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Group : NSManagedObject

@property (retain) NSString* groupId;
@property (retain) NSString* name;
@property (retain) NSString* imageurl;
@property (retain) NSManagedObject* groupChat;

@end