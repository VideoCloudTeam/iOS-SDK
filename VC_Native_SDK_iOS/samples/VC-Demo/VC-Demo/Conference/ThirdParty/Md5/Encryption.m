//
//  Encryption.m
//  测试接口
//
//  Created by 李志朋 on 2017/11/29.
//  Copyright © 2017年 李志朋. All rights reserved.
//

#import "Encryption.h"
#import <CommonCrypto/CommonDigest.h>


//秘钥
//static NSString *encryptionKey = @"nha735n197nxn(N′568GGS%d~~9naei';45vhhafdjkv]32rpks;lg,];:vjo(&**&^)";

@implementation Encryption

+ (NSString *)md5EncryptWithString:(NSString *)string{
    return [self md5:string];
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSLog(@"%s--  digest:%s",cStr,digest);
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result ;
}

@end
