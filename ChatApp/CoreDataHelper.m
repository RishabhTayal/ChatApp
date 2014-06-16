//
//  CoreDataHelper.m
//  VCinity
//
//  Created by Rishabh Tayal on 6/16/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

+(void)savePersistentCompletionBlock:(CompletionHandler)completion
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

@end
