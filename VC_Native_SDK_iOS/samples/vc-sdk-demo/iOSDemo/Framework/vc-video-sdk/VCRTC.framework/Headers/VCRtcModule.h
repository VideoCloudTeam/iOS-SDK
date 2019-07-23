//
//  VCRtcModule.h
//  webrtc-iOS-demo
//
//  Created by starcwl on 11/6/18.
//  Copyright © 2018 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRtcEnumerates.h"
#import <UIKit/UIKit.h>

@class RTCMediaStream;
@class RTCPeerConnectionFactory;
@class VCRtcModule;
@class VCVideoView;
@class Participant;
@class VCMediaStat;

NS_ASSUME_NONNULL_BEGIN
typedef void(^successBlock)(id response);
typedef void(^failureBlock)(NSError * error);
@protocol VCRtcModuleDelegate <NSObject>
@optional

- (void)VCRtc:(VCRtcModule *)module didAddChannelViewController:(UIViewController *)view NS_DEPRECATED_IOS(9_0,9_0,"该方法已废弃");

/**
 接收远端视频
 
 @param module VCRtcModule 的实例对象
 @param view 承载远端视频的界面
 @param uuid 当前视频所对应参会者的唯一标识
 */
- (void)VCRtc:(VCRtcModule *)module didAddView:(VCVideoView *)view uuid:(NSString *)uuid;

/**
  删除远端视频

 @param module VCRtcModule 的实例对象
 @param view 承载远端视频的界面
 @param uuid 当前视频所对应参会者的唯一标识
 */
- (void)VCRtc:(VCRtcModule *)module didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid;

/**
 接收本地视频,也就是用户自己的视频

 @param module  VCRtcModule 的实例对象
 @param view 承载本地视频的界面
 */
- (void)VCRtc:(VCRtcModule *)module didAddLocalView:(VCVideoView *)view;

/**
 加入新的参会者(有新的参会者加入会调用)

 @param module VCRtcModule 的示例对象
 @param participant 新加入的参会者信息
 */
- (void)VCRtc:(VCRtcModule *)module didAddParticipant:(Participant *)participant;

/**
 参会者信息变更(参会者信息变更是调用)

 @param module VCRtcModule 的示例对象
 @param participant 该参会者信息变更后信息
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateParticipant:(Participant *)participant;

/**
 参会者离开会议

 @param module VCRtcModule 的示例对象
 @param participant 离开后的参会者
 */
- (void)VCRtc:(VCRtcModule *)module didRemoveParticipant:(Participant *)participant;

/**
 接收到其他参会者发的消息

 @param module VCRtcModule 的示例对象
 @param message 消息内容
 */
- (void)VCRtc:(VCRtcModule *)module didReceivedMessage:(NSDictionary *)message;

/**
 获取会中正在发言的参会者列表

 @param module VCRtcModule 实例对象
 @param voices 正在发言的参会者列表(vad为100时代表此参会者正在发言)
 */
- (void)VCRtc:(VCRtcModule *)module didReceivedStageVoice:(NSArray *)voices;

/**
 获取音视频质量参数

 @param module  VCRtcModule 实例对象
 @param mediaStats 音视频参数数组
 */
- (void)VCRtc:(VCRtcModule *)module didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats;

/**
 获取会中正在展示视频的参会者列表

 @param module VCRtcModule 实例对象
 @param participants 正在显示视频的参会者列表
 */
- (void)VCRtc:(VCRtcModule *)module didLayoutParticipants:(NSArray *)participants;

/**
 会中有参会者发起分享

 @param module  VCRtcModule 实例对象
 @param shareUuid 分享端的参会者标识
 */
- (void)VCRtc:(VCRtcModule *)module didStartImage:(NSString *)shareUuid;

/**
 接收到其他端更新发送的图片分享

 @param module  VCRtcModule 实例对象
 @param imageStr 分享的图片地址
 @param uuid 分享端的参会者唯一标识
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateImage:(NSString *)imageStr uuid:(NSString *)uuid;

/**
 接收其他端更新发送的视频分享

 @param module  VCRtcModule 实例对象
 @param imageStr 分享的图片地址
 @param uuid 分享端的参会者标识
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateVideo:(NSString *)imageStr uuid:(NSString *)uuid;

/**
 获取到其他端或版本端的停止分享事件

 @param module  VCRtcModule 实例对象
 @param imageStr 分享的图片地址
 */
- (void)VCRtc:(VCRtcModule *)module didStopImage:(NSString *)imageStr;

