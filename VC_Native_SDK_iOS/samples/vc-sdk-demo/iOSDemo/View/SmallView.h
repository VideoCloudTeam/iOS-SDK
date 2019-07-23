//
//  SmallView.h
//  iOSDemo
//
//  Created by mac on 2019/7/8.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VCRTC/VCRTC.h>
NS_ASSUME_NONNULL_BEGIN

@interface SmallView : UIView
/** 参会者唯一标识符 */
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) VCVideoView *videoView;

/**
 初始化会中显示的视频

 @param videoView VCVideoView实例变量 视频界面
 @param isTurnOffTheCamera 是否关闭摄像头
 @param overlayText 会中显示昵称
 @param isBig YES 大视频视图 NO 小视频视图
 */
+ (instancetype)loadSmallViewWithVideoView: (VCVideoView *)videoView isTurnOffTheCamera: (BOOL)isTurnOffTheCamera withParticipant: (Participant *)participant isBig: (BOOL) isBig uuid: (NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
