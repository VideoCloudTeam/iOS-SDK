//
//  ZJMeeting.h
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Success) ( id  result);
typedef void (^Failure) ( NSError * error);

/*
 入会错误类型
 */
typedef NS_ENUM(NSInteger,ZJJoinMeetingErrorType) {
    
    ///连接服务器成功
    ZJJoinMeetingSeverConnetSuss                  = 0,
    ///连接服务器失败，检查服务器地址
    ZJJoinMeetingSeverConnetfill                  = 1,
    ///登录成功
    ZJJoinMeetingLoginSuss                        = 600,
    ///登录失败
    ZJJoinMeetingLoginFailure                     = 601,
    ///入会成功
    ZJJoinMeetingSuss                             = 700,
    /// 未知错误
    ZJJoinMeetingErrorType_unknowError            = 404,
    /// 参数非法
    ZJJoinMeetingErrorType_paramsIllegal          = 500,
    /// 连接服务器超时
    ZJJoinMeetingErrorType_connectServerTimeout   = 1000,
    /// 服务挂断
    ZJJoinMeetingErrorType_peerClosed             = 1001,
    /// 自己断开链接
    ZJJoinMeetingErrorType_selfClosed             = 1002,
    /// 心跳断开
    ZJJoinMeetingErrorType_noKeepAlive            = 1003,
    /// 服务拒绝连接
    ZJJoinMeetingErrorType_peerRejectedConnection = 1004,
    /// 会议结束
    ZJJoinMeetingErrorType_meetingFinished        = 1301,
    /// 被管理员踢出
    ZJJoinMeetingErrorType_kickedOutByAdmin       = 1302,
    /// 会议ID未找到
    ZJJoinMeetingErrorType_meetingIdNotFound      = 1401,
    /// 达到会议最大人数
    ZJJoinMeetingErrorType_upToMaxMeetingCount    = 1402,
    /// 未找到会议
    ZJJoinMeetingErrorType_meetingNotFound        = 1403,
    /// 会议密码不正确
    ZJJoinMeetingErrorType_pwdForRoomNotRight     = 1416,
    /// 会议锁定
    ZJJoinMeetingErrorType_meetingLocked          = 1417
};


@class ZJMeeting ;

//管理类代理
@protocol ZJMeetingDelegate <NSObject>
@optional

//SDK会议消息
- (void)registerOnRemotreResponseLister:(id) response ;
//回调会议控制器
- (void)onMeetingVC:(UIViewController *)meetingVC;
//登录后获取的私人会议室信息
- (void)onRoomInfoCallBack:(id)roomInfo;

@end

@interface ZJMeeting : NSObject

@property(nonatomic,weak)id <ZJMeetingDelegate> delegate;

/* 单例模式 */
+ (instancetype) ZJMeetingShareInstance ;

/*
 注册公司标识
 
 @param conpanyid  公司唯一标识
 */
- (void)initSDKWithCompanyID:(NSString *)companyid;

/**
 配置服务器

 @param server 服务器地址
 @param port 端口地址
 */
- (void)connectServer:(NSString *)server
              andPort:(NSString *)port ;

/*
 登录用户
 
 @param username    用户名
 @param upwd        用户密码
 @param phonenum    电话号码
 @param name        用户昵称
 */
- (void)userName:(NSString *)username
 andUserPassword:(NSString *)upwd
     andPhoneNum:(NSString *)phonenum
     andNickName:(NSString *)name ;

/*
 进入会议
 
 @param severid     会议地址
 @param meetingnum  会议号码
 @param mpwd        会议密码
 @param bw          带宽
 @param nickname    用户昵称
 */
- (void)enterMeetingSeverID:(NSString *)severid
              andMeetingNum:(NSString *)meetingnum
              andMeetingPwd:(NSString *)mpwd
               andBandwidth:(int )bw
                andNickName:(NSString *)nickname ;

@end

NS_ASSUME_NONNULL_END
