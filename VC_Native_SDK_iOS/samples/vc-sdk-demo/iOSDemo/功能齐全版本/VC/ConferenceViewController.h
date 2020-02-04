//
//  ConferenceViewController.h
//
//  Created by 李志朋 on 2018/12/5.
//  Copyright © 2018年 zijingcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInMeetingVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceViewController : BaseInMeetingVC

///** 音频静音 */
@property (nonatomic, assign) BOOL audioMute;
///** 关闭本地视频 */
@property (nonatomic, assign) BOOL videoMute;
///** 是否是接听来电视频 */
//@property (nonatomic, assign) BOOL incomming;
/** 是否是专属云呼叫视频 */
@property (nonatomic, assign) BOOL viaCalling; // 不知道为什么会多一个音频，特用此区分
@property (nonatomic, strong) UIViewController *preControl ;

@end

NS_ASSUME_NONNULL_END
