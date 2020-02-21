//
//  MediaDataHandle.h
//  linphone
//
//  Created by mac on 2019/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MediaStatsLevel) {
    MediaStatsLevel_1 = 0,//最好
    MediaStatsLevel_2,
    MediaStatsLevel_3,
    MediaStatsLevel_4,
    MediaStatsLevel_5,
    MediaStatsLevel_6//无信号
};

typedef NS_ENUM(NSInteger, UserChannel){
    ConferenceVC = 1,//ConferenceViewController
    SingleStreamVC = 2,//SingleStreamViewController
    CalloutVC = 3,//CallingViewController
};
@class VCMediaStat;
@class Participant;
@interface MediaDataHandle : NSObject

/**
 处理质量统计数据

 @param stats 质量统计数据
 @param rosterList 会中参会人
 @param uuid 用户自己的ID
 @param userChannel 使用的地方
 @param block 处理后的数据
 */
+ (void)mediasSatisticsHandel:(NSArray<VCMediaStat *> *)stats rosterList: (NSMutableDictionary<NSString *, Participant *>*)rosterList userSelfUUID: (NSString *)uuid userChannel: (UserChannel)userChannel block:(void (^)(NSMutableArray *array, MediaStatsLevel level))block;
@end

NS_ASSUME_NONNULL_END
