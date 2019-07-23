//
//  NSMutableDictionary+WQHTTP.m
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import "NSMutableDictionary+WQHTTP.h"

@implementation NSMutableDictionary (WQHTTP)

- (void)setFloat:(float)value forField:(NSString *)field {
    NSAssert(field, @"Field值不能为空！");
    if (field) {
        if (!isnan(value) && value!=NSNotFound) {
            [self setObject:[NSNumber numberWithFloat:value] forKey:field];
        } else {
            NSAssert(false, @"值类型错误！");
            [self setObject:@"" forKey:field];
        }
    }
}

- (void)setDouble:(double)value forField:(NSString *)field {
    NSAssert(field, @"Field值不能为空！");
    if (field) {
        if (!isnan(value) && value!=NSNotFound) {
            [self setObject:[NSNumber numberWithDouble:value] forKey:field];
        } else {
            NSAssert(false, @"值类型错误！");
            [self setObject:@"" forKey:field];
        }
    }
}

- (void)setInteger:(NSInteger)value forField:(NSString *)field {
    NSAssert(field, @"Field值不能为空！");
    if (field) {
        if (!isnan(value) && value!=NSNotFound) {
            [self setObject:[NSNumber numberWithInteger:value] forKey:field];
        } else {
            NSAssert(false, @"值类型错误！");
            [self setObject:@"" forKey:field];
        }
    }
}

- (void)setObject:(id)value forField:(NSString *)field {
    NSAssert(field, @"Field值不能为空！");
    if (field) {
        if ([value isKindOfClass:[NSString class]] ||
            [value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSDictionary class]] ||
            [value isKindOfClass:[NSArray class]]) {
            [self setObject:value forKey:field];
        } else {
            NSAssert(!value, @"值类型错误！");
            [self setObject:@"" forKey:field];
        }
    }
}

- (void)removeObjectForField:(NSString *)field {
    [self removeObjectForKey:field];
}

//设置子参数
- (void)setParameter:(void (^)(id<WQParameterDic> parameter))block forField:(NSString *)field {
    NSAssert(field, @"Field值不能为空！");
    if (field) {
        if (block) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            block(dic);
            [self setObject:dic forKey:field];
        }
    }
}
- (void)setParameterForParams:(void (^)(id<WQParameterDic> parameter))block {
    [self setParameter:block forField:@"data"];
}

@end
