//
//  WQNetworkManager.m
//  DNF
//
//  Created by Jayla on 16/5/25.
//  Copyright © 2016年 anzogame. All rights reserved.
//

#import "WQNetworkManager.h"
#import "NSError+WQHTTP.h"
#import "NSMutableDictionary+WQHTTP.h"
#import "WQDevice.h"

#define SeverAddress [VCPublicModel shareModel].apiServer

#define TASK_BEGIN \
NSTimeInterval beginTime = [NSDate timeIntervalSinceReferenceDate];

#define TASK_END(task, parameters) \
NSLog(@"******************************请求开始(%lu)******************************", (unsigned long) task.taskIdentifier);\
(@"请求地址：%@", task.currentRequest.URL);\
NSLog(@"请求参数：%@", parameters);\
NSLog(@"请求头部：%@", task.currentRequest.allHTTPHeaderFields);

#define TASK_SUCCESS(task, responseObject) \
NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];\
NSLog(@"响应头部：%@", ((NSHTTPURLResponse *)task.response).allHeaderFields);\
NSLog(@"响应内容：%@", responseObject);\
NSLog(@"请求用时：%lf", endTime-beginTime);\
NSLog(@"******************************请求完成(%lu)******************************\n\n\n", task.taskIdentifier);

#define TASK_FAILURE(task, responseObject, error) \
NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];\
NSLog(@"请求失败：%@", error.localizedDescription);\
NSLog(@"响应头部：%@", ((NSHTTPURLResponse *)task.response).allHeaderFields);\
NSLog(@"响应内容：%@", responseObject);\
NSLog(@"请求用时：%f", endTime-beginTime);\
NSLog(@"******************************请求完成(%lu)******************************\n\n\n", task.taskIdentifier);


@interface WQNetworkManager ()
@property (nonatomic, weak) NSURLSessionDataTask *task;
@end

@implementation WQNetworkManager

-(instancetype)init {
    self = [super init];
    self.securityPolicy = [self mySecurityPolicy];
    
    AFHTTPRequestSerializer *requestSerializer = self.requestSerializer;
    [requestSerializer setTimeoutInterval:15];
    
    AFJSONResponseSerializer *responseSerializer = (AFJSONResponseSerializer *)self.responseSerializer;
    responseSerializer.removesKeysWithNullValues = YES;
    responseSerializer.readingOptions = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments;
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/jpeg", @"image/png",nil];
    [self.reachabilityManager startMonitoring];
    return self;
}

//- (AFNetworkReachabilityManager *)reachabilityManager{
//    return self.reachabilityManager;
//}

