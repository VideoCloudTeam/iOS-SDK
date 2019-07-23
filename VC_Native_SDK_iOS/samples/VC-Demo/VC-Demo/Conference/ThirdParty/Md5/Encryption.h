//
//  Encryption.h
//  测试接口
//
//  Created by 李志朋 on 2017/11/29.
//  Copyright © 2017年 李志朋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject

//md5加密方法
+ (NSString *)md5EncryptWithString:(NSString *)string;

@end
