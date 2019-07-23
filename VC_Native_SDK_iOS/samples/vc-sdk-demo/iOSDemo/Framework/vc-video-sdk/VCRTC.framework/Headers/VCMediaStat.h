//
//  VCMediaStat.h
//  VCRTC
//
//  Created by starcwl on 12/17/18.
//  Copyright © 2018 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCLegacyStatsReport;

NS_ASSUME_NONNULL_BEGIN

@interface VCMediaStat : NSObject <NSCoding, NSCopying>
/** 用户唯一标识符 */
@property (nonatomic, strong) NSString *uuid;
/** 通道名称: audio: 音频  video视频 */
@property (nonatomic, strong) NSString *mediaType;

/** 远端 本端 send 本端 recv 远端 */
@property (nonatomic, strong) NSString *direction;//send recv

/** 编码格式 */
@property (nonatomic, strong) NSString *codec;
/** 呼叫速率 */
@property (nonatomic, assign) NSInteger bitrate; // unit: kbps
/** 发送或接收数据包的数量 */
@property (nonatomic, assign) NSInteger packets;
/** 发送丢包 */
@property (nonatomic, assign) NSInteger packetsLost;
/** 音视频标识 */
@property (nonatomic, assign) unsigned long ssrc;
/** 分辨率 */
@property (nonatomic, strong) NSString *resolution; // width x height
/** 帧率 */
@property (nonatomic, assign) NSInteger frameRate;
/** 时间戳 */
@property (nonatomic, assign) double timestamp; // unit: milliseconds since 1970;
/** 丢包率 */
@property (nonatomic, assign) double percentageLost; // 100%
/** 抖动 */
@property (nonatomic, assign) double jitter ;

- (NSString *)description;
@end

NS_ASSUME_NONNULL_END
