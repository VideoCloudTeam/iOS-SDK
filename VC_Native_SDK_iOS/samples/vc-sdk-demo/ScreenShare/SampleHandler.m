//
//  SampleHandler.m
//  ScreenShare
//
//  Created by mac on 2019/6/28.
//  Copyright © 2019 mac. All rights reserved.
//


#import "SampleHandler.h"//
//#import "ScreenHelper.h"
#import <ZJRTCScreenShare/ZJRTCScreenShare.h>
#import <VCRTC/VCRTC.h>

@interface SampleHandler ()
@property (nonatomic, strong) ScreenHelper *screenHelper;
//存储屏幕录制状态
@property (nonatomic, strong) NSUserDefaults *userDefault;
@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    self.screenHelper = [ScreenHelper sharedInstance];
    //1.配置GroupId
    self.screenHelper.groupId = kGroupId ;
    self.userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.screenHelper.groupId];
    //开始录制屏幕,保存当前录制状态
    [self.userDefault setObject:@"start" forKey:kScreenRecordState];
    //2. 链接到分享
    [self.screenHelper connect];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.

}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.

}

- (void)broadcastFinished {
    //停止录制 保存当前停止录制状态
    [self.userDefault setObject:@"stop" forKey:kScreenRecordState];
}
- (void)stopRecordScreenTitle:(NSString *)errorReason{
    //录制出错,停止录制
    [self.userDefault setObject:@"stop" forKey:kScreenRecordState];
    [self.userDefault synchronize];
    
    NSDictionary *userInfo1 = [NSDictionary dictionaryWithObjectsAndKeys:@"", NSLocalizedDescriptionKey, errorReason, NSLocalizedFailureReasonErrorKey, @"",NSLocalizedRecoverySuggestionErrorKey,nil];
    NSError *error = [NSError errorWithDomain:@"" code:200 userInfo:userInfo1];
    //停止录制操作
    [self finishBroadcastWithError:error];
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    //屏幕录制状态
    NSString *openStates = [self.userDefault objectForKey:kScreenRecordState];
    //会议状态
    NSString *meetingStates = [self.userDefault objectForKey:kScreenRecordMeetingState];
    if ([meetingStates isEqualToString:@"outmeeting"]) {
    }
    if ([openStates isEqualToString:@"appfinsh"]) {
        [self stopRecordScreenTitle:@"您退出了应用，屏幕录制自动断开。"];
    }
    if ([openStates isEqualToString:@"appstop"]) {
        [self stopRecordScreenTitle:@"您停止了屏幕录制。"];
    }
    
    if ([openStates isEqualToString:@"stop"]) {
        [self stopRecordScreenTitle:@"其他参会者正在分享，您被中断。"];
    }
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            //3.更新录制屏幕的数据流
            [self.screenHelper didCaptureSampleBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

@end
