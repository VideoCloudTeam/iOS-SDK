//
//  Participant.h
//  VCRTC
//
//  Created by starcwl on 11/19/18.
//  Copyright © 2018 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Participant : NSObject
/** “in”:呼入；”out”:呼出 */
@property (nonatomic, strong) NSString *callDirection;
/** 参会者的昵称 */
@property (nonatomic, strong) NSString *displayName;
/** YES:是否是当前演示者（双流发送者） */
@property (nonatomic, assign) BOOL isPresenting;
/** 是否静音 */
@property (nonatomic, assign) BOOL isMuted;
/** YES:参会者只有音频通讯 */
@property (nonatomic, assign) BOOL isAudioOnlyCall;
/** 参会者是否有视频能力 */
@property (nonatomic, assign) BOOL isVideoCall;
/** 是否是全体静音 或者 是否被静画 */
@property (nonatomic, assign) BOOL isVmuted;
@property (nonatomic, strong) NSString *localAlias;
/** 在会中显示的昵称 */
@property (nonatomic, strong) NSString *overlayText;
/** 协议类型 */
@property (nonatomic, strong) NSString *protocolType;
/** 入会角色。"guest"：访客；"chair"：主持人 */
@property (nonatomic, strong) NSString *role;
/** 入会时间（UNIX秒） */
@property (nonatomic, strong) NSDate *startTime;
/** 参会者地址 */
@property (nonatomic, strong) NSString *uri;
/** 本参会者的唯一标识uuid */
@property (nonatomic, strong) NSString *uuid;
/** 入会终端/浏览器的厂商标识 */
@property (nonatomic, strong) NSString *vendor;
/** 音视频标识 */
@property (nonatomic, strong) NSString *ssrc;
@property (nonatomic, strong) NSString *serviceType;
/** 参会者为焦点事件 */
@property (nonatomic, assign) int spotlight;
/** 是否是主持人 */
@property (nonatomic, assign) BOOL isChair;
/** YES 等待入会 */
@property (nonatomic, assign) BOOL isWaiting;
/** 正在呼叫中 */
@property (nonatomic, assign) BOOL isConnecting;
/** 正在说话(专属云) */
@property (nonatomic, assign) BOOL isSpeaking;
/** 讲话者指示：0=不在讲话 100=正在讲话 */
@property (nonatomic, assign) int vad;
@property (nonatomic, strong) NSString *cStickUuid ;


- (instancetype)initWithData:(NSDictionary *)data;

- (Participant *)updateWithData:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