- (AFSecurityPolicy *)mySecurityPolicy {
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    //validatesCertificateChain 是否验证整个证书链，默认为YES
    //设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
    //GeoTrust Global CA
    //    Google Internet Authority G2
    //        *.google.com
    //那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
    //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书，则建议关闭该验证，因为整个证书链一一比对是完全没有必要（请查看源代码）；
    //    securityPolicy.validatesCertificateChain = NO;
    
    // 导入证书 ,可以自动导入bundle中所有证书。
    //    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"http1s" ofType:@"cer"];//证书的路径
    //    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    //    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}

/**********************************************************************/
#pragma mark - Overwrite
/**********************************************************************/

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSString *URL= URLString;
    if (![URLString containsString:SeverAddress]) {
        URL = [NSString stringWithFormat:@"%@%@",SeverAddress,URLString];
    }
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URL relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    //    TASK_BEGIN
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               //                               TASK_FAILURE(dataTask, responseObject, error)
                               if (failure) {
                                   failure(dataTask, error);
                               }
                           } else {
                               //                               TASK_SUCCESS(dataTask, responseObject)
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    TASK_END(dataTask, parameters)
    
    return dataTask;
}
//V3Header设置
- (void)V3SetHeader: (NSString *)urlString {
//    NSDictionary *userInfor = [[NSUserDefaults standardUserDefaults]objectForKey:@"curryUserToken"];
//    NSString *sessionId = userInfor[@"sessionId"] ;
    NSString *devid = @"0b587e7d-4193-4a7b-b9ab-c46882711236" ;
    NSString *token = @"fd3483b8-f451-4cdb-8a84-8078f555fe7a" ;
    NSString *randdtm = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *urlStr = [NSString stringWithFormat:@"/rest/v1/app1/manager/sessions/"];
    
    [self.requestSerializer setValue:devid forHTTPHeaderField:@"devid"];
    [self.requestSerializer setValue:randdtm forHTTPHeaderField:@"randdtm"];
    NSString *md5TokenStr = [NSString stringWithFormat:@"%@,%@,%@,%@",devid,token,randdtm,urlString];
    NSString *md5Token = [Encryption md5EncryptWithString:md5TokenStr];
    [self.requestSerializer setValue:md5Token forHTTPHeaderField:@"md5token"] ;
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString method:(nullable NSString *)method
                    parameters:(id)parameters version:(NSString *)version
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                      progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, id _Nullable responseObject, NSError *error))failure
{
    NSError *serializationError = nil;
    //Post请求HeaderField特殊处理
    if ([version isEqualToString:@"V1"]){
        [self.requestSerializer  setValue:@"application/x-www-form-urlencoded;" forHTTPHeaderField:@"Content-Type"];
    } else if([version isEqualToString:@"V3"]) {
         [self V3SetHeader:URLString];
    }else{
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    NSString *URL = URLString;
    if (![URLString containsString:SeverAddress]) {
        URL = [NSString stringWithFormat:@"%@%@", SeverAddress,URLString];
    }
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:[[NSURL URLWithString:URL relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if ([version isEqualToString:@"V2"] || [version isEqualToString:@"V3"]) {
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:[[NSURL URLWithString:URL relativeToURL:self.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:block error:&serializationError];
            NSDictionary *parametersDic =  (NSDictionary *)parameters;
            NSData *data = [parametersDic yy_modelToJSONData];
            if (data) {
                [request setHTTPBody:data];
            }
        }
    }
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil,nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
   
    //    TASK_BEGIN
    __block NSURLSessionDataTask *task = [self uploadTaskWithStreamedRequest:request progress:uploadProgress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (![AFNetworkReachabilityManager sharedManager].reachable) {
            NSError *tempError = nil;
//            tempError.domain = NSURLErrorDomain;
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NET_UNCONNECT};
                tempError = [NSError errorWithDomain:RequestErrorDoman code:error.code userInfo:userInfo];
            failure(task,responseObject, tempError);
        } else {
            if (error) {
                //            TASK_FAILURE(task, responseObject, error)
                if (failure) {
                    
                    failure(task,responseObject, error);
                    
                }
            } else {
                //            TASK_SUCCESS(task, responseObject)
                if (success) {
                    success(task, responseObject);
                }
            }
        }
    }];
    
    [task resume];
    
    return task;
}

/**********************************************************************/
#pragma mark - Private
/**********************************************************************/

- (void)handleSuccess:(NSURLSessionDataTask *)task response:(id)responseObject
              success:(void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
              failure:(void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure
                cache:(void (^)(void))cache {
    
    NSLog(@"response - %@", responseObject);
    if ([responseObject isKindOfClass:[NSArray class]]) {
        success(task,responseObject);
        return ;
    }
    
    NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"请求数据错误:%@", task);
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        BOOL isSuccess = false;
        NSString *code = responseObject[@"code"];
        NSInteger errorCode = -2;
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if ([response statusCode] == 200) {
            isSuccess = YES;
        }else {
            errorCode = code.integerValue;
        }
        
        if (!isSuccess) {
            if (failure) {
                NSMutableDictionary *userInfo = [responseObject mutableCopy];
                if ([responseObject[@"results"] isKindOfClass:[NSString class]]) {
                    [userInfo setObject:responseObject[@"results"]?:NET_REQUEST_ERROR forKey:NSLocalizedDescriptionKey];
                }
                NSError *error = [NSError errorWithDomain:BussinessErrorDoman code:errorCode userInfo:userInfo];
                failure(task, responseObject, error);
            }
        }else{
            if (cache) {
                cache();
            }
            if (success) {
                success(task, responseObject);
            }
        }
        if ([code intValue] == 407) {
            //退出登录
        }
    } else {
        if (failure) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NET_SERVER_ERROR};
            NSError *error = [NSError errorWithDomain:BussinessErrorDoman code:-1 userInfo:userInfo];
            failure(task, responseObject, error);
        }
    }
}
// id _Nullable responseObject
- (void)handleFailure:(NSURLSessionDataTask *)task responseObject: (id)responseObject error:(NSError *)error
              failure:(void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    if (failure){
        NSError *tempError = nil;
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NET_UNCONNECT};
            tempError = [NSError errorWithDomain:RequestErrorDoman code:error.code userInfo:userInfo];
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NET_REQUEST_ERROR};
            tempError = [NSError errorWithDomain:ResponseErrorDoman code:error.code userInfo:userInfo];
        }
        if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary  class]]) {
            failure(task, responseObject, tempError);
        } else {
            failure(task, nil, tempError);
        }
    }
}

/**********************************************************************/
#pragma mark - WQNetworkProtocol
/**********************************************************************/

