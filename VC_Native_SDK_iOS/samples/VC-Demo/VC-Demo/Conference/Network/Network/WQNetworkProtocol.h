//
//  WQNetworkProtocol.h
//  DNF
//
//  Created by Jayla on 16/5/24.
//  Copyright © 2016年 anzogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NSMutableDictionary+WQHTTP.h"

typedef NS_ENUM(NSInteger, WQNetworkStatus) {
    WQNetworkStatusUnknown          = -1,
    WQNetworkStatusNotReachable     = 0,
    WQNetworkStatusReachableViaWWAN = 1,
    WQNetworkStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

@protocol WQNetworkProtocol <NSObject>
@required
@property (readonly, nonatomic, assign) WQNetworkStatus networkStatus;
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
//@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

/**********************************************************************/
#pragma mark - Public
/**********************************************************************/

//数据请求
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;


//文件上传
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

//文件下载
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**********************************************************************/
#pragma mark - HTTP
/**********************************************************************/

//- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
//                            parameters:(nullable id)parameters
//                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
//                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
//                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString method:(nullable NSString *)method
                             parameters:(nullable id)parameters version:(NSString *)version
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

/**********************************************************************/
#pragma mark - WQHTTP
/**********************************************************************/

- (nullable NSURLSessionDataTask *)HTTP_GET:(NSString *)url parameters:(NSDictionary *)parameters
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (nullable NSURLSessionDataTask *)HTTP_GET:(NSString *)url parameters:(NSDictionary *)parameters
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (nullable NSURLSessionDataTask *)HTTP_POSTV3:(NSString *)url action:(nullable NSString *)action
                                  parameters:(NSDictionary *)parameters
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (nullable NSURLSessionDataTask *)HTTP_POST:(NSString *)url action:(nullable NSString *)action cache:(BOOL)cache
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;


- (nullable NSURLSessionDataTask *)HTTP_POST:(NSString *)url action:(nullable NSString *)action
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                   constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> formData))block
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;


//V2
- (nullable NSURLSessionDataTask *)HTTP_POSTV2:(NSString *)url action:(nullable NSString *)action cache:(BOOL)cache
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;



- (nullable NSURLSessionDataTask *)HTTP_POSTV2:(NSString *)url action:(nullable NSString *)action
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                   constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> formData))block
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (nullable NSURLSessionDataTask *)HTTP_PUT:(NSString *)url action:(nullable NSString *)action
                                 parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (nullable NSURLSessionDataTask *)HTTP_DELETE:(NSString *)url action:(nullable NSString *)action
                                    parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure;

- (void)setSessionId:(NSString *)sessionId andKey:(NSString *)key ; 

@end

NS_ASSUME_NONNULL_END