/**
 获取到当前会议的录制直播状态

 @param module  VCRtcModule 实例对象
 @param data 录制、直播状态 [data[@"isrecord"] boolValue] == YES 开启录制 NO关闭录制 [data[@"isliving"] boolValue] == YES 开启直播 NO关闭直播
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateRecordAndlive:(NSDictionary *)data;

/**
 获取到当前会议的布局状态
 调用该方法后
- (void)updateLayoutHost:(NSString *)layout guest:(NSString *)glayout conferenceType:(VCConferenceType )type success:(successBlock)success failure:(failureBlock)failure
 会回调didUpdateLayout方法
 @param module  VCRtcModule 实例对象
 @param data 布局状态 data[@"layout"] 主持人布局 值为: "1：0"、"4：0"、"1：7"、"1：21"、"2：21"  data[@"glayout"] 访客布局值类型跟主持人布局相同
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateLayout:(NSDictionary *)data ;

/**
 获取到当前会议的会议状态
 当调用了
 - (void)muteAllGuest:(BOOL )mute
 success:(successBlock)success
 failure:(failureBlock)failure
 或
 -
 (void)lockMeeting:(BOOL )lock
 success:(successBlock)success
 failure:(failureBlock)failure
 -
 (void)enableRecordSuccess:(successBlock)success
 failure:(failureBlock)failure ;
 - (void)disableRecordSuccess:(successBlock)success
 failure:(failureBlock)failure ;
 - (void)enableLiveSuccess:(successBlock)success
 failure:(failureBlock)failure ;
 - (void)disableLiveSuccess:(successBlock)success
 failure:(failureBlock)failure
 
 会回调该方法
 @param module  VCRtcModule 实例对象
 @param data 全体静音、锁定会议状态 [data[@"locked"] integerValue] == 1 锁定会议
 [data[@"guests_muted"] integerValue] == 1 访客全体静音
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateConferenceStatus:(NSDictionary *)data;

/**
 会中参会者增删改后的最新的参会者列表 或者参会者信息有变

 @param module VCRtcModule 的实例对象
 @param participants 最新参会者数据
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateParticipants:(NSArray *)participants;

/**
 接收到当前参会者被其他参会者修改身份

 @param module  VCRtcModule 实例对象
 @param role 参会者身份 host 主持人 guest 访客
 */
- (void)VCRtc:(VCRtcModule *)module didChangeRole:(NSString *)role;

/**
 接收到其他参会者开启白板

 @param module VCRtcModule 实例对象
 @param shareUrl 分享白板的链接
 @param uuid 分享者的标识
 */
- (void)VCRtc:(VCRtcModule *)module didStartWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid ;

/**
 接受到其他参会者关闭白板

 @param module VCRtcModule 实例对象
 @param shareUrl 分享白板的链接
 @param uuid 分享者的标识
 */
- (void)VCRtc:(VCRtcModule *)module didStopWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid ;

/**
 加入会议失败
 
 @param module VCRtcModule 的示例对象
 @param reason 失败原因
 */
- (void)VCRtc:(VCRtcModule *)module didDisconnectedWithReason:(NSError *)reason;

@end

@interface VCRtcModule : NSObject

@property(nonatomic, weak) id <VCRtcModuleDelegate> delegate;
/** 服务器域名 */
@property(nonatomic, strong) NSString *apiServer;
/** 开启直播、录播域名 */
@property(nonatomic, strong) NSString *liveServer;
/** 屏幕录制 apple developer 申请的groupId */
@property(nonatomic, strong) NSString *groupId;
/** 带宽 默认:1024kbps*/
@property(nonatomic, assign) NSUInteger bandwidth;
/** 当前用户的唯一标识符 */
@property(nonatomic, strong, readonly) NSString *uuid;
/** 参会者信息列表 */
@property(nonatomic, strong, readonly) NSMutableDictionary<NSString *, Participant *> *rosterList;
/** 显示在视频上的布局参会者 */
@property(nonatomic, strong, readonly) NSArray<NSString *> *layoutParticipants;
@property(nonatomic, strong) NSString *oemId; // only shitong;
/** 屏幕旋转方向 默认none */
@property(nonatomic, assign) UIDeviceOrientation forceOrientation;
/** 参会者身份 */
@property (nonatomic, strong) NSString *role ;
/** 支持直播功能 */
@property (nonatomic, assign) BOOL isSupportLive ;
/** 支持录制功能 */
@property (nonatomic, assign) BOOL isSupportRecord ;
/** 呼叫的名称 */
@property (nonatomic, strong) NSString *callName ;
/** 会中分享的image地址 */
@property (nonatomic, strong) NSString *shareImageURL;
/** 图片、PDF分享成流时使用。 */
@property (nonatomic, strong) NSString *localShareUuid ;
/** 音视频连接类型 */
@property (nonatomic, assign) VCCallType callType ;
/** 会议连接类型 */
@property (nonatomic, assign) VCConnectType connectType ;

