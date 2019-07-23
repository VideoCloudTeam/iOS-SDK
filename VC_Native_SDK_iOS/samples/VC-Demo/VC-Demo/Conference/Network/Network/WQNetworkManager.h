//
//  WQNetworkManager.h
//  DNF
//
//  Created by Jayla on 16/5/25.
//  Copyright © 2016年 anzogame. All rights reserved.
//

#import "WQNetworkProtocol.h"
#import "WQNetworkUtil.h"
#import "WQHTTPCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface WQNetworkManager : AFHTTPSessionManager<UIApplicationDelegate, WQNetworkProtocol>
@property (readonly, nonatomic, assign) WQNetworkStatus networkStatus;
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@end
NS_ASSUME_NONNULL_END
