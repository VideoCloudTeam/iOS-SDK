//
//  WQNetworkUtil.m
//  Pods
//
//  Created by Jayla on 16/7/28.
//
//

#import "WQNetworkUtil.h"
#import "wqencrylib.h"
#import "NSMutableDictionary+WQHTTP.h"

static NSString * const kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * WQPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * WQPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@implementation WQQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return WQPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", WQPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), WQPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}
@end

static NSArray * WQQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        for (id nestedKey in dictionary.allKeys) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:WQQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        int i = 0;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:WQQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[%d]", key, i++], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in set) {
            [mutableQueryStringComponents addObjectsFromArray:WQQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[WQQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

NSArray * WQQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    NSArray<WQQueryStringPair *> *tempArray = WQQueryStringPairsFromKeyAndValue(nil, dictionary);
    tempArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(WQQueryStringPair * _Nonnull obj1, WQQueryStringPair   * _Nonnull obj2) {
        return [obj1.field compare:obj2.field];
    }];
    return tempArray;
}

NSString * WQQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (WQQueryStringPair *pair in WQQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

@implementation WQNetworkUtil

//URL编码
+ (NSString *)encodeUrl:(NSString *)url {
    url = WQPercentEscapedQueryStringValueFromStringWithEncoding(url, NSUTF8StringEncoding);
    return url;
}

//请求地址
+ (NSString *)requestUrlWithUrl:(NSString *)url api:(NSString *)api {
//    if ([api isEqualToString:@"bindThirdUser"]||
//        [api isEqualToString:@"saveThirdUser"]||
//        [api isEqualToString:@"sendSms"]) {
//        if (api) {
//            url = [url stringByAppendingString:[NSString stringWithFormat:@"/%@",api]];
//        }
//    }else{
//        url = [url stringByAppendingPathComponent:@"api"];
//    }
    return url;
}

//请求参数
+ (NSMutableDictionary *)requestParamsWithApi:(NSString *)api params:(NSDictionary *)params {
//    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
//    [tempDic setObject:@"ios" forField:@"os"];
//    [tempDic setObject:@"ios" forField:@"platform"];
//    [tempDic setObject:[WQDevice osVersion] forField:@"osVersion"];
//    [tempDic setObject:[WQDevice appBuild] forField:@"platformVersion"];
//    if (APPENGINE.userManager.token) {
//        [tempDic setObject:APPENGINE.userManager.token forField:@"token"];
//    }
//    [tempDic setObject:api forField:@"api"];
//    if ([params isKindOfClass:[NSDictionary class]]) {
//        [tempDic addEntriesFromDictionary:params];
//    }
    
//    return tempDic;
    return (NSMutableDictionary*)params;// [NSMutableDictionary
//            dictionary];
}

//缓存Key
+ (NSString *)requestCacheKeyWithUrl:(NSString *)url api:(NSString *)api params:(NSDictionary *)params {
    NSMutableDictionary *tempDic = [params mutableCopy];
    [tempDic removeObjectForKey:@"time"];
    [tempDic removeObjectForKey:@"deviceId"];
    [tempDic removeObjectForKey:@"secretId"];
    [tempDic removeObjectForKey:@"secretVersion"];
    [tempDic removeObjectForKey:@"nonce"];
    [tempDic removeObjectForKey:@"secretSignature"];
//    NSString *cacheKey = [WQHTTPCache cacheKeyWithUrl:url api:api params:tempDic];
    
//    return cacheKey;
    return @"hh";
}

//修正接口时间差
static NSTimeInterval check_timestamp = 0;
+ (void)updateCheckTimestamp:(NSTimeInterval)timestamp {
    check_timestamp = timestamp - [[NSDate date] timeIntervalSince1970];
}

//获取接口请求时间
+ (NSDate *)reqeustDate{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:check_timestamp];
    return date;
}

@end