/** 单例*/
+ (instancetype)sharedInstance;

/* ------ 参加当前会议，并对当前会议音视频管理 ------ */

/**
 登录用户名到平台(该方法已经废弃)
 
 @param name 登录名
 @param password 登录密码
 @param phone 注册使用手机号
 @param nickname 登录名称
 */
- (void)loginWithUsername:(NSString *)name
                 password:(NSString *)password
                    phone:(NSString *)phone
                 nickname:(NSString *)nickname
                  success:(successBlock)success
                  failure:(failureBlock)failure NS_DEPRECATED_IOS(9_0,9_0,"该方法已废弃");

/**
 加入会议
 
 @param channel 会议短号或长地址 (必填)
 @param password 入会密码 (必填) ,若当前会议室没有密码,传空字符串
 @param name 入会显示名称 (必填)
 */
- (void)connectChannel:(nonnull NSString *)channel
              password:(NSString *)password
                  name:(nonnull NSString *)name
               success:(void (^)(id))success
               failure:(void (^)(NSError *error))failure ;

/**
 配置连接会议的类型
 
 @param connectType 连接会议的类型
 VCConnectTypeMeeting 音视频会议 (默认)  VCConnectTypeUser 点对点间呼叫
 VCConnectTypeOnlyManager 仅会议管理加入 VCConnectTypeHideMe 观看会议，并不参见会议
 */
- (void)configConnectType:(VCConnectType )connectType ;

/**
 配置为专属云模型会议室
 
 @param privateCloud 是否为专属云会议室,默认为NO
 */
- (void)configPrivateCloudPlatform:(BOOL ) privateCloud;

/**
 配置音视频呼叫速率 (同时配置接收、发送呼叫速率，多流模式下,接收速率参数无效)

 @param bandwidth 音视频呼叫速率 默认为800kbps
 */
- (void)configBandwidth:(CGFloat ) bandwidth ;

/**
 配置音视频接收呼叫速率 (多流模式下,设置此参数无效)

 @param bandwidth 音视频呼叫速率 默认为800kbps
 */
- (void)configReceiveBandwidth:(CGFloat ) bandwidth ;

/**
 配置音视频发送呼叫速率
 
 @param bandwidth 音视频呼叫速率 默认为800kbps
 */
- (void)configSendBandwidth:(CGFloat ) bandwidth ;

/**
 配置视频帧率 (同时配置接收、发送帧率，多流模式下,接收帧率参数无效)
 
 @param frameRate 视频帧率 默认为25fps
 */
- (void)configFrameRate:(CGFloat ) frameRate ;

/**
 配置视频接收帧率 (多流模式下,设置此参数无效)
 
 @param frameRate 视频帧率 默认为25fps
 */
- (void)configReceiveFrameRate:(CGFloat ) frameRate ;

/**
 配置视频发送帧率 (多流模式下,设置此参数无效)
 
 @param frameRate 视频帧率 默认为25fps
 */
- (void)configSendFrameRate:(CGFloat ) frameRate ;

/**
 配置发送、接收的视频分辨率 (多流模式下,设置此参数无效) 默认为 960x540

 @param width 视频分辨率宽
 @param height 视频分辨率高
 */
- (void)configResolutionWidth:(NSInteger )width
                    andHeight:(NSInteger )height ;

/**
 配置发送的视频分辨率 (多流模式下,设置此参数无效) 默认为 960x540
 
 @param width 视频分辨率宽
 @param height 视频分辨率高
 */
- (void)configSendResolutionWidth:(NSInteger )width
                        andHeight:(NSInteger )height ;

/**
 配置接收的视频分辨率 (多流模式下,设置此参数无效) 默认为 960x540
 
 @param width 视频分辨率宽
 @param height 视频分辨率高
 */
- (void)configReceiveResolutionWidth:(NSInteger )width
                           andHeight:(NSInteger )height ;

/**
 配置音视频质量参数
 
 @param profile 预先设置好的音视频配置选项
 VCVideoProfileNone 不做参数设置
 VCVideoProfile720P 分辨率:1280x720 帧率:30fps
 VCVideoProfile480P 分辨率:640x480 帧率:25fps
 VCVideoProfile360P 分辨率:640x360 帧率:20fps
 VCVideoProfile180P 分辨率:320x180 帧率:20fps
 VCVideoProfileCustom 自定义 分辨率、帧率

 VCVideoProfile480P(默认)
 */
