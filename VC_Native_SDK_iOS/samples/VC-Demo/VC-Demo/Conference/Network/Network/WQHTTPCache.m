////
////  WQHTTPCache.m
////  Pods
////
////  Created by Jayla on 16/1/21.
////
////
//
//#import "WQHTTPCache.h"
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface WQHTTPCache ()
//@property (nonatomic, strong) YYDiskCache *diskCache;
//@property (nonatomic, strong) NSURL *cacheUrl;
//@property (nonatomic, strong) NSURL *cacheInfoUrl;
//@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *timeDic;
//@end
//
//@implementation WQHTTPCache
//
//static dispatch_queue_t quque = nil;
//
//- (instancetype)init {
//    @throw [NSException exceptionWithName:@"WQHTTPCache init error"
//                                   reason:@"WQHTTPCache must be initialized with a path. Use 'initWithPath:' instead."
//                                 userInfo:nil];
//    return [self initWithPath:@""];
//}
//
//- (instancetype)initWithPath:(NSString *)path {
//    YYDiskCache *diskCache = [[YYDiskCache alloc] initWithPath:path];
//    diskCache.customArchiveBlock = ^(id object) {
//        NSError *error = nil;
//        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
//        return data;
//    };
//    diskCache.customUnarchiveBlock = ^(NSData *data) {
//        NSDictionary *dic = [data objectFromJSONData];
//        return dic;
//    };
//    if (!diskCache) return nil;
//
//    self = [super init];
//    _diskCache = diskCache;
//    _cacheUrl = [NSURL fileURLWithPath:path];
//    _cacheInfoUrl = [_cacheUrl URLByAppendingPathComponent:@"info.plist"];
//    _timeDic = [NSMutableDictionary dictionaryWithContentsOfURL:_cacheInfoUrl];
//    _timeDic = _timeDic?:[NSMutableDictionary dictionary];
//
//    if (quque == nil) {
//        quque = dispatch_queue_create("com.woqugame.http.chache", NULL);
//    }
//    return self;
//}
//
//+ (instancetype)sharedCache {
//    static WQHTTPCache *httpCache = nil;
//    static dispatch_once_t t;
//    dispatch_once(&t, ^{
//        httpCache = [[self alloc] initWithPath:APPDIRECTORY.httpCacheDir.dirURL.path];
//    });
//    return httpCache;
//}
//
///**********************************************************************/
//#pragma mark - Private
///**********************************************************************/
//
//- (void)setCacheTime:(NSTimeInterval)cacheTime forKey:(NSString *)key {
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(quque, ^{
//        NSNumber *timeNumber = [NSNumber numberWithDouble:cacheTime];
//        [weakSelf.timeDic setObject:timeNumber forKey:key];
//    });
//}
//
//- (void)removeCacheTimeForKey:(NSString *)key {
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(quque, ^{
//        [weakSelf.timeDic removeObjectForKey:key];
//    });
//}
//
//- (void)removeAllCacheTime {
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(quque, ^{
//        [weakSelf.timeDic removeAllObjects];
//    });
//}
//
//- (void)save {
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(quque, ^{
//        if (![weakSelf.timeDic writeToURL:self.cacheInfoUrl atomically:YES]) {
//            DDLogError(@"接口信息写入失败");
//        }
//    });
//}
//
///**********************************************************************/
//#pragma mark - Public
///**********************************************************************/
//
////生成缓存Key
//+ (NSString *)cacheKeyWithUrl:(NSString *)url api:(NSString *)api params:(NSDictionary *)params {
//    NSParameterAssert(url);
//    NSParameterAssert(api);
//    NSParameterAssert(params);
//
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
//    NSString *dataMD5 = [CocoaSecurity md5WithData:data].hex;
//    NSString *cacheKey = [NSString stringWithFormat:@"%@::%@::%@", url, api, dataMD5];
//    return cacheKey;
//}
//
////获取缓存数据
//- (nullable NSDictionary *)getDataForKey:(NSString *)key {
//    return (NSDictionary *)[self.diskCache objectForKey:key];
//}
//- (nullable NSDictionary *)getValidityDataForKey:(NSString *)key {
//    NSTimeInterval expireTime = [[self.timeDic objectForKey:key] doubleValue];
//    if (expireTime > 0) {
//        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
//        if (nowTime >= expireTime) {
//            return nil;
//        }
//    }
//    return (NSDictionary *)[self.diskCache objectForKey:key];
//}
//
////设置缓存数据
//- (void)setData:(NSDictionary *)object forKey:(NSString *)key {
//    [self.diskCache setObject:object forKey:key];
//    [self setCacheTime:0 forKey:key];
//    [self save];
//}
//- (void)setData:(NSDictionary *)object forKey:(NSString *)key duration:(NSTimeInterval)duration {
//    NSDate *cacheTime = [NSDate dateWithTimeIntervalSinceNow:duration];
//    duration = [cacheTime timeIntervalSinceReferenceDate];
//
//    [self.diskCache setObject:object forKey:key];
//    [self setCacheTime:duration forKey:key];
//    [self save];
//}
//
////清除缓存数据
//- (void)cleanCacheForApi:(NSString *)api {
//    __weak typeof(self) weakSelf = self;
//    NSDictionary<NSString *, NSNumber *> *tempDic = [self.timeDic mutableCopy];
//    [tempDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
//        NSArray *tempArray = [key componentsSeparatedByString:@"::"];
//        if (tempArray.count == 3) {
//            NSString *cacheApi = tempArray[1];
//            if ([api isEqualToString:cacheApi]) {
//                [weakSelf removeCacheTimeForKey:key];
//                [weakSelf.diskCache removeObjectForKey:key];
//            }
//        }
//    }];
//    [self save];
//}
//- (void)cleanOutdateCache{
//    __weak typeof(self) weakSelf = self;
//    NSDictionary<NSString *, NSNumber *> *tempDic = [self.timeDic mutableCopy];
//    [tempDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
//        NSTimeInterval expireTime = [obj doubleValue];
//        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
//        if (nowTime >= expireTime) {
//            [weakSelf removeCacheTimeForKey:key];
//            [weakSelf.diskCache removeObjectForKey:key];
//        }
//    }];
//    [self save];
//}
//- (void)cleanAllCache{
//    [self.diskCache removeAllObjects];
//    [self removeAllCacheTime];
//    [self save];
//}
//
//@end
//
//NS_ASSUME_NONNULL_END
