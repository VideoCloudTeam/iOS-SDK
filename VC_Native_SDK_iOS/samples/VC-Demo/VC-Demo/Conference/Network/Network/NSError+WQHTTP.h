//
//  NSError+WQHTTP.h
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NET_UNCONNECT @"网络不太顺畅哦\n请检查网络设置"
#define NET_CONNECT_ERROR @"当前网络不给力,请稍后重试"
#define NET_REQUEST_ERROR @"请求失败，请稍后重试"
#define NET_SERVER_ERROR @"服务器繁忙，请稍后再试"

#define RequestErrorDoman   @"RequestErrorDomain"
#define ResponseErrorDoman  @"ResponseErrorDomain"
#define BussinessErrorDoman @"BussinessErrorDomain"

@interface NSError (WQHTTP)

+ (NSError *)reqeustError:(NSInteger)code message:(NSString *)message;
+ (NSError *)responseError:(NSInteger)code message:(NSString *)message;
+ (NSError *)bussinessError:(NSInteger)code message:(NSString *)message;

- (NSError *)toRequestError;
- (NSError *)toResponseError;


@end
