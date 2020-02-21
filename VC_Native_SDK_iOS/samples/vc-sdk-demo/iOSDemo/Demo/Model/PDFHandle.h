//
//  PDFHandle.h
//  iOSDemo
//
//  Created by mac on 2019/7/12.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFHandle : NSObject
+ (NSArray *) extractJPGsFromPDFWithPath:(NSString *)pdfPath;
@end

NS_ASSUME_NONNULL_END
