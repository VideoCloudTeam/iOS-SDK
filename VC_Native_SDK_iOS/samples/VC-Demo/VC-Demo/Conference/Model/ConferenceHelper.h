//
//  ConferenceHelper.h
//  ZJRTC
//
//  Created by 李志朋 on 2019/3/5.
//  Copyright © 2019年 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YCPhotoBrowserConst.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZJMediaStatsLevel){
    ZJMediaStatsLevel_1 = 0,
    ZJMediaStatsLevel_2,
    ZJMediaStatsLevel_3,
    ZJMediaStatsLevel_4,
    ZJMediaStatsLevel_5
};

@class ConferenceHelper ;
@class RTCHelper ;

@protocol ConferenceHelperDelegate <NSObject>

- (void)conferenceHelper:(ConferenceHelper *)helper dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion ;
- (void)conferenceHelper:(ConferenceHelper *)helper didPhotoResource:(NSArray *)selectImages ;
- (void)conferenceHelper:(ConferenceHelper *)helper didRecordTitleView:(BOOL )isShow ;

/* view model */
- (void)conferenceHelper:(ConferenceHelper *)helper didClickStick:(BOOL )stick forButton:(UIButton *)button;
- (void)conferenceHelper:(ConferenceHelper *)helper didHiddenView:(BOOL )hidden ;
- (void)conferenceHelper:(ConferenceHelper *)helper changePage:(NSInteger)page ;
- (void)conferenceHelper:(ConferenceHelper *)helper zoomEndImage:(UIImage *)image ;

@end

@interface ConferenceHelper : NSObject

@property(nonatomic, assign) ZJMediaStatsLevel qualityLevel ;
@property(nonatomic, assign) BOOL needCloseVideo ;
@property(nonatomic, assign) BOOL changeIsBackground ;
@property(nonatomic, weak) id <ConferenceHelperDelegate> delegate ;
@property(nonatomic, strong) RTCHelper *rtcHelper ;

// 注册到通知监听系统，做相应的设置
- (void) conf_registerApps ;
- (void) conf_registerNetworkChange ;
- (void) conf_registerAudioStatus ;
- (void) conf_registerBackgroundFunc ;
- (void) conf_registerForegroundFunc ;
- (void) conf_registerTerminateFunc ;
- (void) conf_removeAllRegister ;

// 检测音视频以及app质量
- (float)conf_appCPUsage ;
- (float)conf_memoryUsage ;
- (NSArray *) conf_parseMediaStats:(NSArray *)stats ;

// 获取资源
- (void)conf_alertGetResources ;
- (void)conf_loadPhotoResources ;
- (void)conf_loadDocumentResources ;
- (void)conf_loadNoRecording ;

// 转移会中部分操作
- (void)conf_doExitChannel ;
- (void)conf_errorExitChannel:(NSString *)errorStr ;
- (void)conf_toggleRecordEnable:(BOOL )enable ;
- (void)conf_toggleLivingEnable:(BOOL )enable ;
- (void)conf_toggleLayoutTag:(NSInteger )tag ;

// 模块化功能 获取会中分享
- (void)conf_setShareInfo:(NSDictionary *)info;



/******************  以下是界面上的 model    *******************/

@property (nonatomic, assign) BOOL livingEnable ;
@property (nonatomic, assign) BOOL recordEnable ;
@property (nonatomic, assign) BOOL sticking ;

- (UIView *)conf_reloadView:(BOOL )isBig localCutClose:(BOOL )isClose withOwner:(NSMutableDictionary *)viewOwner withIndex:(NSInteger )index withSize:(CGSize )size streamCount:(NSInteger )count;

- (UIView *)conf_loadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType )sourceType ;

- (void)conf_reloadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType )sourceType reloadView:(UIView *)presentionView ;


@end

NS_ASSUME_NONNULL_END
