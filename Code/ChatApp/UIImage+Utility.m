//
//  UIImage+Utility.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/6/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "UIImage+Utility.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation UIImage (Utility)

-(UIImage*)applyGaussianBlur
{
    CIFilter* gaussianBLurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBLurFilter setDefaults];
    [gaussianBLurFilter setValue:[CIImage imageWithCGImage:[self CGImage]] forKey:kCIInputImageKey];
    [gaussianBLurFilter setValue:@6 forKey:kCIInputRadiusKey];
    
    CIImage* outImage = [gaussianBLurFilter outputImage];
    CIContext* context = [CIContext contextWithOptions:nil];
    CGRect rect = [outImage extent];
    
    rect.origin.x += (rect.size.width - self.size.width) / 2;
    rect.origin.y += (rect.size.height - self.size.height) / 2;
    rect.size = self.size;
    
    CGImageRef cgimg = [context createCGImage:outImage fromRect:rect];
    UIImage* image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return image;
}

+(void)imageForURL:(NSURL *)url imageDownloadBlock:(ImageDownloadedBloack)block
{
    DLog(@"%@", url);
    
    [[SDWebImageManager sharedManager] downloadWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        block(image, error);
    }];
}

-(UIImage*)imageWithColor:(UIColor*)color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, [UIScreen mainScreen].scale);
    //        UIGraphicsBeginImageContext(image.size)
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage* coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImage;
}

@end
