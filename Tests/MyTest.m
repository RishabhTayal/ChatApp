//
//  MyTest.m
//  VCinity
//
//  Created by Rishabh Tayal on 5/29/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface MyTest : GHTestCase
{
    
}

@end

@implementation MyTest

-(BOOL)shouldRunOnMainThread
{
    return NO;
}

-(void)setUpClass
{
    
}

-(void)tearDownClass
{
    
}

-(void)setUp
{
    
}

-(void)tearDown
{
    
}

-(void)testFoo
{
    NSString *a = @"foo";
    GHTestLog(@"I can log to the GHUnit test console: %@", a);
    
    // Assert a is not NULL, with no custom error description
    GHAssertNotNil(a, nil);
    
    // Assert equal objects, add custom error description
    NSString *b = @"bar";
    GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
}

-(void)testBar
{
        //another test
}

@end