- (void)configVideoProfile:(VCVideoProfile )profile ;

/** 配置音视频接收的方式
 *
 * @param multistream 模式为多流
 */
- (void)configMultistream:(BOOL )multistream ;

/** 配置默认入会后静麦克风
 *
 * @param mute 静麦克风
 */
- (void)configSelectMute:(BOOL )mute ;

/** 配置主叫方的呼叫账号

 @param account 主叫账号
 */
- (void)configLoginAccount:(NSString *)account ;

/** 配置点对点接听 设置的参数

 @param token 平台信令
 @param bsskey bss平台验证key值
 @param timeStamp 呼叫的时间戳
 @param owner 真实通过的MCU地址
 */
- (void)configPTPOneTimeToken:(NSString *)token
                    andBsskey:(NSString *)bsskey
                     andStamp:(NSString *)timeStamp
                        owner:(NSString *)owner ;

/**
 配置呼入的音视频类型
 
 @param callType 音视频类型 详见 VCCallType
 */
- (void)configCallType:(VCCallType )callType ;

/**
 打开/禁用本地麦克风

 @param enabled 麦克风使用
 */
- (void)micEnable:(BOOL)enabled;

/**
 打开/禁用本地相机
 
 @param enabled 相机使用
 */
- (void)videoEnable:(BOOL)enabled;

/** 切换前后摄像头 */
- (void)switchCamera;

/**
 重新设置本地显示布局
 
 @param clayout 期望布局
 */
- (void)resetClayout:(NSString *)clayout ;

/**
 打开仅语音模式
 
 @param enabled 打开仅语音模式
 */
- (void)onlyAudioEnable:(BOOL)enabled  ;

/**
 重新连接本地音视频
 
 入会后主动获取本地视频，调用后，
 可通过 - (void)VCRtc:(VCRtcModule *)module didAddLocalView:(VCVideoView *)view;
 接收当前连接的本地视频
 */
- (void)reloadLocalVideo ;

/** 只连接音视频 用在先入会，后需要音视频时直接加入到音视频参会 */
- (void)connectMediaCall ;

/** 重建音视频 出现断网或者改变网络节点的情况下调用 */
- (void)reconstructionMediaCall ;

/**
 打开音视频质量参数监听
 
 @param enable 是否打开
 可通过 - (void)VCRtc:(VCRtcModule *)module didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats ;
 接收到当前能收到的音视频质量参数
 */
- (void)enableStatistics:(BOOL)enable;

/** 当前账号退出会议，断开媒体连接 */
- (void)exitChannelSuccess:(successBlock)success
                   failure:(failureBlock)failure;

/**
 打开SDK 中日志写入成文件

 @param name 写入地址
 @param URLString 地址
 */
- (void)uploadLoggerWithName:(NSString *)name
                   URLString:(NSString *)URLString;

/** 结束当前会议 (需要验证当前参会者为主持人身份) */
- (void)closeChannelSuccess:(successBlock)success
                    failure:(failureBlock)failure;

/* ------ 会议管理，当前仅部分身份参会者可用 ------ */

/** 在会中发送文字信息

 @param message 文字信息
 */
- (void)sendMessage:(NSString *)message
            success:(successBlock)success
            failure:(failureBlock)failure ;

/** 邀请平台下通讯录的地址
 protocol: 专属云环境下默认是:sip 公有云默认:auto 参会者身份是访客 streaming NO
 @param dest 通讯录地址
 */
- (void)inviteDesitination:(NSString *)dest
                   success:(successBlock)success
                   failure:(failureBlock)failure ;

/** 邀请其他参会人

 @param dest 通讯地址
 @param protocolType 通讯类型
 @param name 入会显示名称
 @param isHost 参会身份
 @param isStreaming 发送流方式
 */
- (void)inviteDestination:(NSString *)dest
                 protocol:(NSString *)protocolType
                    alias:(NSString *)name
                     host:(BOOL)isHost
                streaming:(BOOL)isStreaming
                  success:(successBlock)success
                  failure:(failureBlock)failure ;

/** 开启录制 */
- (void)enableRecordSuccess:(successBlock)success
                    failure:(failureBlock)failure ;

/** 关闭录制 */
- (void)disableRecordSuccess:(successBlock)success
                     failure:(failureBlock)failure ;

/** 开启直播 */
- (void)enableLiveSuccess:(successBlock)success
                  failure:(failureBlock)failure ;

/** 关闭直播 */
- (void)disableLiveSuccess:(successBlock)success
                   failure:(failureBlock)failure ;

/**
 锁定会议

 @param lock 锁定会议
 */
