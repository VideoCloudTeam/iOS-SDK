//
//  NetworkManager.m
//  linphone
//
//  Created by mac on 2019/5/11.
//

#import "NetworkrRequstAPI.h"
#import "NetBridge.h"
#import "NSMutableDictionary+WQHTTP.h"

@implementation NetworkRequstAPI
/**
 公有云我的会诊室
 @param alias 用户账号
 */
+ (NSURLSessionDataTask *)cloudMeeting: (NSString *)alias success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure{
    NSMutableDictionary *parameter = [NSMutableDictionary new];
    [parameter setObject:alias forField:@"alias"];
    return [NetBridge getWithUrl:@"/api/v3/app/getmeetings" params:parameter success:success failure:failure];
}

+ (NSURLSessionDataTask *)loginUserName:(NSString*)address password:(NSString*)password success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSMutableDictionary *parameter = [NSMutableDictionary new];
    [parameter setObject:address forField:@"account"];
    [parameter setObject:password forKey:@"pwd"] ;
    return [NetBridge getWithUrl:@"api/v3/app/user/login/verify_user.shtml" params:parameter success:success failure:failure] ;
}

+ (NSURLSessionDataTask *)registerUserName:(NSString*)address password:(NSString*)password success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure {
    NSMutableDictionary *parameter = [NSMutableDictionary new];
    [parameter setObject:address forField:@"account"];
    [parameter setObject:password forKey:@"pwd"] ;
    return [NetBridge getWithUrl:@"api/v3/app/user/login/verify_user.shtml" params:parameter success:success failure:failure] ;
}

@end
