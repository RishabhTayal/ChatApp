//
//  Group.m
//  VCinity
//
//  Created by Rishabh Tayal on 6/15/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "Group.h"
#import <Parse/Parse.h>

@implementation Group

@dynamic groupId;
@dynamic name;
@dynamic imageurl;
@dynamic members;
@dynamic updatedAt;

@end

@implementation Members

+(Class)transformedValueClass
{
    return [NSArray class];
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