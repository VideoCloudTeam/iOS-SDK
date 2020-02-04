//
//  UIImage+ForceDecode.m
//  linphone
//
//  Created by heqin on 16/7/29.
//
//

#import "UIImage+ForceDecode.h"

@implementation UIImage (ForceDecodsse)

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8,
                                                 // Just always return width * 4 will be enough
                                                 CGImageGetWidth(imageRef) * 4,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 // Makes system don't need to do extra conversion when displayed.
                                                 // NOTE: here we remove the alpha channel for performance. Most of the time, images loaded
                                                 //       from the network are jpeg with no alpha channel. As a TODO, finding a way to detect
                                                 //       if alpha channel is necessary would be nice.
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context)
        return nil;
    
    CGRect rect = (CGRect){CGPointZero, {CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}};
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage =
    [[UIImage alloc] initWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}


@end
