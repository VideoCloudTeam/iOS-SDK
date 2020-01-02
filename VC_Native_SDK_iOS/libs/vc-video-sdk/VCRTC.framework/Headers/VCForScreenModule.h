//
//  VCForScreenModule.h
//  ZJRTC-With-Demo
//
//  Created by 李志朋 on 2019/12/9.
//  Copyright © 2019 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRtcEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@class VCForScreenModule ;

@protocol VCForScreenModuleDelegate <NSObject>

@optional

// 连接到投屏端成功
- (void)connectSuccessed ;

// 连接到投屏端失败
// @param faildType 失败类型
// @param reasonStr 失败原因
- (void)connectFailedWithReason:(VCForScreenFaildType )faildType withStringReason:(NSString *) reasonStr ;

// 远端发送命令断开当前的端
- (void)remoteDisconnect ;

// 投屏内容成功
// @param type 投屏内容的类型
- (void)performForScreenSuccessedWithType:(VCForScreenType )type ;

// 投屏内容失败


// 投屏内容断开
// @param type 投屏内容的类型
// @param reasonType 投屏内容断开的原因

- (void)performDisconnectForScreenWithType:(VCForScreenType )type disconnecReason:(VCForScreenDisconnectReason )reasonType  ;


@end

@interface VCForScreenModule : NSObject

@property (nonatomic, weak) id<VCForScreenModuleDelegate> delegate ;

@property (nonatomic, assign) BOOL sharing ;

+ (instancetype)shareForScreenModule ;

// 根据投屏码连接到终端
- (void)connectForScreenCode:(NSString *)fsCode ;

// 通过录屏的方式投屏
- (void)performForScreenWithRecord:(NSString *)groupId ;

// 通过图片的方式投屏
- (void)performForScreenWithPhoto:(NSData *)imageData ;

// 断开投屏内容
- (void)disconnectPerformForScreen ;

// 断开当前的投屏
- (void)disconnect ;


@end

NS_ASSUME_NONNULL_END
