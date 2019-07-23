//
//  NetBridge.h
//  PUBG
//
//  Created by december on 2018/1/12.
//  Copyright © 2018年 woqugame. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NetBridge : NSObject
+(NSURLSessionDataTask *)postWithApi:(NSString *)api params:(NSDictionary<NSString * , id> *)params needPara:(BOOL)need success:(void (^)(id object))success
                             failure:(void (^)(NSInteger code, NSString *message))failure;

+(NSURLSessionDataTask *)postV3WithApi:(NSString *)api params:(NSDictionary<NSString * , id> *)params success:(void (^)(id object))success
                             failure:(void (^)(NSInteger code, NSString *message))failure;

+(NSURLSessionDataTask *)postV2WithApi:(NSString *)api params:(NSDictionary<NSString * , id> *)params success:(void (^)(id object))success
                             failure:(void (^)(NSInteger code, NSString *message))failure;

+(NSURLSessionDataTask *)getWithUrl:(NSString *)url params:(NSDictionary<NSString * , id> *)params success:(void (^)(id object))success
                            failure:(void (^)(NSInteger code, NSString *message))failure;

+ (NSURLSessionDataTask *)putWithApi:(NSString *)api params:(NSDictionary<NSString *,id> *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure;

+ (NSURLSessionDataTask *)deleteWithApi:(NSString *)api params:(NSDictionary<NSString *,id> *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure;

+ (NSURLSessionDataTask *)postV2UpLoadApi:(NSString *)api file:(UIImage *)file success:(void (^)(id _Nonnull))success failure:(void (^)(NSInteger, NSString * _Nonnull))failure;

+ (NSDictionary *)getSignData:(NSDictionary *)params api:(NSString *)api;

@end
NS_ASSUME_NONNULL_END
