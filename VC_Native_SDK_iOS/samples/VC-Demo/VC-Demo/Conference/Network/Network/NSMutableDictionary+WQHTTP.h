//
//  NSMutableDictionary+WQHTTP.h
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WQParameterDic <NSObject>

- (void)setFloat:(float)value forField:(NSString *)field;
- (void)setDouble:(double)value forField:(NSString *)field;
- (void)setInteger:(NSInteger)value forField:(NSString *)field;

- (void)setObject:(id)value forField:(NSString *)field;
- (void)removeObjectForField:(NSString *)field;

//设置子参数
- (void)setParameter:(void (^)(id<WQParameterDic> parameter))block forField:(NSString *)value;
- (void)setParameterForParams:(void (^)(id<WQParameterDic> parameter))block;
@end 

@interface NSMutableDictionary (WQHTTP)<WQParameterDic>

@end
