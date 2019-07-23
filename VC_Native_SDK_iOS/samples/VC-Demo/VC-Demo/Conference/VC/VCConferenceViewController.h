//
//  VCConferenceViewController.h
//  VCRTC
//
//  Created by 李志朋 on 2018/12/5.
//  Copyright © 2018年 zijingcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCRtcEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCConferenceViewController : UIViewController

@property (nonatomic, strong) NSString *channel;
@property (nonatomic, assign) BOOL isSupportLive ;
@property (nonatomic, assign) BOOL isSupportRecord ;
@property (nonatomic, assign) BOOL selectMute ;
@property (nonatomic, assign) BOOL incomming ;
@property (nonatomic, assign) BOOL isFormAppointment;//是否来源于预约

@property (nonatomic, strong) NSDictionary *shareUrl ;

@end

NS_ASSUME_NONNULL_END