- (void)lockMeeting:(BOOL )lock
            success:(successBlock)success
            failure:(failureBlock)failure ;

/**
 静音全部访客

 @param mute 静音
 */
- (void)muteAllGuest:(BOOL )mute
             success:(successBlock)success
             failure:(failureBlock)failure ;


/**
 分享图片类型到会中

 @param imageData 图片数据
 @param open 打开分享
 @param change 更新分享，NO为重建分享
 */
- (void)shareImageData:(NSData *)imageData
                  open:(BOOL )open
                change:(BOOL )change
               success:(successBlock)success
               failure:(failureBlock)failure ;

/**
 分享图片类型为视频流方式到会中

 @param imageData 图片数据
 @param open 打开分享
 @param change 更新分享，NO为重建分享
 */
- (void)shareToStreamImageData:(NSData *)imageData
                          open:(BOOL )open
                        change:(BOOL )change
                       success:(successBlock)success
                       failure:(failureBlock)failure ;

/**
 分享图片类型为白板方式到会中

 @param open 打开分享
 */
- (void)shareToWhiteOpen:(BOOL )open
                 success:(successBlock)success
                 failure:(failureBlock)failure ;

- (void)configUseDefultViewController:(BOOL )isUsed NS_DEPRECATED_IOS(9_0,9_0,"该方法已废弃") ;

/** 当前分享被其他端打断后，要自动关闭本地分享资源 */
- (void)shareToRemoteDisconnect ;

/**
 更改参会者视频布局

 @param layout 主持人布局 前仅支持可以传的值 1：0、4：0、1：7、1：21、2：21
 @param glayout 访客布局 可传空 前仅支持可以传的值 1：0、4：0、1：7、1：21、2：21
 @param type 会议室类型
 @param success {
 "status": "success",
 "result": true
 }
 */
- (void)updateLayoutHost:(NSString *)layout
                   guest:(NSString *)glayout
          conferenceType:(VCConferenceType )type
                 success:(successBlock)success
                 failure:(failureBlock)failure ;

/**
 某个参会者静音或取消静音 isMute YES静音 NO取消静音
 @param participant 参数格式: @{@"uuid":@"参会者唯一标识符",@"isMute":[NSNumber numberWithBool:YES]}
 */
- (void)muteParticipant:(NSDictionary *)participant
                success:(successBlock)success
                failure:(failureBlock)failure ;

/**
 移除参会者

 @param participant 参数格式: @{@"uuid":@"参会者唯一标识符"}
 */
- (void)removeParticipant:(NSDictionary *)participant
                  success:(successBlock)success
                  failure:(failureBlock)failure;

/**
 修改参会者在会中显示的名

 @param participant :@{@"uuid":@"参会者唯一标识符"}
 @param changedName 参会者在会中显示的名
 */
- (void)changeNameParticipant:(NSDictionary *)participant
                  withNewName:(NSString *)changedName
                      success:(successBlock)success
                      failure:(failureBlock)failure;

/**
 更改参会者角色

 @param participant isChair: YES主持人 NO访客 数据格式:@{@"uuid":@"参会者唯一标识符",@"isChair":[NSNumber numberWithBool:YES]}
 */
- (void)changeRoleParticipant:(NSDictionary *)participant
                      success:(successBlock)success
                      failure:(failureBlock)failure;

/**
 会议锁定的状态下,不允许访客入会

 @param participant 数据格式: @{@"uuid":@"参会者唯一标识符"}
 */
- (void)refusedToParticipant:(NSDictionary *)participant
                     success:(successBlock)success
                     failure:(failureBlock)failure;

/**
 会议锁定状态下,允许访客入会

 @param participant 数据格式: @{@"uuid":@"参会者唯一标识符"}
 */
- (void)allowParticipant:(NSDictionary *)participant
                 success:(successBlock)success
                 failure:(failureBlock)failure;

/**
 指定参会者为焦点,设置后参会者的视频显示在会议中的第一位 spotlight: 值为0 设置为焦点

 @param participant 数据格式: @{@"uuid":@"参会者唯一标识符", @"spotlight": [NSNumber numberWithInt:0]}
 */
- (void)spolightParticipant:(NSDictionary *)participant
                    success:(successBlock)success
                    failure:(failureBlock)failure;

/**
 设置为本地主屏

 @param participant 参会者唯一标识符
 @param stick 开启设置为本地主屏
 */
- (void)stickParticipant:(NSString *)participant
                 onStick:(BOOL )stick
                 success:(successBlock)success
                 failure:(failureBlock)failure ;

/** 主动停止屏幕录制 */
- (void)stopRecordScreen ;


@end

NS_ASSUME_NONNULL_END
