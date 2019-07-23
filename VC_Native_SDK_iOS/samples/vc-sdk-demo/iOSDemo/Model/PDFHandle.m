//
//  PDFHandle.m
//  iOSDemo
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 mac. All rights reserved.
//

#import "PDFHandle.h"
#import "PDFView.h"
#import "UIImage+PDF.h"

@implementation PDFHandle

//把PDF转成JPG格式
+ (NSArray *) extractJPGsFromPDFWithPath:(NSString *)pdfPath {
    NSURL *pathURL = [NSURL URLWithString:pdfPath];
    pdfPath = [pathURL path];
    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
    if (!fileExists) return @[];
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:&error];
    if (error) return @[];
    if ([attributes objectForKey:NSFileType] == NSFileTypeDirectory) return @[];
    NSInteger pages = [PDFView pageCountForURL:pathURL];
    for(NSInteger page = 1; page <= pages; page++) {
        UIImage *image = [UIImage originalSizeImageWithPDFURL:pathURL atPage:page];
        image = [PDFHandle scaleToFill1280W720H:image];
        NSString *filePath = [PDFHandle getRandomDatePathAtPage:page filetype:@"jpg"];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        BOOL success = [imageData writeToFile:filePath atomically:NO];
        [pathArray addObject:image];
        if(!success) return @[];
    }
    return [pathArray copy];
}

+ (UIImage *)scaleToFill1280W720H:(UIImage *)image {
    CGFloat const longSide = 1280;
    CGFloat const shortSide = 720;
    UIImage *newImage = image;
    CGSize size = image.size;
    if(MAX(size.width, size.height) > longSide || MIN(size.width, size.height) > shortSide){
        CGFloat longFactor = longSide / MAX(size.width, size.height);
        CGFloat shortFactor = shortSide / MIN(size.width, size.height);
        CGFloat factor = MIN(longFactor, shortFactor);
        CGSize newSize = CGSizeMake(size.width * factor, size.height * factor);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return  newImage;
}

+ (NSString *)getRandomDatePathAtPage:(NSInteger)page filetype:(NSString *)filetype {
    NSDate *now = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@_%ld.%@",[PDFHandle stringWithFormat:@"YYYYMMddHHmmss" withDate:now], (long)page, filetype];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return filePath;
}
+ (NSString *)stringWithFormat:(NSString *)format withDate: (NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate: date];
}
@end
