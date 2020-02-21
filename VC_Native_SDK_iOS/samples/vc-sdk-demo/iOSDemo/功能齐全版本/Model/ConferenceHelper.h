//
//  ConferenceHelper.h
//
//  Created by 李志朋 on 2019/3/5.
//  Copyright © 2019年 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YCPhotoBrowserConst.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VCMediaStatsLevel){
    VCMediaStatsLevel_1 = 0,
    VCMediaStatsLevel_2,
    VCMediaStatsLevel_3,
    VCMediaStatsLevel_4,
    VCMediaStatsLevel_5
};

@class ConferenceHelper ;
@class RTCHelper;
@class NameView;

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

@property(nonatomic, assign) VCMediaStatsLevel qualityLevel ;
@property(nonatomic, assign) BOOL needCloseVideo ;
@property(nonatomic, assign) BOOL changeIsBackground ;
@property(nonatomic, weak) id <ConferenceHelperDelegate> delegate ;
@property(nonatomic, strong) RTCHelper *rtcHelper ;

@property(nonatomic, weak) UIViewController *preController ;

// 注册到通知监听系统，做相应的设置
- (void) conf_registerApps ;
- (void) conf_registerNetworkChange ;
- (void) conf_registerAudioStatus ;
- (void) conf_registerBackgroundFunc ;
- (void) conf_registerForegroundFunc ;
- (void) conf_registerTerminateFunc ;
- (void) conf_removeAllRegister ;

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
-(void)conf_setShareInfo:(NSDictionary *)info block:(void (^)(NSString *name))block ;



/******************  以下是界面上的 model    *******************/

@property (nonatomic, assign) BOOL livingEnable ;
@property (nonatomic, assign) BOOL recordEnable ;
@property (nonatomic, assign) BOOL sticking ;

- (UIView *)conf_reloadView:(BOOL )isBig localCutClose:(BOOL )isClose withOwner:(NSMutableDictionary *)viewOwner withIndex:(NSInteger )index withSize:(CGSize )size streamCount:(NSInteger )count;

- (UIView *)conf_loadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType )sourceType ;

- (void)conf_reloadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType )sourceType reloadView:(UIView *)presentionView ;

/**
 会中其他参会者更改了静音状态 即使更新

 @param participants 最新状态的参会者
 @param marrShows 小话面
 @param manageView 小视频画面的父视图
 */
- (void)updateInConferenceParticipantMuteState:(NSArray *)participants marrShows: (NSArray *)marrShows manageView: (UIView *)manageView;

- (NameView *)manage_loadTitleLabel:(NSString *)text hidden:(BOOL )hidden isShowMuteImage: (BOOL)isShowMuteImage isSpeaking: (BOOL) isSpeaking rect: (CGRect)rect isPresentation: (BOOL)isPresentation;
- (void)updatePresenterLabFrameWithOwner:(NSMutableDictionary *)viewOwner manageView: (UIView *)manageView isDownMigration: (BOOL)isDownMigration;
@end

NS_ASSUME_NONNULL_END
