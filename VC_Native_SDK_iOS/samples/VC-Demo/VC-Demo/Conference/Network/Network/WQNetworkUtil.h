//
//  WQNetworkUtil.h
//  Pods
//
//  Created by Jayla on 16/7/28.
//
//

#import <Foundation/Foundation.h>

@interface WQQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

extern NSArray * WQQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSString * WQQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);

@interface WQNetworkUtil : NSObject

//URL编码
+ (NSString *)encodeUrl:(NSString *)url;

//请求地址
+ (NSString *)requestUrlWithUrl:(NSString *)url api:(NSString *)api;

//请求参数
+ (NSMutableDictionary *)requestParamsWithApi:(NSString *)api params:(NSDictionary *)params;

//缓存Key
+ (NSString *)requestCacheKeyWithUrl:(NSString *)url api:(NSString *)api params:(NSDictionary *)params;

//修正接口时间差
+ (void)updateCheckTimestamp:(NSTimeInterval)timestamp;

//获取接口请求时间
+ (NSDate *)reqeustDate;

@end
