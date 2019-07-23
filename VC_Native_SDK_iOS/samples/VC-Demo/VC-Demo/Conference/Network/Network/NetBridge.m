//
//  NetBridge.m
//  PUBG
//
//  Created by december on 2018/1/12.
//  Copyright © 2018年 woqugame. All rights reserved.
//
//
#import "NetBridge.h"
#import "NSMutableDictionary+WQHTTP.h"
#import "ZJAPPEngine.h"
#define APPENGINE ((ZJAPPEngine *)[[UIApplication sharedApplication] delegate])
@implementation NetBridge
+(NSURLSessionDataTask *)postWithApi:(NSString *)api params:(NSDictionary<NSString * , id> *)params needPara:(BOOL)need success:(void (^)(id object))success
                                  failure:(void (^)(NSInteger code, NSString *message))failure{
    return [APPENGINE.networkManager  HTTP_POST:api action:api cache:NO parameters:^(id<WQParameterDic>  _Nonnull parameter) {
        NSDictionary *para = [self getSignData:params api:api];
        if (need) {
            [parameter setParameterForParams:^(id<WQParameterDic> parameter) {
                for (NSString * key in para) {
                    [parameter setObject:para[key] forField:key];
                }
            }];
        }else{
            for (NSString * key in para) {
                [parameter setObject:para[key] forField:key];
            }
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}


+(NSURLSessionDataTask *)postV3WithApi:(NSString *)api params:(NSDictionary<NSString * , id> *)params success:(void (^)(id object))success
                             failure:(void (^)(NSInteger code, NSString *message))failure{

    return [APPENGINE.networkManager HTTP_POSTV3:api action:api parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject, NSError * _Nonnull error) {
        if (failure) {
            if (responseObject[@"result"] != nil && [responseObject[@"result"] isKindOfClass:[NSString class]]) {
                failure(error.code, responseObject[@"result"]);
            } else {
                failure(error.code, error.localizedDescription);                
            }
        }
    }];
}

#pragma mark - V2
+ (NSURLSessionDataTask *)postV2WithApi:(NSString *)api params:(NSDictionary<NSString *,id> *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure{
    return [APPENGINE.networkManager HTTP_POSTV2:api action:api cache:false parameters:^(id<WQParameterDic>  _Nonnull parameter) {
        for (NSString * key in params) {
            [parameter setObject:params[key] forField:key];
        }
    } success:^(NSURLSessionDataTask *  task, NSDictionary * responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *  task, NSDictionary * responseObject, NSError * error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}


+ (NSURLSessionDataTask *)putWithApi:(NSString *)api params:(NSDictionary<NSString *,id> *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure{
    return [APPENGINE.networkManager HTTP_PUT:api action:api parameters:^(id<WQParameterDic>  _Nonnull parameter) {
        for (NSString * key in params) {
            [parameter setObject:params[key] forField:key];
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject, NSError * _Nonnull error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}

+ (NSURLSessionDataTask *)deleteWithApi:(NSString *)api params:(NSDictionary<NSString *,id> *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure{
    return [APPENGINE.networkManager HTTP_DELETE:api action:api parameters:^(id<WQParameterDic>  _Nonnull parameter) {
        for (NSString * key in params) {
            [parameter setObject:params[key] forField:key];
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject, NSError * _Nonnull error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}

+(NSURLSessionDataTask *)getWithUrl:(NSString *)url params:(NSDictionary<NSString * , id> *)params success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure{
  
    return [APPENGINE.networkManager HTTP_GET:url parameters: params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * task, NSDictionary * responseObject, NSError * error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}

+ (NSURLSessionDataTask *)postV2UpLoadApi:(NSString *)api file:(UIImage *)file success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure{
    
    return [APPENGINE.networkManager HTTP_POSTV2:api action:api parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(file, 0.01);
        [formData appendPartWithFileData:data name:@"hcImage" fileName:@"image.jpg" mimeType:@"image/jpg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject, NSError * _Nonnull error) {
        if (failure) {
            failure(error.code, error.localizedDescription);
        }
    }];
}

#pragma mark - Action

+ (NSDictionary *)getSignData:(NSDictionary *)params api:(NSString *)api{
    
    
//    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];
//    NSMutableDictionary *newParamsDic = [[NSMutableDictionary alloc]init];
//    if (params) {
//        [newParamsDic addEntriesFromDictionary:params];
//    }
//    if ([api isEqualToString:@"UserPayWallet"]||
//        [api isEqualToString:@"UserCashWallet"]||
//        [api isEqualToString:@"StockExWallet"]||
//        [api isEqualToString:@"DoAreaCeoCampaign"]||
//        [api isEqualToString:@"LockCity"]) {
//        [newParamsDic setObject:timeStr forKey:@"timemap"];
//    }
//
////    NSArray *arr = @[timeStr,[WQUtility deviceId],@"yfb90891f4e7f76acd8c6a3f1a9a219ca1"];
//    NSString *sign = [self encryptionSign:arr];
//    if ([api isEqualToString:@"RedbagBack"] ||
//        [api isEqualToString:@"saveRedbag"]) {
//
//    }else{
//        [newParamsDic setObject:sign forKey:@"sign"];
//    }
//
//    NSString *values = @"";
//
//    NSArray *result = [newParamsDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {return [obj1 compare:obj2];}]; //升序
//
//    if ([api isEqualToString:@"myReceivedRedbag"]||
//        [api isEqualToString:@"mySendRedbag"]||
//        [api isEqualToString:@"sendSms"]||
//        [api isEqualToString:@"saveThirdUser"] || [api isEqualToString:@"bindThirdUser"]) {
//        [newParamsDic setObject:timeStr forKey:@"time_stamp"];
//    }
//
//    for (NSString * key in result) {
//        if ([newParamsDic[key] isKindOfClass:[NSString class]]) {
//            values = [values stringByAppendingString:newParamsDic[key]];
//        }else if ([newParamsDic[key] isKindOfClass:[NSNumber class]]) {
//            NSString *temp = [NSString stringWithFormat:@"%@",newParamsDic[key]];
//            values = [values stringByAppendingString:temp];
//        }
//    }
//
//    if ([api isEqualToString:@"openReadbag"]) {
//        NSString *pwd = [newParamsDic objectForKey:@"password"];
//        NSString *redPacketUserId = [newParamsDic objectForKey:@"redbag_user"];
//        NSString *redPacketId = [newParamsDic objectForKey:@"redbag_id"];
//        NSString *userToken = APPENGINE.userManager.token;
//        if (redPacketUserId && redPacketId && userToken) {
//            NSString *acc = [NSString stringWithFormat:@"%@%@%@",redPacketUserId,redPacketId,userToken];
//            if (pwd) {
//                acc = [acc stringByAppendingString:pwd];
//            }
//            acc = [acc stringByAppendingString:@"#yuefei#"];
//            NSString *accToken = acc.md5;
//            if (accToken) {
//                [newParamsDic setObject:accToken forKey:@"acc_token"];
//            }
//        }
//    }else{
//        NSString *accToken = [NSString stringWithFormat:@"%@#yuefei#",values].md5;
//        [newParamsDic setObject:accToken forKey:@"acc_token"];
//    }
    
    return params;
}

+ (NSString *)encryptionSign:(NSArray<NSString *>*)strs{
//    NSArray *arr = [strs sortedArrayUsingSelector:@selector(compare:)];
//    NSString *str = [arr componentsJoinedByString:@""];
//    CocoaSecurityResult *result = [CocoaSecurity sha1:str];
//    CocoaSecurityResult *result2 =[CocoaSecurity md5:result.hexLower];
//    if (!result.hex) {
//        return @"";
//    }
    return @"";
}


@end
