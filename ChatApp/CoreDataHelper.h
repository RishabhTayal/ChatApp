//
//  CoreDataHelper.h
//  VCinity
//
//  Created by Rishabh Tayal on 6/16/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler)(BOOL success, NSError *error);

@interface CoreDataHelper : NSObject

+(void)savePersistentCompletionBlock:(CompletionHandler)completion;

@end
