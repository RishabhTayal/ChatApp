//
//  Chat.m
//  VCinity
//
//  Created by Rishabh Tayal on 6/16/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "Chat.h"


@implementation Chat

@dynamic jsmessage;
@dynamic groupId;
@dynamic friendId;
@dynamic updatedAt;

@end

@implementation JSMessage

+(Class)transformedValueClass
{
    return [JSQMessage class];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value
{
   return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end