- (WQNetworkStatus)networkStatus {
    return (WQNetworkStatus)self.reachabilityManager.networkReachabilityStatus;
}

- (BOOL)isReachable {
    return self.reachabilityManager.reachable;
}

- (BOOL)isReachableViaWiFi {
    return self.reachabilityManager.isReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN {
    return self.reachabilityManager.isReachableViaWWAN;
}


- (nullable NSURLSessionDataTask *)HTTP_POSTV3:(NSString *)url action:(nullable NSString *)action
                                  parameters:(NSDictionary *)parameters
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    NSURLSessionDataTask *dataTask = [self POST:url method:@"POST" parameters:parameters version:@"V3" constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task,id _Nullable responseObject , NSError * _Nonnull error) {
        [self handleFailure:task responseObject: responseObject error:error failure:failure];
    }];
    return dataTask;
    
}

- (nullable NSURLSessionDataTask *)HTTP_POST:(NSString *)url action:(nullable NSString *)action cache:(BOOL)cache
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    //请求参数
    NSString *retUrl = [WQNetworkUtil requestUrlWithUrl:url api:action];
    //参数处理
    NSMutableDictionary *retParams = [WQNetworkUtil requestParamsWithApi:action params:tempDict];
    NSString *URLString = retUrl;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,retUrl];
    }
    
    //参数的特殊处理
    //    id realParams = nil;
    //    if ([action isEqualToString:@"bindThirdUser"]||
    //        [action isEqualToString:@"saveThirdUser"]||
    //        [action isEqualToString:@"sendSms"]) {
    //        realParams = retParams;
    //    }else{
    //        [retParams setObject:@"" forKey:@"time_stamp"];
    //        NSString *tempString = [retParams yy_modelToJSONString];
    //        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //        [dic setObject:tempString forKey:@"post_data"];
    //        realParams = dic;
    //    }
    
    //请求网络数据
    //    @weakify(self)
    NSURLSessionDataTask *dataTask = [self POST:URLString method:@"POST" parameters:retParams version:@"" constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        @strongify(self)
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError * _Nonnull error) {
        //        @strongify(self)
        [self handleFailure:task responseObject:responseObject error:error failure:failure];
    }];
    
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_POST:(NSString *)url action:(nullable NSString *)action
                                  parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                   constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> formData))block
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                     failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    
    //请求参数
    NSString *retUrl = [WQNetworkUtil requestUrlWithUrl:url api:action];
    //设置headerField
    NSMutableDictionary *retParams = [WQNetworkUtil requestParamsWithApi:action params:tempDict];
    //    id realParams = nil;
    //    if ([action isEqualToString:@"bindThirdUser"]||
    //        [action isEqualToString:@"saveThirdUser"]||
    //        [action isEqualToString:@"sendSms"]) {
    //        realParams = retParams;
    //    }else{
    //        if ([action isEqualToString:@""]) {
    //        }else{
    //            [retParams setObject:@"" forKey:@"time_stamp"];
    //        }
    //        NSString *tempString = [retParams yy_modelToJSONString];
    //        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //        [dic setObject:tempString forKey:@"post_data"];
    //        realParams = dic;
    //    }
    NSString *URLString = retUrl;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,retUrl];
    }
    //请求网络数据
    NSURLSessionDataTask *dataTask = [self POST:URLString method:@"POST" parameters:retParams version:@"V1"  constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task,id _Nullable responseObject, NSError * _Nonnull error) {
        [self handleFailure:task responseObject: responseObject error:error failure:failure];
    }];
    
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_GET:(NSString *)url parameters:(NSDictionary *)parameters
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    
    return [self HTTP_GET:url parameters: parameters progress:nil success:success failure:failure];
}

- (nullable NSURLSessionDataTask *)HTTP_GET:(NSString *)url parameters:(NSDictionary *)parameters progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    NSParameterAssert(url);
    [self setHeaderData:url];
    //请求网络数据
    NSString *retUrl = url;
    retUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *URLString = retUrl;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,retUrl];
    }
    NSURLSessionDataTask *dataTask =  [self GET:URLString parameters: parameters headers:nil progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailure:task responseObject: nil error:error failure:failure];
        
    }];
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_POSTV2:(NSString *)url action:(nullable NSString *)action cache:(BOOL)cache
                                    parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure {
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    [self setHeaderData:url];
    NSString *URLString = url;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,url];
    }
    NSURLSessionDataTask *dataTask = [self POST:URLString method:@"POST" parameters:tempDict version:@"V2" constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task,id _Nullable responseObject, NSError * _Nonnull error) {
        [self handleFailure:task responseObject: responseObject error:error failure:failure];
    }];
    
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_POSTV2:(NSString *)url action:(nullable NSString *)action
                                    parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                     constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> formData))block
                                      progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure{
    
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    [self setHeaderData:url];
    NSString *URLString = url;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,url];
    }
    //请求网络数据
    NSURLSessionDataTask *dataTask = [self POST:URLString method:@"POST" parameters:tempDict version:@"V2" constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task,id _Nullable responseObject, NSError * _Nonnull error) {
        [self handleFailure:task responseObject:responseObject error:error failure:failure];
    }];
    
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_PUT:(NSString *)url action:(nullable NSString *)action
                                 parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure{
    
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    
    [self setHeaderData:url];
    NSString *URLString = url;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,url];
    }
    NSURLSessionDataTask *dataTask = [self POST:URLString method:@"PUT" parameters:tempDict version:@"V2" constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError * _Nonnull error) {
        [self handleFailure:task responseObject: responseObject error:error failure:failure];
    }];
    
    return dataTask;
}

