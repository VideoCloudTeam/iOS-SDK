//
//  ShareModel.h
//  iOSDemo
//
//  Created by mac on 2019/7/10.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareModel : NSObject
/**

分享类型 local本端分享图片 remote 远端分享(图片或屏幕共享) none暂时没有分享
 localScreenShare 本端屏幕共享(即录制屏幕) local_remote 抢其他人的分享
 本端: 代表自己
 远端: 其他参会者
 注意:公有云环境下 远端和本端屏幕共享生成的都是一帧一帧的图片
 */
@property (nonatomic, copy) NSString *shareType;
/** 是否正在分享 */
@property (nonatomic, assign) BOOL isSharing;
/** 分享人的唯一标识 */
@property (nonatomic, copy) NSString *uuid;
@end

NS_ASSUME_NONNULL_END
