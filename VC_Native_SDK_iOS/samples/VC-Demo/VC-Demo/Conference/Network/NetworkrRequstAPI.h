//
//  NetworkManager.h
//  linphone
//
//  Created by mac on 2019/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 公有云我的会诊室
 @param alias 用户账号
 */
@interface NetworkRequstAPI : NSObject

+ (NSURLSessionDataTask *)cloudMeeting: (NSString *)alias success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure;

+ (NSURLSessionDataTask *)loginUserName:(NSString*)address password:(NSString*)password success:(void (^)(id object))success failure:(void (^)(NSInteger code, NSString *message))failure ;

@end

NS_ASSUME_NONNULL_END
