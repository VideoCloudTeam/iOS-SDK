//
//  NSError+WQHTTP.m
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import "NSError+WQHTTP.h"

@implementation NSError (WQHTTP)

+ (NSError *)reqeustError:(NSInteger)code message:(NSString *)message{
    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{NSLocalizedDescriptionKey: message};
    }
    return [NSError errorWithDomain:RequestErrorDoman code:code userInfo:userInfo];
}
+ (NSError *)responseError:(NSInteger)code message:(NSString *)message{
    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{NSLocalizedDescriptionKey: message};
    }
    return [NSError errorWithDomain:ResponseErrorDoman code:code userInfo:userInfo];
}
+ (NSError *)bussinessError:(NSInteger)code message:(NSString *)message{
    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{NSLocalizedDescriptionKey: message};
    }
    return [NSError errorWithDomain:BussinessErrorDoman code:code userInfo:userInfo];
}


- (NSError *)toRequestError {
    if ([self.domain isEqualToString:RequestErrorDoman]) {
        return self;
    }
    return [NSError reqeustError:self.code message:self.localizedDescription];
}

- (NSError *)toResponseError {
    if ([self.domain isEqualToString:ResponseErrorDoman]) {
        return self;
    }
    NSString *message = nil;
    switch (self.code) {
        case kCFHostErrorHostNotFound:{
            message = @"网络无法连接";
        }break;
        case NSURLErrorCancelled:{
            message = @"请求取消";
        }break;
        case NSURLErrorBadURL:{
            message = @"地址出错";
        }break;
        case NSURLErrorTimedOut:{
            message = @"连接超时，请稍后重试";
        }break;
        case NSURLErrorCannotFindHost:{
            message = @"服务器未找到";
        }break;
        case NSURLErrorCannotConnectToHost:{
            message = @"暂时无法连接";
        }break;
        case NSURLErrorNetworkConnectionLost:{
            message = @"网络连接丢失";
        }break;
        case NSURLErrorBadServerResponse:{
            message = @"服务器响应出错";
        }break;
        case NSURLErrorCannotDecodeContentData:{
            message = @"不能解码响应数据";
        }break;
        case NSURLErrorCannotParseResponse:{
            message = @"不能解析响应数据";
        }break;
        case NSURLErrorNotConnectedToInternet:{
            message = @"网络已断开，请连接后重试";
        }break;
        default:{
            message = [NSHTTPURLResponse localizedStringForStatusCode:self.code];
        }break;
    }
    return [NSError bussinessError:self.code message:message];
}

@end
