//
//  MediaDataHandle.m
//  linphone
//
//  Created by mac on 2019/9/12.
//

#import "MediaDataHandle.h"
#import "VCMediaStat.h"
#import "Participant.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

@implementation MediaDataHandle
+ (void)mediasSatisticsHandel:(NSArray<VCMediaStat *> *)stats rosterList: (NSMutableDictionary<NSString *, Participant *>*)rosterList userSelfUUID: (NSString *)uuid userChannel: (UserChannel)userChannel block:(void (^)(NSMutableArray *array, MediaStatsLevel level))block {
    NSMutableArray *array = [NSMutableArray array];
    float totalPercentageLost = 0.0;
//    NSLog(@"---------------------%@",stats);
    for (VCMediaStat *stat in stats) {
        NSArray *tempArray = [MediaDataHandle parseMediaStats:stat rosterList:rosterList userSelfUUID:uuid userChannel:userChannel];
        if (tempArray.count) {
            [array addObject:tempArray];
            
        }
        totalPercentageLost += stat.percentageLost;
    }
    if (userChannel == ConferenceVC) {
        [array addObject:@[@"本端CPU",[NSString stringWithFormat:@"%0.1lf%%",[MediaDataHandle conf_appCPUsage]],@"--",@"内存使用",[NSString stringWithFormat:@"%0.1lfMB",[MediaDataHandle conf_memoryUsage]],@"--",@"--",@"--"]];
    }
    MediaStatsLevel level = [MediaDataHandle setNetQualityLevel:totalPercentageLost];
    
    block(array, level);
}

/** 处理数据 */
+ (NSArray *) parseMediaStats: (VCMediaStat *)stat  rosterList: (NSMutableDictionary<NSString *, Participant *>*)rosterList userSelfUUID: (NSString *)uuid userChannel: (UserChannel)userChannel {
    if (userChannel == ConferenceVC) {
        if ([stat.direction isEqualToString:@"recv"] && [stat.mediaType isEqualToString:@"video"]&& [stat.uuid isEqualToString: uuid]) {
            return @[];
        }
    }
    NSMutableArray *mArr = [NSMutableArray array];
    NSString *key = stat.uuid ;
    NSString *display = @"";
    if ([rosterList.allKeys containsObject:key]) {
        Participant *p = rosterList[key];
        display = p.displayName ;
    }
    [mArr addObject:([stat.direction isEqualToString:@"send"] ? @"本端" : ( display.length && stat.uuid != uuid) ? display : @"远端")] ;
    [mArr addObject:[NSString stringWithFormat:@"%@%@",([stat.mediaType isEqualToString:@"audio"] ? @"音频" : @"视频" ),([stat.direction isEqualToString:@"send"] ? @"发送" : @"接收")]];
    [mArr addObject:stat.codec];
    [mArr addObject:stat.resolution ? stat.resolution : @"--" ];
    [mArr addObject:stat.frameRate ? [NSString stringWithFormat:@"%ld",(long)stat.frameRate] : @"--"];
    [mArr addObject:[NSString stringWithFormat:@"%ld",(long)stat.bitrate]];
    [mArr addObject:[NSString stringWithFormat:@"%.0fms",stat.jitter]];
    [mArr addObject:[NSString stringWithFormat:@"%.1f%%",stat.percentageLost]];
    return [mArr copy];
}

+ (float)conf_appCPUsage {
    kern_return_t kr;
    task_info_data_t info;
    mach_msg_type_number_t infoCount = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)info, &infoCount);
    if (kr != KERN_SUCCESS) return -1;
    thread_array_t thread_list; mach_msg_type_number_t thread_count; thread_info_data_t thinfo; mach_msg_type_number_t thread_info_count; thread_basic_info_t basic_info_th;
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) return -1;
    float tot_cpu = 0;
    for (int j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) return -1;
        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_cpu += basic_info_th->cpu_usage/(float)TH_USAGE_SCALE * 100.0;
        }
    }
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    return tot_cpu;
}

+ (float)conf_memoryUsage {
    vm_size_t memory = memory_usage();
    return memory / 1000.0 / 1000.0;
}

vm_size_t memory_usage(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

/** 计算信号登记 */
+ (MediaStatsLevel)setNetQualityLevel: (CGFloat)totalPercentageLost {
    if (totalPercentageLost == 0) {
        return MediaStatsLevel_1;
    } else if (totalPercentageLost > 0 && totalPercentageLost <=1) {
        return MediaStatsLevel_2;
    } else if (totalPercentageLost> 1 && totalPercentageLost <= 2) {
        return MediaStatsLevel_3;
    } else if (totalPercentageLost > 2 && totalPercentageLost <= 5) {
        return MediaStatsLevel_4;
    } else if (totalPercentageLost > 5 && totalPercentageLost <= 10) {
       return MediaStatsLevel_5;
    } else {
       return MediaStatsLevel_6;
    }
}
@end
