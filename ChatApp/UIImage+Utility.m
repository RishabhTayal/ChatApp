//
//  UIImage+Utility.m
//  ChatApp
//
//  Created by Rishabh Tayal on 5/6/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "UIImage+Utility.h"

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
    return image;
}

@end