- (nullable NSURLSessionDataTask *)HTTP_DELETE:(NSString *)url action:(nullable NSString *)action
                                    parameters:(nullable void (^)(id<WQParameterDic> parameter))parameters
                                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject, NSError *error))failure{
    NSParameterAssert(url);
    NSParameterAssert(action);
    
    NSMutableDictionary *tempDict = nil;
    if (parameters) {
        tempDict = [NSMutableDictionary dictionary];
        parameters(tempDict);
    }
    [self setHeaderData:url];
    NSString *URLString = url;
    if (![URLString containsString:SeverAddress]) {
        URLString = [NSString stringWithFormat:@"%@%@",SeverAddress,url];
    }
    NSURLSessionDataTask *dataTask = [self DELETE:URLString parameters:tempDict headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:task response:responseObject success:success failure:failure cache:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailure:task responseObject: nil error:error failure:failure];
    }];
    
    return dataTask;
    
}






- (void)setSessionId:(NSString *)sessionId andKey:(NSString *)key {
    if (sessionId.length == 0 || key.length == 0) {
        [self.requestSerializer clearAuthorizationHeader];
    } else {
        [self.requestSerializer setValue:sessionId forHTTPHeaderField:key];
    }
}


- (void)setHeaderData:(NSString *)url{
//    NSDictionary *userInfor = [[NSUserDefaults standardUserDefaults]objectForKey:@"curryUserToken"];
//    NSString *sessionId = userInfor[@"sessionId"];
//    [self.requestSerializer setValue:sessionId forHTTPHeaderField:@"sessionId"];
    //        sign = md5 (md5(Hc-Time + Hc-Device-Id + Hc-Token + URI) + salt)
    //    NSString *temp = @"";
    //    NSString *urlSub = [url stringByReplacingOccurrencesOfString:temp withString:@""];
    //    NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];
    //    NSString *sign = [NSString stringWithString:timeStr];
    
    //    [self.requestSerializer setValue:timeStr forHTTPHeaderField:@"Hc-Time"]; //请求时间戳，服务端可能判断签名过期时间，请每次请求都取最新值
    //    if ([WQUtility deviceId]) {
    //        NSString *device = [NSString stringWithFormat:@"HC:IOS:%@",[WQUtility deviceId]];
    //        sign = [sign stringByAppendingString:device];
    //        [self.requestSerializer setValue:device forHTTPHeaderField:@"Hc-Device-Id"]; //客服端设备ID, 建议添加 HC: 前缀
    //    }else{
    //        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Hc-Device-Id"];
    //    }
    //    if (APPENGINE.userManager.token) {
    //        sign = [sign stringByAppendingString:APPENGINE.userManager.token];
    //        [self.requestSerializer setValue:APPENGINE.userManager.token forHTTPHeaderField:@"Hc-Token"]; //用户登录成功之后返回的token
    //    }else{
    //        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Hc-Token"];
    //    }
    //    NSString *rand = [self generateTradeNO];
    //    [self.requestSerializer setValue:rand forHTTPHeaderField:@"Hc-Rand"];
    //    sign = [sign stringByAppendingString:newUrl];
    //    sign = [sign stringByAppendingString:rand];
    //    sign = [sign stringByAppendingString:APPENGINE.userManager.salt ? :@""];
    //    NSString *realSign = [sign sha256String];
    //    [self.requestSerializer setValue:realSign forHTTPHeaderField:@"Hc-Sign"]; //生成的签名字符串
    //
    //    [self.requestSerializer setValue:[WQDevice appVersion] forHTTPHeaderField:@"Hc-Version"]; //生成的签名字符串
}

- (NSString *)generateTradeNO
{
    char data[32];
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}


@end

