//
//  UIImage+Utility.h
//  ChatApp
//
//  Created by Rishabh Tayal on 5/6/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageDownloadedBloack)(UIImage *image, NSError *error);

@interface UIImage (Utility)

-(UIImage*)applyGaussianBlur;

+(void)imageForURL:(NSURL*)url imageDownloadBlock:(ImageDownloadedBloack)block;

-(UIImage*)imageWithColor:(UIColor*)color;

@end
