//
//  ConferenceViewController.m
//
//  Created by 李志朋 on 2018/12/3.
//  Copyright © 2018年 zijingcloud. All rights reserved.
//

#import "ConferenceViewController.h"
#import "VCRtcModule.h"
#import "Participant.h"
#import "VCVideoView.h"
#import "VCMediaStat.h"
#import "UIView+Frame.h"
#import "ConferenceHelper.h"
//#import "VCManageViewController.h"
#import "RTCHelper.h"
#import "NSMutableAttributedString+VCAttributedString.h"
#import <ReplayKit/ReplayKit.h>

#import "ManageNavigationController.h"

#import "MXActionSheet.h"
#import "ActionModel.h"
#import "UIView+AddViewProperty.h"
#import "VCWhiteBoardView.h"
#import "NSMutableAttributedString+VCAttributedString.h"


typedef void(^compate)(UIImage *image);

API_AVAILABLE(ios(12.0))
@interface ConferenceViewController ()
<VCRtcModuleDelegate,
ConferenceHelperDelegate,
RTCHelperMediaDelegate> {
    int timeCount;
    BOOL imageLock;
}

@property (nonatomic, strong) NSMutableArray *streamShareVideos ;
@property (nonatomic, strong) NSMutableArray *streamFrames ;
@property (nonatomic, strong) NSArray *layoutParticipants ;
@property (nonatomic, strong) NSMutableDictionary *localOnwers ;

@property (nonatomic, strong) UIView *manageView ;     // 会中 全编全解/多流 展示
@property (nonatomic, strong) UIView *presentationView; // 分享展示
@property (nonatomic, strong) UIView *recordScreenView;
@property (nonatomic, strong) UIView *onlyAudioView;
@property (nonatomic, strong) UIView *titleView ;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) YCPhotoSourceType photoType;
/** 设为主屏的参会者UUID */
@property (nonatomic, strong) NSString *stickUuid;
/** 分享状态 */
@property (nonatomic, strong) NSString *sharingStuts ;
@property (nonatomic, assign) BOOL frontCamera;
/** 开启画中画 */
@property (nonatomic, assign) BOOL loadSmallView ;
@property (nonatomic, assign) BOOL sharing ;
@property (nonatomic, assign) BOOL localSharing ;
@property (nonatomic, assign) BOOL remoteSharing ;
@property (nonatomic, assign) BOOL exSharing ;
/** 是否显示锁屏 */
@property (nonatomic, assign) BOOL isShowStickOpen ;
@property (nonatomic, assign) BOOL isShowStickClose;
/** 是否锁屏 */
@property (nonatomic, assign) BOOL isStickOne ;
@property (nonatomic, assign) BOOL isRecording ;
@property (nonatomic, assign) BOOL isLiving ;
@property (nonatomic, assign) BOOL isHidding ;

@property (nonatomic, strong) ConferenceHelper *confHelper ;
@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastView ;

@property (nonatomic, strong) VCWhiteBoardView *whiteBoardView;

/** 分享时的小视频 */
@property (nonatomic, strong) UIView *smallView;
/** 是否显示字幕 */
@property (nonatomic, assign,getter=isShowSubtitleLab) BOOL showSubtitleLab;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSArray *localShareArray;

@end

@implementation ConferenceViewController
#pragma mark - 界面和数据存储的加载
-(NSTimer *)recordTimer {
    if (!_recordTimer) {
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
        _recordTimer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
            if ([[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"stop"] ||
                [[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"appfinsh"]) {
                [userDefault setObject:@"applaunch" forKey:@"screen_record_open_state"];
                [self.vcrtc stopRecordScreen];
                if (!self.vcrtc.isShiTong) {
                    [self RTCHelper:self.rtcHelper didStopImage:@"stopex"];
                }
            }
        } repeats:YES];
    }
    return _recordTimer ;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initClass];
    }
    return self;
}


- (void)initClass {
    self.confHelper = [[ConferenceHelper alloc]init];
    self.confHelper.needCloseVideo = YES ;
    self.confHelper.delegate = self ;
    self.confHelper.preController = self ;
    self.rtcHelper = [[RTCHelper alloc]init ];
    self.rtcHelper.media_delegate = self ;
    self.confHelper.rtcHelper = self.rtcHelper ;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.confHelper conf_removeAllRegister];
    [self.hiddenTimer invalidate];
    [self.recordTimer invalidate];
    [self.timeLengthTimer invalidate];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSTimeInterval timeStr =  [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *settings = @{ @"go_settings" : @(NO) , @"time" : @(timeStr) };
    
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"go_settings_defaults"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( self.streamOnwers.count ) {
        [self changeLayoutStream];
    }
    
    if ([self.sharingStuts isEqualToString:@"remote"] && self.sharing){
        if (!self.vcrtc.isShiTong) {
            [self loadPresentationView];
        }
    }
    
    if (self.confHelper.changeIsBackground) {
        self.confHelper.changeIsBackground = NO ;
        [self.vcrtc reconstructionMediaCall];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始状态参数
    [self firstStatusData];
    [self setDefaultValue];
    [self.view insertSubview:self.manageView atIndex:0];
    //    [self addTimeLengthTimer];
    [[NSRunLoop currentRunLoop] addTimer:self.hiddenTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
    [self addNotificationCeter];
    [self.confHelper conf_registerApps];
    if (!self.viaCalling) {
        [self.vcrtc reloadLocalVideo];
    }
}


#pragma mark - 初始化
- (void)firstStatusData {
    timeCount = 0;
    imageLock = NO ;
    self.selectImages = [NSArray array];
    self.selectImageIndex = 0 ;
    self.sharing = NO ;
    self.isShowStickOpen = NO ;
    self.isShowStickClose = NO ;
    self.localSharing = NO ;
    self.remoteSharing = NO ;
    self.isStickOne = NO ;
    self.shareUuid = @"";
    self.stickUuid = @"";
    self.sharingStuts = @"none";
    self.frontCamera = YES ;
    self.loadSmallView = YES ;
    self.vcrtc = [VCRtcModule sharedInstance];
    self.isRecording = NO ;
    self.isLiving = NO ;
    self.isHidding = NO ;
    self.callName = self.vcrtc.callName ;
    
}

/** 默认数据 */
- (void)setDefaultValue {
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.muteBtn.selected = self.selectMute || self.audioMute;
    self.closeLocalVideoBtn.selected = self.videoMute;
    self.onlyAudioBtn.hidden = !self.vcrtc.isShiTong;
    self.meetingRoomNumLab.text =  self.channel;
    
    //静音开启
    if (self.selectMute) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"静音已开启"];
        });
    }
    
}

/** 添加通知 */
- (void)addNotificationCeter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endMeeting_host:)
                                                 name:@"endMeeting_host"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chang:)
                                                 name:@"changeToLayout"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startShareImage:)
                                                 name:@"didStartLocalWithScreenHelper"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopShareImage:)
                                                 name:@"didStopLocalWithScreenHelper"
                                               object:nil];
}

- (void)dismissController:(NSNotification *)sender {
    [self myDismissViewControllerAnimated:YES completion:nil] ;
}


/**
 专属云分享成流的形式
 */
- (void)startShareImage:(NSNotification *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadPresentationView];
        
        self.shareUuid = @"new";
        self.shareBtn.selected = YES ;
        self.localSharing = YES ;
        self.sharing = YES ;
        self.sharingStuts = [self.sharingStuts isEqualToString:@"none"] ? @"local" : @"local_remote" ;
    });
    
}


/** 分享成流的形式出错结束分享 */
- (void)stopShareImage:(NSNotification *)sender {
    [self.vcrtc shareToStreamImageData:[NSData data]
                                  open:NO
                                change:NO
                               success:^(id  _Nonnull response) {}
                               failure:^(NSError * _Nonnull error) {}];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectImages = [NSArray array];
        self.selectImageIndex = 0 ;
        self.localSharing = NO ;
        self.shareUuid = @"";
        //        [self animateShowUnlockView:sender.object[@"reason"]];
    });
}

- (NSString *)parseReason:(NSString *)reason {
    if ([reason isEqualToString:@"admin closed"]) return @"" ;
    return reason ;
}

- (void)networkStateChange:(NSNotification *)sender {
    
}

- (void)endMeeting_host:(NSNotification *)sender {
    if (self.preControl) {
        [self.preControl dismissViewControllerAnimated:YES completion:nil];
    }
    NSError *error = [NSError errorWithDomain:@"RequestErrorDomain"
                                         code:3
                                     userInfo:@{
                                         NSLocalizedDescriptionKey:sender.object[@"reason"]
                                     }];
    [self RTCHelper:self.rtcHelper didDisconnectedWithReason:error];
}

- (void)chang:(NSNotification *)sender {
    if (self.streamOnwers.count) {
        [self changeLayoutStream];
    }
}


- (void)conferenceHelper:(ConferenceHelper *)helper didRecordTitleView:(BOOL)isShow {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.broadcastView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                if (@available(iOS 13.0, *)) {
                    [(UIButton*)view sendActionsForControlEvents:UIControlEventAllEvents];
                } else {
                    [(UIButton*)view sendActionsForControlEvents:UIControlEventTouchDown];
                }
            }
        }
    });
}

#pragma mark - VCRtcModuleDelegate 接收、更新、删除视频流。

- (void) RTCHelper:(RTCHelper *)helper didAddLocalView:(VCVideoView *)view {
    Participant *localParticipant = [[Participant alloc] init];
    localParticipant.role = @"host";
    localParticipant.uuid = self.vcrtc.uuid ;
    localParticipant.overlayText = @"我";
    localParticipant.isMuted = self.vcrtc.rosterList[self.vcrtc.uuid].isMuted;
    self.localOnwers = [self addStreamView:view uuid:self.vcrtc.uuid owner:localParticipant] ;
    if(![self justContainsObject:self.streamOnwers withStr: self.vcrtc.uuid]){
        [self.streamOnwers addObject:self.localOnwers];
    }
    [self didLayoutParticipants:self.vcrtc.layoutParticipants];
}

- (void) RTCHelper:(RTCHelper *)helper didAddView:(VCVideoView *)view uuid:(NSString *)uuid {
    if (!uuid) return;
    if (!view.isPresentation) {
        [self.streamOnwers addObject:[self addStreamView:view uuid:uuid owner:self.vcrtc.rosterList[uuid]]];
        NSLog(@"[conference] streams add remote - %@",uuid);
    } else {
        [self.streamOnwers addObject:[self addStreamView:view uuid:[uuid stringByAppendingString:@"-presentation"] owner:self.vcrtc.rosterList[uuid]]];
        NSLog(@"[conference] streams add remote - %@",[uuid stringByAppendingString:@"-presentation"]);
    }
    [self didLayoutParticipants:self.vcrtc.layoutParticipants];
}

- (void) RTCHelper:(RTCHelper *)helper didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid {
    NSDictionary *selectOwnerInfo ;
    if (!view.isPresentation) {
        selectOwnerInfo = [self selectUuid:uuid] ;
        NSLog(@"[conference] streams add remove - %@",uuid);
    } else {
        selectOwnerInfo = [self selectUuid:[uuid stringByAppendingString:@"-presentation"]];
        NSLog(@"[conference] streams add remove - %@",[uuid stringByAppendingString:@"-presentation"]);
    }
    [self.streamOnwers removeObject:selectOwnerInfo];
    [self didLayoutParticipants:self.vcrtc.layoutParticipants];
}

- (void) RTCHelper:(RTCHelper *)helper didLayoutParticipants:(NSArray *)participants {
    [self didLayoutParticipants:participants];
}

- (void)didLayoutParticipants:(NSArray *)participants {
    NSMutableArray *mArr = [participants mutableCopy];
    if (self.vcrtc.isShiTong && self.vcrtc.uuid) {
        BOOL isPresentation = NO ;
        //自己是否被点击上主屏了
        BOOL stickLocal =  [self.vcrtc.uuid isEqualToString:self.stickUuid] ;
        //是否有发双流
        for (NSString *uuid in participants) {
            if ([uuid rangeOfString:@"-presentation"].length) {
                isPresentation = YES ;
            }
        }
        if (![mArr containsObject:self.vcrtc.uuid]) {
            if (!isPresentation) {
                if (stickLocal) {
                    if (mArr.count <= 0) {
                        [mArr addObject:self.vcrtc.uuid] ;
                    } else {
                        [mArr insertObject:self.vcrtc.uuid atIndex:0];
                    }
                } else {
                    if (mArr.count <= 1) {
                        [mArr addObject:self.vcrtc.uuid];
                    } else {
                        [mArr insertObject:self.vcrtc.uuid atIndex:1] ;
                    }
                }
            }
        }
    }
    
    self.layoutParticipants = [mArr copy] ;
    NSLog(@"[conference][controller] streams layout participants %@",participants);
    [self layoutOrderParticipants];
}


- (void)layoutOrderParticipants {
    if (self.vcrtc.isShiTong ) {
        if (!self.layoutParticipants.count) {
            return ;
        }
        
        NSMutableArray *mArr = [NSMutableArray array];
        BOOL isPresentation = NO ;
        BOOL hasStick = NO ;
        NSLog(@"self.vcrtc.uuid - %@",self.vcrtc.uuid);
        
        for (int i = 0 ; i < self.layoutParticipants.count ; i ++ ) {
            if ([self.layoutParticipants[i] isEqualToString:self.vcrtc.uuid]) {
                if (![self justContainsObject:mArr withStr:self.vcrtc.uuid]) {
                    [mArr addObject:self.localOnwers];
                }
                if ([self.stickUuid isEqualToString:self.vcrtc.uuid]) {
                    hasStick = YES ;
                    if (self.isShowStickOpen) {
                        self.isStickOne = YES ;
                        [self animateShowLockView];
                        self.isShowStickOpen = NO;
                    }
                }
            } else {
                for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
                    if  ([self.layoutParticipants[i] isEqualToString:subOwnerInfo[@"uuid"]]) {
                        if (![self justContainsObject:mArr withStr:subOwnerInfo[@"uuid"]]) {
                            [mArr addObject:subOwnerInfo];
                        }
                    }
                    
                    if ([self.stickUuid isEqualToString:subOwnerInfo[@"uuid"]]) {
                        hasStick = YES ;
                        if (self.isShowStickOpen) {
                            self.isStickOne = YES ;
                            [self animateShowLockView];
                            self.isShowStickOpen = NO;
                        }
                    }
                }
            }
            
            if([self.layoutParticipants[i] rangeOfString:@"-presentation"].length) {
                isPresentation = YES ;
            }
        }
        
        BOOL justStreamOnwers = NO ;
        for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
            if ([self.localOnwers[@"uuid"] isEqualToString:subOwnerInfo[@"uuid"]]) {
                justStreamOnwers = YES ;
            }
        }
        
        if (!hasStick || isPresentation ) {
            self.isStickOne = NO ;
            self.stickUuid = @"";
            if (self.isShowStickClose) {
                [self animateShowUnlockView:@"主屏已解锁"];
                self.isShowStickClose = NO ;
            }
        }
        
        if (isPresentation) {
            // 当前为分享中状态，看数据
            NSLog(@"[logs][layout] -- %@",self.layoutParticipants);
            if (self.streamOnwers.count ) {
                if (mArr.count == 2) {
                    self.streamShareVideos = [mArr mutableCopy];
                    self.streamOnwers = [mArr mutableCopy];
                }
            }
        } else {
            if (self.streamOnwers.count ) {
                if (self.streamOnwers.count == mArr.count) {
                    self.streamShareVideos = [mArr mutableCopy];
                    self.streamOnwers = [mArr mutableCopy];
                }
            }
        }
        
        [self changeLayoutStream];
        
    } else {
        //不是本地屏幕分享隐藏屏幕分享视图
        if(![self.sharingStuts isEqualToString:@"ex"]) {
            self.recordScreenView.hidden = YES ;
        }
        
        NSLog(@"[conference][controller] layout count is  , reload view return %@.", self.streamOnwers);
        
        // 当出现layout 中的参会者个数 为 0 时, 直接加载本地视图。
        // 一则避免layout 延迟到来造成的 清除 streams 的个数。
        // 二则此时说明仅显示本地视图，减少计算量。
        if (self.layoutParticipants.count == 0) {
            [self changeLayoutStream];
            NSLog(@"[conference][controller] layout count is 0 , reload view return %@.", self.streamOnwers);
            return ;
        }
        
        //  判断 本地 stream view 是否为 stick 的 stream view .
        BOOL stickLocal =  [self.vcrtc.uuid isEqualToString:self.stickUuid];
        BOOL hasStick = NO ;
        BOOL isPresentation = NO ;
        
        // 当 stick 的是本地 stream view,把本地stream view 放到第一个。
        NSMutableArray *mArr = [NSMutableArray array];
        if (stickLocal) {
            for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
                if ([self.vcrtc.uuid isEqualToString:subOwnerInfo[@"uuid"]]) {
                    [mArr addObject:subOwnerInfo] ;
                    NSLog(@"[conference][controller] stick local stream view.");
                }
            }
        }
        
        // 把其余的 stream view 根据 layout 提供的顺序 排序
        for (int i = 0 ; i < self.layoutParticipants.count ; i ++ ) {
            for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
                if  ([self.layoutParticipants[i] isEqualToString:subOwnerInfo[@"uuid"]] && ![self justContainsObject:mArr withStr:subOwnerInfo[@"uuid"]]) {
                    [mArr addObject:subOwnerInfo];
                }
                
                if ([self.layoutParticipants[i] rangeOfString:@"-presentation"].length) {
                    isPresentation = YES ;
                }
                
                if ([self.stickUuid isEqualToString:subOwnerInfo[@"uuid"]]) {
                    hasStick = YES;
                    if (self.isShowStickOpen) {
                        self.isStickOne = YES ;
                        [self animateShowLockView];
                        self.isShowStickOpen = NO;
                    }
                }
            }
        }
        
        
        if (!stickLocal) {
            for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
                if ([self.vcrtc.uuid isEqualToString:subOwnerInfo[@"uuid"]] && ![self justContainsObject:mArr withStr:subOwnerInfo[@"uuid"]]) {
                    if (mArr.count >= 2) {
                        [mArr insertObject:subOwnerInfo atIndex:1] ;
                    } else {
                        [mArr addObject:subOwnerInfo] ;
                    }
                }
            }
        }
        
        if (!hasStick || ([self.sharingStuts isEqualToString:@"remote"] &&  self.layoutParticipants.count == 2)) {
            self.isStickOne = NO ;
            self.stickUuid = @"";
            if (self.isShowStickClose) {
                [self animateShowUnlockView:@"主屏已解锁"];
                self.isShowStickClose = NO ;
            }
        }
        
        NSLog(@"[conference][controller] streams - %@",mArr);
        
        if (self.streamOnwers.count) {
            if ([self.sharingStuts isEqualToString:@"remote"] && self.layoutParticipants.count == 2) {
                self.streamShareVideos = [mArr mutableCopy];
                self.streamOnwers = [mArr mutableCopy];
            } else {
                self.streamOnwers = [mArr mutableCopy];
            }
            
            if (self.sharing) {
                if (imageLock) {
                    imageLock = NO ;
                    [self updatePresentSmallView];
                }
            } else {
                [self changeLayoutStream];
            }
        }
    }
    [self showSubTitle];
}

- (BOOL )justContainsObject:(NSArray *)object withStr:(NSString *)uuid {
    for (NSDictionary *dic in object) {
        if( [dic[@"uuid"] isEqualToString:uuid]) {
            return YES ;
        }
    }
    return NO;
}

#pragma mark - VCRtcModuleDelegate 分享。

- (void) RTCHelper:(RTCHelper *)helper didStartImage:(NSString *)shareUuid {
    NSLog(@"myuuid -- %@ shareuuid -- %@",self.vcrtc.uuid, shareUuid);
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
    }
    // 三种状态
    
    // 远端 、 本端发送图片 、 本端录制屏幕
    
    if ( self.whiteBoardView.hidden == NO ) {
        [self.whiteBoardView removeFromSuperview];
        self.whiteBoardView = nil ;
    }
    
    if (self.vcrtc.isShiTong) {
        self.shareUuid = shareUuid ;
        // 本端 用 shareuuid 相匹配
        if ( [shareUuid isEqualToString:self.vcrtc.uuid] ) {
            if ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]) {
                // 查看当前会议中处于什么状态中。
                if (self.sharing) {
                    // 当前为异常情况
                    if (self.shareBtn.selected) {
                        // 异常情况为本地正在开启分享，没有被关闭。
                        if ([self.sharingStuts isEqualToString:@"ex"]) {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find ex is open!");
                        } else if([self.sharingStuts isEqualToString:@"remote"]) {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find remote is open! && status is chaos!");
                        } else if([self.sharingStuts isEqualToString:@"local"]) {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find local is open!");
                        } else if([self.sharingStuts isEqualToString:@"local_remote"]) {
                            // 需要特殊处理一下
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find local remote is open!");
                        } else {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find share status is error!");
                        }
                    } else {
                        // 异常情况为本地正在开启分享，没有被关闭。
                        if ([self.sharingStuts isEqualToString:@"ex"]) {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find ex is open! && status is chaos!");
                        } else if([self.sharingStuts isEqualToString:@"remote"]){
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find remote is open!");
                        } else if([self.sharingStuts isEqualToString:@"local"]){
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find local is open! && status is chaos!");
                        } else {
                            NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find share status is error!");
                        }
                    }
                } else {
                    // 判断当前的分享状态是否已经清除
                    if ([self.sharingStuts isEqualToString:@"none"]) {
                        self.sharing = YES ;
                        self.shareBtn.selected = YES ;
                        self.recordScreenView.hidden = NO ;
                        self.sharingStuts = @"ex";
                    } else {
                        NSLog(@"[error][start][ex] warning !!!!!!!!!! \n Find share status is not none !");
                    }
                }
            } else {
                // 正在分享本地图片。(因为本地展示的时候有个要求，要立即看到展示的图片。所以在提交的时候就已经告知全局状态)
                if (!self.sharing) {
                    self.sharing = YES ;
                }
                
                if ([self.sharingStuts isEqualToString:@"local_remote"]) {
                    self.sharingStuts = @"local" ;
                } else if ([self.sharingStuts isEqualToString:@"local_ex"]){
                    self.sharingStuts = @"local";
                } else  if ([self.sharingStuts isEqualToString:@"local"]) {
                    
                } else {
                    NSLog(@"[error][start][local] warning !!!!!!!!!! \n Find share status is error!");
                }
            }
        } else {
            if (self.sharing) {
                // 当前为异常情况
                if (self.shareBtn.selected) {
                    // 异常情况为本地正在开启分享，没有被关闭。
                    if ([self.sharingStuts isEqualToString:@"ex"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find ex is open!");
                    } else if([self.sharingStuts isEqualToString:@"remote"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find remote is open! && status is chaos!");
                    } else if([self.sharingStuts isEqualToString:@"local"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find local is open!");
                    } else if([self.sharingStuts isEqualToString:@"local_remote"]) {
                        // 需要特殊处理一下
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find local remote is open!");
                    } else {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error!");
                    }
                } else {
                    // 异常情况为本地正在开启分享，没有被关闭。
                    if ([self.sharingStuts isEqualToString:@"ex"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find ex is open! && status is chaos!");
                    } else if([self.sharingStuts isEqualToString:@"remote"]){
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find remote is open!");
                    } else if([self.sharingStuts isEqualToString:@"local"]){
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find local is open! && status is chaos!");
                    } else {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error!");
                    }
                }
                self.sharingStuts = @"remote";
            } else {
                // 判断当前的分享状态是否已经清除
                if ([self.sharingStuts isEqualToString:@"none"]) {
                    self.sharing = YES ;
                    self.shareBtn.selected = NO ;
                    self.sharingStuts = @"remote";
                } else {
                    self.sharingStuts = @"remote";
                    
                    NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is not none !");
                }
            }
        }
        [self didLayoutParticipants:self.vcrtc.layoutParticipants] ;
    } else {
        
        NSLog(@"[vcrtc] share start - %@,%d,%@",self.sharingStuts,self.exSharing,[userDefaults objectForKey:@"screen_record_open_state"]);
        // 正在录制屏幕的分享,出现其他端打断当前会议。
        if (self.exSharing && [self.sharingStuts isEqualToString:@"ex"] && ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] ||[[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] )) {
            [userDefaults setObject:@"stop" forKey:@"screen_record_open_state"];
            self.sharing = YES ;
            self.remoteSharing = YES ;
            self.sharingStuts = @"remote";
            self.shareBtn.selected = NO;
            // 出现录制屏幕,并只有屏幕录制作为分享时。
        } else if( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]){
            self.sharing = YES ;
            self.shareBtn.selected = YES ;
            self.recordScreenView.hidden = NO ;
            self.sharingStuts = @"ex";
            self.exSharing = YES ;
            NSLog(@"share image -- ssddd ");
            // 出现其他端,并只有其他端作为分享时。
        } else {
            self.sharing = YES ;
            self.remoteSharing = YES ;
            self.sharingStuts = @"remote";
            self.shareBtn.selected = NO ;
        }
        
        SharingStauts stauts = [self justSharingStopStauts];
        
        NSLog(@"--- 当前分享状态 %ld", (long)stauts);
        switch (stauts) {
            case SharingStautsRemoteToLocal :
            case SharingStautsExToLocal :
                self.selectImages = [NSArray array];
                self.selectImageIndex = 0 ;
                self.localSharing = NO ;
                self.shareUuid = @"" ;
                [self showAlert] ;
                break;
                
            case SharingStautsRemoteToEx :
            case SharingStautsLocalToEx :
                self.exSharing = NO ;
                self.recordScreenView.hidden = YES;
                break;
                
            default:
                break;
        }
    }
}

- (void)showAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"其他参会人正在分享，您的分享已被暂停。" preferredStyle:UIAlertControllerStyleAlert] ;
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) RTCHelper:(RTCHelper *)helper didUpdateVideo:(NSString *)imageStr uuid:(NSString *)uuid {
}


-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

- (void) RTCHelper:(RTCHelper *)helper didUpdateImage:(NSString *)imageStr uuid:(nonnull NSString *)uuid {
    
    if (self.sharing && (self.localSharing && [self.sharingStuts isEqualToString:@"local"] ) ) {
        UIImage *image = [self getImageFromURL:imageStr] ;
        if (image) {
            if (self.timeoutTimer) {
                [self.timeoutTimer invalidate];
            }
        }
    }
    
    NSLog(@"didUpdateImage -- %@",imageStr);
    
    if (self.isStickOne) [self cancelStick:nil];
    if (!imageStr.length) return ;
    if (self.sharing && (self.localSharing && [self.sharingStuts isEqualToString:@"local"])) return;
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
    
    NSLog(@"[vcrtc] share update - %@,%d,%@",imageStr,self.exSharing,[userDefaults objectForKey:@"screen_record_open_state"] );
    //本地屏幕共享
    if ([[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] ||
        [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]) {
        [userDefaults setObject:@"opening" forKey:@"screen_record_open_state"];
        NSLog(@"[conference]update image ex");
        
        self.shareBtn.selected = YES ;
        self.recordScreenView.hidden = NO ;
        self.sharingStuts = @"ex";
        self.exSharing = YES ;
        
        SharingStauts stauts = [self justSharingStopStauts];
        switch (stauts) {
            case SharingStautsRemoteToLocal :
            case SharingStautsExToLocal:
                self.selectImages = [NSArray array];
                self.selectImageIndex = 0 ;
                self.localSharing = NO ;
                self.shareUuid = @"";
                break;
            default:
                break;
        }
        
    } else {
        NSLog(@"[conference]update image remote");
        
        if (self.localSharing && [self.sharingStuts isEqualToString:@"local"]) return;
        if (!self.sharing) return ;
        NSURL *url= [NSURL URLWithString:imageStr];
        NSLog(@"[conference]update image remote 1");
        
        imageLock = NO ;
        
        self.photoType = YCPhotoSourceType_URL ;
        
        self.selectImages = @[url];
        [self loadPresentationView];
    }
}

- (void) RTCHelper:(RTCHelper *)helper didStopImage:(NSString *)imageStr {
    if(self.vcrtc.isShiTong) {
        NSLog(@"%@----%@",imageStr, self.vcrtc.uuid);
        if ([imageStr isEqualToString:self.vcrtc.uuid]) {
            
            [self.vcrtc shareToStreamImageData:[NSData data]
                                          open:NO
                                        change:NO
                                       success:^(id  _Nonnull response) {}
                                       failure:^(NSError * _Nonnull error) {}];
            self.selectImages = [NSArray array];
            self.selectImageIndex = 0 ;
            self.localSharing = NO ;
            self.shareUuid = @"";
            
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
            if ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] ) {
                self.sharing = NO ;
                self.sharingStuts = @"none" ;
                self.recordScreenView.hidden = YES;
                self.shareBtn.selected = NO ;
                [userDefaults setObject:@"platformstop" forKey:@"screen_record_open_state"];
            } else {
                self.sharing = NO ;
                self.sharingStuts = @"none";
                self.recordScreenView.hidden = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.vcrtc shareToRemoteDisconnect];
                    [self clearPresentationView];
                    [self.presentationView removeFromSuperview];
                    self.presentationView = nil;
                    self.shareBtn.selected = NO;
                    [self didLayoutParticipants:self.layoutParticipants];
                });
            }
            return ;
        }
        
        if (self.sharing || (!self.sharing && [self.sharingStuts isEqualToString:@"local"]) ) {
            if ([self.sharingStuts isEqualToString:@"ex"]) {
                self.sharing = NO ;
                self.sharingStuts = @"none" ;
                self.recordScreenView.hidden = YES;
                self.shareBtn.selected = NO ;
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
                if ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] ) {
                    [userDefaults setObject:@"stop" forKey:@"screen_record_open_state"];
                    [self.vcrtc stopRecordScreen];
                }
            } else if ([self.sharingStuts isEqualToString:@"local"]) {
                self.sharing = NO ;
                self.sharingStuts = @"none" ;
                [self.vcrtc shareToRemoteDisconnect];
                [self clearPresentationView];
                [self.presentationView removeFromSuperview];
                self.presentationView = nil ;
                
            } else if ([self.sharingStuts isEqualToString:@"local_remote"]) {
                // 此时为本地正在抢其他的分享者的分享。输出日志，证明一下。
                NSLog(@"[logs][stop][remote] log .......\n local with remote, to none");
            } else if ([self.sharingStuts isEqualToString:@"local_ex"]) {
                // 此时为本地正在抢 ex 的分享。输出日志，证明一下。 (不会出现)
                NSLog(@"[logs][stop][remote] log .......\n local with ex. error");
            } else if ([self.sharingStuts isEqualToString:@"remote"]) {
                self.sharing = NO ;
                self.sharingStuts = @"none" ;
            }
        } else {
            NSLog(@"[error][stop][remote] warning !!!!!!!!!! \n Find share status is close ! repeat");
        }
        [self didLayoutParticipants:self.layoutParticipants];
    } else {
#pragma mark - 公有云结束分享
        if ([imageStr isEqualToString:@"stopex"] && [self.sharingStuts isEqualToString:@"remote"]) {
            return ;
        }
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
        //屏幕共享
        if([self.sharingStuts isEqualToString:@"ex"] && self.exSharing && self.shareBtn.selected) {
            if (([[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"stop"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"applaunch"])) {
                
            } else {
                return ;
            }
        }
        SharingStauts stauts = [self justSharingStopStauts];
        switch (stauts) {
            case SharingStautsNone :
                NSLog(@"-----------------无");
                return;
                break;
                
            case SharingStautsRemote :
                //解决本地抢双流的时候,该视图被移除
                //                if ([[self.selectImages firstObject] isKindOfClass:[UIImage class]]) {
                //                    NSLog(@"=====================================================class");
                //                    return;
                //                }
                self.sharing = NO ;
                [self clearPresentationView];
                [self.presentationView removeFromSuperview];
                self.presentationView = nil;
                NSLog(@"-----------------远端在分享");
                break;
            case SharingStautsExToRemote :
                [self.presentationView removeFromSuperview];
                self.presentationView = nil;
                self.remoteSharing = NO;
                NSLog(@"-----------------远端在分享,被本地屏幕抢断");
                break;
            case SharingStautsLocalToRemote:
                //                [self.presentationView removeFromSuperview];
                //                self.presentationView = nil;
                NSLog(@"-----------------远端在分享,被本地抢断");
                self.remoteSharing = NO;
                break;
                
            case SharingStautsEx :
                NSLog(@"-----------------本地屏幕在分享");
                self.sharing = NO;
                [self clearPresentationView];
                [self.presentationView removeFromSuperview];
                self.shareBtn.selected = NO ;
                self.presentationView = nil ;
            case SharingStautsRemoteToEx :
                NSLog(@"-----------------本地屏幕在分享,被远端抢断");
            case SharingStautsLocalToEx :
                self.exSharing = NO ;
                self.recordScreenView.hidden = YES;
                NSLog(@"-----------------本地屏幕在分享,被本地抢断");
                break;
            case SharingStautsExToLocal:
                NSLog(@"-----------------本地在分享,被本地屏幕抢断");
                break;
            case SharingStautsLocal: {
                NSString *screenRecordState = [userDefaults objectForKey:@"screen_record_open_state"];
                if ([screenRecordState isEqualToString:@"start"] ||
                    [screenRecordState isEqualToString:@"opening"]) {
                    self.sharing = NO;
                    [self clearPresentationView];
                    [self.presentationView removeFromSuperview];
                    self.shareBtn.selected = NO ;
                    self.presentationView = nil ;
                }
            }
            default:
                NSLog(@"-----------------");
                break;
        }
        [self changeLayoutStream];
    }
    [self didLayoutParticipants:self.layoutParticipants];
}

- (SharingStauts )justSharingStopStauts{
    int trueCount = 0 ;
    for (NSNumber *number in @[[NSNumber numberWithBool:self.remoteSharing],
                               [NSNumber numberWithBool:self.localSharing],
                               [NSNumber numberWithBool:self.exSharing]]) {
        if ([number boolValue]) {
            trueCount ++ ;
        }
    }
    
    if ([self.sharingStuts isEqualToString:@"video"]) {
        return SharingStautsVideo ;
    }
    
    if (trueCount == 1) {
        if (self.remoteSharing) {
            return SharingStautsRemote;
        } else if (self.localSharing) {
            return SharingStautsLocal ;
        } else if (self.exSharing) {
            return SharingStautsEx;
        }
    } else if (trueCount == 2) {
        if (self.remoteSharing && self.localSharing) {
            if ([self.sharingStuts isEqualToString:@"remote"]) {
                return SharingStautsRemoteToLocal;
            } else if([self.sharingStuts isEqualToString:@"local"]){
                return SharingStautsLocalToRemote ;
            }
        } else if (self.remoteSharing && self.exSharing) {
            if ([self.sharingStuts isEqualToString:@"remote"]) {
                return SharingStautsRemoteToEx ;
            } else if([self.sharingStuts isEqualToString:@"ex"]){
                return SharingStautsExToRemote ;
            }
        } else if (self.localSharing && self.exSharing) {
            if ([self.sharingStuts isEqualToString:@"local"]) {
                return SharingStautsLocalToEx ;
            } else if([self.sharingStuts isEqualToString:@"ex"]){
                return SharingStautsExToLocal ;
            }
        }
    }
    return SharingStautsNone;
}

#pragma mark - VCRtcModuleDelegate 状态。
- (void)RTCHelper:(RTCHelper *)helper didUpdateParticipant:(Participant *)participant {
    if ([participant.uuid isEqualToString:self.vcrtc.uuid] && ([participant.role isEqualToString:@"guest"])) {
        if (participant.isMuted && !self.isMute) {
            [SVProgressHUD showInfoWithStatus:@"您已被主持人静音，如需发言请举手申请"];
            self.isMute = YES;
            [self.muteBtn setImage:[UIImage imageNamed:@"icon_handsup_inmeeting"] forState:UIControlStateNormal];
            self.muteBtn.selected = NO;
        } else if (participant.isMuted && self.isMute && participant.hand_time == 0  && self.muteBtn.selected) {
            [SVProgressHUD showInfoWithStatus:@"主持人拒绝您的发言"];
            [self.muteBtn setImage:[UIImage imageNamed:@"icon_handsup_inmeeting"] forState:UIControlStateNormal];
            self.muteBtn.selected = NO;
        } else {
            if (self.isMute && !participant.isMuted) {
                [SVProgressHUD showInfoWithStatus:@"主持人已允许您发言"];
                self.isMute = NO;
                [self.muteBtn setImage:[UIImage imageNamed:@"hz_tabbar_btn01_n"] forState:UIControlStateNormal];
                [self.muteBtn setImage:[UIImage imageNamed:@"tabbar_btn01_s"] forState:UIControlStateSelected];
                
                if (self.isLocalMute == true) {
                    self.muteBtn.selected = NO ;
                    [self.vcrtc micEnable: YES ];
                }
                
            }
        }
    } else if ([participant.uuid isEqualToString:self.vcrtc.uuid] && participant.isChair) {
        //被主持人从访客设为主持人
        [self.muteBtn setImage:[UIImage imageNamed:@"hz_tabbar_btn01_n"] forState:UIControlStateNormal];
        [self.muteBtn setImage:[UIImage imageNamed:@"tabbar_btn01_s"] forState:UIControlStateSelected];
        self.muteBtn.selected = self.isLocalMute;
        [self.vcrtc micEnable:!self.isLocalMute];
        self.isMute = NO;
        if (participant.hand_time > 0) {
            [self.vcrtc raiseHand:self.vcrtc.uuid isRaiseHand:NO success:^(id  _Nonnull response) {
            } failure:^(NSError * _Nonnull error) {
                
            }];
        }
    }
}
- (void) RTCHelper:(RTCHelper *)helper didUpdateRecordAndlive:(nonnull NSDictionary *)data{
    if (!self.vcrtc.isShiTong) {
        BOOL isRecord = [data[@"isrecord"] boolValue];
        BOOL isLiving = [data[@"isliving"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isRecording = isRecord ;
            self.isLiving = isLiving ;
        });
    }
     [self changeLayoutStream];
}

- (void) RTCHelper:(RTCHelper *)helper didUpdateConferenceStatus:(NSDictionary *)data {
    if (self.vcrtc.isShiTong) {
        if (!data) data = @{} ;
        if ([data.allKeys containsObject:@"record_status"]) {
            self.isRecording = [data[@"record_status"] boolValue];
        }
        if ([data.allKeys containsObject:@"live_status"]) {
            self.isLiving = [data[@"live_status"] boolValue];
        }
        [self changeLayoutStream];
    }
}

- (void)RTCHelper:(RTCHelper *)helper didUpdateParticipants:(NSArray *)participants {
    self.participantCountLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)participants.count];
    Participant *localSelfPant;
    //被静音了本地更新静音按钮状态
    NSMutableArray *handArray = [NSMutableArray array];
    for (Participant *parti in participants) {
        if (parti.hand_time != 0) {
            [handArray addObject:parti];
        }
        if ([parti.uuid isEqualToString:self.vcrtc.uuid]) {
            localSelfPant = parti;
        }
        
        //自己是否被静音
        for ( NSDictionary *dic in self.streamOnwers) {
            if ([parti.uuid isEqualToString:self.vcrtc.uuid] && [dic[@"uuid"] isEqualToString:self.vcrtc.uuid]) {
                Participant *partiOwner = dic[@"owner"];
                partiOwner.isMuted = parti.isMuted;
                break;
            }
        }
    }
    //举手个数显示
    if(localSelfPant.isChair) {
        if (handArray.count == 1) {
            self.handCountBtn.hidden = NO;
            Participant *participant = [handArray firstObject];
            [self.handCountBtn setTitle:participant.overlayText forState:UIControlStateNormal];
        } else if (handArray.count > 0) {
            self.handCountBtn.hidden = NO;
            [self.handCountBtn setTitle:[NSString stringWithFormat:@"（%ld）", handArray.count] forState:UIControlStateNormal];
        } else {
            self.handCountBtn.hidden = YES;
        }
    } else {
        self.handCountBtn.hidden = YES;
    }
    [self.confHelper updateInConferenceParticipantMuteState:participants marrShows:[self.sharingStuts isEqualToString:@"video"] ? self.streamShareVideos : self.streamOnwers manageView:self.manageView];
    
}

/** 计算文本 */
- (void) RTCHelper:(RTCHelper *)helper didDisconnectedWithReason:(NSError *)reason {
    NSString *patchStr = [[NSBundle mainBundle]pathForResource:@"ErrorReason" ofType:@"plist"];
    NSDictionary *reasonDic = [NSDictionary dictionaryWithContentsOfFile:patchStr];
    NSString *reasonChair = reasonDic[reason.userInfo[NSLocalizedDescriptionKey]];
    [self errorInforDismissControl:reasonChair.length ? reasonChair : reason.userInfo[NSLocalizedDescriptionKey]];
    
}

- (void)RTCHelper:(RTCHelper *)helper didReceivedSubtitlesMessage:(NSDictionary *)subtitlesmessage {
    
    NSString *messageText = subtitlesmessage[@"payload"];
    self.showSubtitleLab = messageText.length ? YES : NO;;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (messageText.length) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowBlurRadius = 1.5;
            shadow.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
            shadow.shadowOffset =CGSizeMake(0,1);
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:messageText];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] range:NSMakeRange(0, string.length)];
            [string addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, string.length)];
            [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, string.length)];
            [string addAttribute:NSKernAttributeName value:@(2) range:NSMakeRange(0, string.length)];
            self.subtitleLab.attributedText = string;
            self.subtitleLab.textAlignment = NSTextAlignmentCenter;
            [self showSubTitle];
        } else {
            self.subtitleLab.hidden = YES;
        }
    });
}

// 提示错误的方式为 退出会中界面。 提示用户信息
- (void) errorInforDismissControl:(NSString *)errorStr {
    [self.confHelper conf_errorExitChannel:errorStr];
}

- (void) RTCHelper:(RTCHelper *)helper didChangeRole:(NSString *)role {
    if ([role.lowercaseString isEqualToString:@"host"]) {
        NSLog(@"[conference] rtc delegate didChangeRole is host");
    } else if ([role.lowercaseString isEqualToString:@"guest"]) {
        NSLog(@"[conference] rtc delegate didChangeRole is guest");
        
    } else {
        NSLog(@"[conference] rtc delegate didChangeRole is notfine");
    }
    
}

- (void) RTCHelper:(RTCHelper *)helper didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats {
    [self reloadStats:mediaStats rosterList:self.vcrtc.rosterList userSelfUUID:self.vcrtc.uuid userChannel:1];
}

- (void)RTCHelper:(RTCHelper *)helper didStartWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid {
    if([uuid isEqualToString:self.vcrtc.uuid]) {
        self.shareBtn.selected = YES ;
    } else {
        if (self.shareBtn.selected == YES) {
            self.shareBtn.selected = NO ;
        }
    }
    self.whiteBoardView.hidden = NO ;
    [self.whiteBoardView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shareUrl]]];
    
}

- (void)RTCHelper:(RTCHelper *)helper didStopWhiteBoard:(nonnull NSString *)shareUrl withUuid:(nonnull NSString *)uuid{
    [self.whiteBoardView removeFromSuperview];
    self.whiteBoardView = nil ;
}

- (NSMutableDictionary *)addStreamView:(VCVideoView *)view uuid:(NSString *)uuid owner:(Participant *)owner {
    NSMutableDictionary *ownerInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uuid":uuid,
        @"view":view,
        @"role":owner.role.length ? owner.role : @"guest",
        @"overlayText":owner.overlayText.length ? owner.overlayText : @"远端",
    }];
    if (owner) {
        [ownerInfo setValue:owner forKey:@"owner"];
    }
    return ownerInfo ;
}

- (NSMutableDictionary *)selectUuid:(NSString *)uuid {
    NSMutableDictionary *selectOwnerInfo = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
        if([subOwnerInfo[@"uuid"] isEqualToString:uuid]) {
            selectOwnerInfo = subOwnerInfo ;
        }
    }
    return selectOwnerInfo;
}

- (void)changeLayoutStream {
    [self clearSubView];
    self.confHelper.livingEnable = self.isLiving && [[self.vcrtc.role lowercaseString] isEqualToString:@"host"] ;
    self.confHelper.recordEnable = self.isRecording && [[self.vcrtc.role lowercaseString] isEqualToString:@"host"] ;
    self.confHelper.sticking = self.isStickOne ;
    if (!self.sharing || self.vcrtc.isShiTong) {
        [self createBigStreamView];
        if (self.loadSmallView) {
            [self createSmallStreamView];
        }
    }
    if (self.sharing && ([self.sharingStuts isEqualToString:@"local_remote"] || [self.sharingStuts isEqualToString:@"local"] || [self.sharingStuts isEqualToString:@"local_ex"]) ) {
        [self updatePresentSmallView];
    }
}

- (void)clearSubView {
    for (UIView *view in self.manageView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)createBigStreamView {
    NSMutableArray *marrShows = [self.sharingStuts isEqualToString:@"video"] ? self.streamShareVideos : self.streamOnwers;
    if (marrShows.count == 0) return;
    NSMutableDictionary *owner = marrShows[0];
    NSString *uuid = owner[@"uuid"];
    BOOL isClose = [self.vcrtc.uuid isEqualToString:uuid] && self.closeLocalVideoBtn.selected ;
    if (!marrShows.count) return;
    if(self.manageView.subviews.count == 0) {
        [self.manageView addSubview:[self.confHelper conf_reloadView:YES localCutClose:isClose  withOwner:owner withIndex:0 withSize:CGSizeMake(self.manageView.ott_width, self.manageView.ott_height) streamCount:marrShows.count]];
        [self updatePresenterFrame];
    }
}

- (void)createSmallStreamView {
    NSMutableArray *arr = [self.sharingStuts isEqualToString:@"video"] ? self.streamShareVideos : self.streamOnwers;
    if (!arr.count) return ;
    if(self.manageView.subviews.count < arr.count){
        [self addNewVideoView];
    } else if (self.manageView.subviews.count > arr.count) {
        [self removeIndexVideoView];
    }
}

- (void)animateShowLockView {
    if (self.titleView) [self.titleView removeFromSuperview];
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 146, 50)];
    [alertView.layer setCornerRadius:3];
    [alertView.layer setMasksToBounds:YES];
    alertView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    alertView.center = CGPointMake(self.view.frame.size.width/ 2.0, self.view.frame.size.height/ 2.0);
    UILabel *labelTop = [[UILabel alloc]initWithFrame:CGRectMake(0, 9, 70, 12)];
    labelTop.text = @"主屏已锁定" ;
    labelTop.textAlignment = NSTextAlignmentCenter;
    labelTop.textColor = [UIColor whiteColor];
    labelTop.center = CGPointMake(alertView.frame.size.width/2.0,labelTop.center.y );
    labelTop.font = [UIFont systemFontOfSize:12];
    [alertView addSubview:labelTop];
    UILabel *labelBottom = [[UILabel alloc]initWithFrame:CGRectMake(0, alertView.frame.size.height - 21, 70, 12)];
    labelBottom.text = @"双击取消" ;
    labelBottom.textAlignment = NSTextAlignmentCenter;
    labelBottom.textColor = [UIColor whiteColor];
    labelBottom.center = CGPointMake(alertView.frame.size.width/2.0,labelBottom.center.y );
    labelBottom.font = [UIFont systemFontOfSize:12];
    [alertView addSubview:labelBottom];
    [self.view addSubview:alertView];
    [UIView animateWithDuration:3 animations:^{
        alertView.alpha = 0 ;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        self.titleView = nil ;
    }];
    self.titleView = alertView ;
}

- (void)animateShowUnlockView:(NSString *)errorStr {
    if (self.titleView) [self.titleView removeFromSuperview];
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 146, 50)];
    [alertView.layer setCornerRadius:3];
    [alertView.layer setMasksToBounds:YES];
    alertView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    alertView.center = CGPointMake(self.view.frame.size.width/ 2.0, self.view.frame.size.height/ 2.0);
    UILabel *labelTop = [[UILabel alloc]initWithFrame:CGRectMake(0, 9, 70, 12)];
    labelTop.text = errorStr ;
    labelTop.textAlignment = NSTextAlignmentCenter;
    labelTop.textColor = [UIColor whiteColor];
    labelTop.center = CGPointMake(alertView.frame.size.width/2.0,alertView.frame.size.height/2.0);
    labelTop.font = [UIFont systemFontOfSize:12];
    [alertView addSubview:labelTop];
    [self.view addSubview:alertView];
    [UIView animateWithDuration:3 animations:^{
        alertView.alpha = 0 ;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        self.titleView = nil ;
    }];
    self.titleView = alertView ;
}

- (void)setStick:(UIButton *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView:) object:sender];
    
    if (self.sharing) return;
    //分享视频
    if ([self.sharingStuts isEqualToString:@"video"] &&  self.layoutParticipants.count == 2) return;
    NSMutableDictionary *owner = self.streamOnwers[sender.tag] ;
    self.stickUuid = owner[@"uuid"];
    if (![owner[@"uuid"] isEqualToString:self.vcrtc.uuid]) {
        [self.vcrtc stickParticipant:owner[@"uuid"] onStick:YES success:^(id  _Nonnull response) {
            self.isShowStickOpen = YES ;
            NSLog(@"stick -- 成功");
        } failure:^(NSError * _Nonnull er) {
            NSLog(@"stick -- 失败");
        }];
    } else {
        NSMutableDictionary *owner1 = self.streamOnwers[0] ;
        self.stickUuid = owner1[@"uuid"];
        if (self.isStickOne) [self cancelStick:nil];
        self.stickUuid = owner[@"uuid"];
        self.isStickOne = YES ;
        self.isShowStickOpen = YES ;
        [self didLayoutParticipants:self.vcrtc.layoutParticipants];
    }
}

- (IBAction)clickCancelStick:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView:) object:sender];
    [self cancelStick:sender];
}


/**
 取消锁屏
 */
- (void)cancelStick:(UIButton *)sender {
    
    if (!self.sharing && self.isStickOne) {
        self.isShowStickClose = YES;
    }
    if (![self.stickUuid isEqualToString:self.vcrtc.uuid]) {
        [self.vcrtc stickParticipant:self.stickUuid onStick:NO success:^(id  _Nonnull response) {
        } failure:^(NSError * _Nonnull er) {}];
        self.stickUuid = @"";
    } else {
        self.isStickOne = NO ;
        self.stickUuid = @"";
        [self didLayoutParticipants:self.vcrtc.layoutParticipants];
    }
}

- (void)addNewVideoView {
    NSMutableArray *marrShows = [self.sharingStuts isEqualToString:@"video"] ? self.streamShareVideos : self.streamOnwers;
    if (!marrShows.count) return ;
    for (int i = 1; i < marrShows.count; i++) {
        if (!(i < self.manageView.subviews.count)) {
            NSMutableDictionary *owner = marrShows[i];
            NSString *uuid = owner[@"uuid"];
            BOOL isClose = [self.vcrtc.uuid isEqualToString:uuid] && self.closeLocalVideoBtn.selected ;
            [self.manageView addSubview:[self.confHelper conf_reloadView:NO localCutClose:isClose withOwner:owner withIndex:i withSize:CGSizeMake(self.manageView.ott_width, self.manageView.ott_height) streamCount:marrShows.count] ];
        }
    }
}
- (void)showSubTitle {
    //    CGSize size = [(NSMutableAttributedString *)self.subtitleLab.attributedText cuculateAttributedStringHeightWithFontSize:20 withWidth:self.view.frame.size.width -  89 * 2];
    CGRect frame = CGRectMake(89, 10, self.view.frame.size.width - 89 * 2, 50);
    if (self.manageView.subviews.count <= 1) {
        self.subtitleLab.frame = CGRectMake(frame.origin.x, self.view.frame.size.height - frame.size.height - 80, frame.size.width, frame.size.height);
    } else if (self.manageView.subviews.count > 1) {
        UIView *secondeView = self.manageView.subviews[1];
        self.subtitleLab.frame = CGRectMake(frame.origin.x, self.view.frame.size.height - secondeView.frame.size.height - frame.size.height - 15, frame.size.width, frame.size.height);
    }
    self.subtitleLab.hidden = !self.isShowSubtitleLab;
    [self.subtitleLab layoutIfNeeded];
}

- (void)removeIndexVideoView  {
    UIView *samllView = self.manageView.subviews[self.manageView.subviews.count - 1];
    [samllView removeFromSuperview];
}

#pragma mark -  click item
- (void)hiddenView:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = self.topView.alpha == 0 ? 0.9 : 0 ;
        self.bottomView.alpha = self.bottomView.alpha == 0 ? 0.9 : 0;
        self.handCountToBtm.priority = self.topView.alpha == 0 ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow;
        [self setNeedsStatusBarAppearanceUpdate];
        [self updatePresenterFrame];
    }];
    
    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil ;
    [[NSRunLoop currentRunLoop] addTimer:self.hiddenTimer forMode:NSRunLoopCommonModes];
}
- (void)updatePresenterFrame {
    [super updatePresenterFrame];
    NSMutableArray *marrShows = [self.sharingStuts isEqualToString:@"video"] ? self.streamShareVideos : self.streamOnwers;
    if (marrShows.count == 0) return;
    NSMutableDictionary *owner = marrShows[0];
    [self.confHelper updatePresenterLabFrameWithOwner:owner manageView:self.manageView isDownMigration:self.topView.alpha == 0 ? NO : YES];
}

- (IBAction)mute:(UIButton *)sender {
    if (self.isMute) {
        [sender setImage:[UIImage imageNamed:@"icon_handsup_inmeeting"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"icon_nohandsup"] forState:UIControlStateSelected];
        [self.vcrtc raiseHand:self.vcrtc.uuid isRaiseHand:!sender.selected success:^(id  _Nonnull response) {
            sender.selected = !sender.selected;
            if (sender.selected) {
                [SVProgressHUD showInfoWithStatus:@"发言请求已发送"];
            }
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (granted) {
                [sender setImage:[UIImage imageNamed:@"hz_tabbar_btn01_n"] forState:UIControlStateNormal];
                [sender setImage:[UIImage imageNamed:@"tabbar_btn01_s"] forState:UIControlStateSelected];
                [self.vcrtc micEnable:sender.selected];
                sender.selected = !sender.selected;
                self.isLocalMute = sender.selected;
            } else {
                [self goSettingPermissions:@"" andMessage:@"麦克风被禁用，请在本机的“设置”—“隐私”—“麦克风”中允许紫荆云访问您的麦克风" success:^(bool go) {
                    
                }];
            }
        }];
    }
    
}




- (IBAction)vmute:(id)sender {
    UIButton *btn = sender ;
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return ;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.confHelper.needCloseVideo = btn.selected ;
                [self.vcrtc videoEnable: btn.selected];
                btn.selected = !btn.selected ;
                
                if (btn.selected) {
                    [self didLayoutParticipants:self.vcrtc.layoutParticipants];
                } else {
                    [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        [self didLayoutParticipants:self.vcrtc.layoutParticipants];
                    }];
                }
            });
        } else {
            [self goSettingPermissions:@"" andMessage:@"相机被禁用，请在本机的“设置”—“隐私”—“相机”中允许紫荆云访问您的相机" success:^(bool go) {
                
            }];
        }
    }];
    
    
}

- (IBAction)toggle:(id)sender {
    if (self.closeLocalVideoBtn.selected) {
        return;
    }
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return;
    }
    [self.vcrtc switchCamera ];
    self.frontCamera = !self.frontCamera ;
}

- (IBAction)onlyAudio:(id)sender {
    UIButton *btn = sender ;
    if (!self.closeLocalVideoBtn.selected) {
        [self.vcrtc onlyAudioEnable: btn.selected];
    }
    self.confHelper.needCloseVideo = btn.selected ;
    if (!btn.selected) {
        self.onlyAudioView.hidden = NO ;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             self.onlyAudioView.hidden = YES ;
        });
    }
    [self.vcrtc resetClayout: btn.selected ? @"1:4" : @"0:0"];
    btn.selected = !btn.selected;
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
}

- (IBAction)share:(id)sender {
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return ;
    }
    if (self.shareBtn.selected) {
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
        if ([[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] ||  [[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"start"]) {
            [self RTCHelper:self.rtcHelper didStopImage:@""];
            [userDefault setObject:@"appstop" forKey:@"screen_record_open_state"];
        } else if(self.whiteBoardView.hidden == NO){
            [self.vcrtc shareToWhiteOpen:NO
                                 success:^(id  _Nonnull response) {}
                                 failure:^(NSError * _Nonnull error) {}];
        } else{
            [self endShare];
        }
        self.sharing = NO;
        self.shareBtn.selected = NO;
        return ;
    }
    
    [self.confHelper conf_alertGetResources];
}

- (IBAction)handDetailAction:(UIButton *)sender {
    /*
    VCManageViewController *rootVc =  [[VCManageViewController alloc]init] ;
    rootVc.rtcHelper = self.rtcHelper;
    rootVc.channel = self.channel;
    rootVc.meetingInfo = self.shareUrl;
    int selectIndex = 0;
    if(([[VCRtcModule sharedInstance].role isEqualToString:@"host"] || [[VCRtcModule sharedInstance].role.lowercaseString isEqualToString:@"host"])) {
        selectIndex = 2;
    }
    rootVc.selectIndex = selectIndex;
    ManageNavigationController *vc = [[ManageNavigationController alloc]initWithRootViewController:rootVc];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
     */
    
}



- (void)endShare {
    if (self.vcrtc.isShiTong) {
        [self.vcrtc shareToStreamImageData:[NSData data]
                                      open:NO
                                    change:NO
                                   success:^(id  _Nonnull response) {}
                                   failure:^(NSError * _Nonnull error) {}];
        [self.vcrtc shareToRemoteDisconnect];
    } else {
        [self.vcrtc shareImageData:[NSData data]
                              open:NO
                            change:NO
                           success:^(id  _Nonnull response) {
            
        }
                           failure:^(NSError * _Nonnull error) {
            
        }];
    }
    
    self.sharing = NO ;
    [self clearPresentationView];
    [self.presentationView removeFromSuperview];
    self.presentationView = nil ;
    self.selectImages = [NSArray array];
    self.selectImageIndex = 0;
    self.localSharing = NO ;
    self.shareUuid = @"";
    self.sharing = NO;
    self.shareBtn.selected = NO;
}
- (void)VCRtc:(VCRtcModule *)module didStartLocal:(NSString *)shareUrl withUuid:(NSString *)uuid {
    
}

- (void)VCRtc:(VCRtcModule *)module didStopLocal:(nonnull NSString *)shareUrl withUuid:(nonnull NSString *)uuid {
    [self animateShowUnlockView:shareUrl];
}


- (void)submitSharingImage:(UIImage *)image change:(BOOL )myChange{
    
    NSLog(@"********************************************************************************////////");
    
    NSData* data = UIImageJPEGRepresentation(image, 1);
    if (self.vcrtc.isShiTong) {
        [self.vcrtc shareToStreamImageData:data open:YES change:self.shareUuid.length ? YES : NO success:^(id  _Nonnull response) {
            NSLog(@"分享成功：%@ -- ",self.shareUuid);
            self.shareUuid = @"new";
            self.shareBtn.selected = YES ;
            self.localSharing = YES ;
            self.sharing = YES ;
            self.sharingStuts = [self.sharingStuts isEqualToString:@"video"] ? @"local_remote" : @"local";
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"分享失败：%@ -- ",error);
            if(self.shareBtn.selected == NO) return ;
            self.shareBtn.selected = NO ;
            self.sharing = NO ;
            self.localSharing = NO ;
        }];
        
        //        if (myChange != YES) {
        //            self.shareUuid = @"new";
        //            self.shareBbtn.selected = YES ;
        //            self.localSharing = YES ;
        //            self.sharing = YES ;
        //            self.sharingStuts = [self.sharingStuts isEqualToString:@"none"] ? @"local" : @"local_remote" ;
        //        }
        //
        
    } else {
        __block NSString *shareState = @"none";
        __block NSInteger i = 0;
        if (self.timeoutTimer) {
            [self.timeoutTimer invalidate];
        }
        self.timeoutTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            i++;
            if (i == 5 && [shareState isEqualToString:@"none"]) {
                [SVProgressHUD showInfoWithStatus:@"内容发送缓慢，请耐心等待"];
            }
            if (i == 10 && [shareState isEqualToString:@"none"]) {
                [self uploadImageFailed];
                [timer invalidate];
            }
        }];
        [[NSRunLoop currentRunLoop]addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
        self.sharingStuts = @"local";
        self.sharing = YES;
        self.localSharing = YES;
        self.shareBtn.selected = YES;
        [self updatePresentSmallView];
        BOOL isChange = self.shareUuid.length ? YES : NO;
        [self.vcrtc shareImageData:data open:YES change:isChange success:^(id  _Nonnull response) {
            //图片上传成功
            self.shareUuid = @"new";
            NSLog(@"分享成功：%@ -- ",self.shareUuid);
            if ([response[@"result"] isKindOfClass:[NSString class]] && [response[@"result"] isEqualToString:@"OK"]) {
                shareState = @"success";
                [self.timeoutTimer invalidate];
            }
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"分享失败：%@ -- ",error);
            [self uploadImageFailed];
            [self.timeoutTimer invalidate];
            if(self.shareBtn.selected == NO) return;
            self.shareBtn.selected = NO ;
            self.sharing = NO ;
            self.localSharing = NO;
            self.shareUuid = @"";
            shareState = @"failed";
        }];
        self.shareUuid = @"new";
    }
    
    
    
}

- (void)uploadImageFailed {
    if (self.shareBtn.selected == YES) {
        [SVProgressHUD showInfoWithStatus:@"内容共享失败，请稍后重试"];
        [self endShare];
        [self didLayoutParticipants:self.layoutParticipants];
    }
}

#pragma mark - 辅助视图更换的方法

- (void)conferenceHelper:(ConferenceHelper *)helper didPhotoResource:(NSArray *)selectImages{
    self.selectImages = selectImages;
    self.localShareArray = selectImages;
    self.photoType = YCPhotoSourceType_Image ;
    if (!self.vcrtc.isShiTong) {
        [self loadPresentationView] ;
    }
    NSLog(@"********************************************************************************didPhotoResource");
    [self submitSharingImage:self.selectImages[0] change:NO];
}


/**
 锁屏
 */
- (void)conferenceHelper:(ConferenceHelper *)helper didClickStick:(BOOL)stick forButton:(UIButton *)button{
    if (stick) {
        [self setStick:button];
    } else {
        [self cancelStick:button];
    }
}

- (void)conferenceHelper:(ConferenceHelper *)helper didHiddenView:(BOOL)hidden {
    [self hiddenView:[UITapGestureRecognizer new]];
}

- (void)conferenceHelper:(ConferenceHelper *)helper changePage:(NSInteger)page {
    self.photoType = YCPhotoSourceType_Image ;
    if (page < self.selectImages.count) {
        NSLog(@"********************************************************************************changePage");
        [self submitSharingImage:self.selectImages[page] change:YES];
    }
}

- (void)conferenceHelper:(ConferenceHelper *)helper zoomEndImage:(UIImage *)image {
    NSLog(@"********************************************************************************zoomEndImage");
    [self submitSharingImage:image change:YES];
}

- (void)loadPresentationView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UITapGestureRecognizer *tagSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView:)];
        tagSingle.numberOfTapsRequired = 1 ;
        tagSingle.numberOfTouchesRequired = 1;
        [self.presentationView addGestureRecognizer:tagSingle];
        self.presentationView.userInteractionEnabled = YES ;
        [self.view insertSubview:self.presentationView atIndex:1] ;
        [self.confHelper conf_reloadPresentionView:self.selectImages PhotoSourceType:self.photoType reloadView:self.presentationView];
        
        [self updatePresentSmallView];
    });
}

- (void)updatePresentSmallView {
    if (!self.streamOnwers.count) {
        return ;
    }
    if (self.sharing) {
        if (!self.smallView) {
            self.smallView = [[UIView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height - self.view.frame.size.width/5.0 * 9/16, self.view.frame.size.width/5.0-1 , self.view.frame.size.width/5.0 * 9/16)];
            
            // 背景图片
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.smallView.frame.size.width, self.smallView.frame.size.height) ];
            imageView.image = [UIImage imageNamed:@"background-close-video"];
            [self.smallView addSubview:imageView];
            self.smallView.layer.zPosition = 1;
        }
        [self.presentationView addSubview:self.smallView];
        VCVideoView *view ;
        NSDictionary *viewOwner ;
        if (self.streamOnwers.count == 0) {
            return;
        } else if (self.streamOnwers.count == 1) {
            viewOwner = self.streamOnwers[0] ;
            view = self.streamOnwers[0][@"view"] ;
        } else if (self.streamOnwers.count > 1) {
            viewOwner = self.streamOnwers[0] ;
            view = self.streamOnwers[0][@"view"] ;
        }
        
        NameView *overlayTextLabel = [self.confHelper manage_loadTitleLabel:[viewOwner[@"owner"] overlayText] hidden:view.isPresentation isShowMuteImage:[viewOwner[@"owner"] isMuted] isSpeaking: ([viewOwner[@"owner"] vad] == 200 || [viewOwner[@"owner"] isSpeaking]) rect: CGRectMake(5, self.smallView.ott_height - 18, self.smallView.ott_width, 16) isPresentation:NO];
        view.objectFit = VCVideoViewObjectFitCover ;
        view.frame = CGRectMake(0, 0, self.smallView.frame.size.width, self.smallView.frame.size.height);
        [self.smallView addSubview:view];
        [self.smallView addSubview:(UIView *)overlayTextLabel] ;
        
    }
}

- (void)clearPresentationView{
    for (UIView *view in self.presentationView.subviews) {
        [view removeFromSuperview];
    }
}


#pragma mark - 点击触发时间

- (IBAction)more:(id)sender {
    NSArray<ActionModel *> *otherButtonTitles = nil;
    NSMutableArray *muteOtherButtonTitles = [NSMutableArray array] ;
    
    if ([self.vcrtc.role isEqualToString:@"host"] || [self.vcrtc.role.lowercaseString isEqualToString:@"host"]) {
        if (self.isSupportRecord) {
            ActionModel *wxModel = [[ActionModel alloc] initWithName:self.isRecording ? @"关闭录制" : @"开启录制" withUserTag:@"record"];
            [muteOtherButtonTitles addObject:wxModel];
        }
        if (self.isSupportLive) {
            ActionModel *linkModel = [[ActionModel alloc] initWithName:self.isLiving ? @"关闭直播" : @"开启直播" withUserTag:@"living"];
            [muteOtherButtonTitles addObject:linkModel];
        }
    }
    
    ActionModel *booksModel = [[ActionModel alloc] initWithName:self.loadSmallView ? @"关闭画中画" : @"开启画中画" withUserTag:@"hide"];
    [muteOtherButtonTitles addObject:booksModel];
    
    otherButtonTitles = [muteOtherButtonTitles copy];
    
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles selectedBlock:^(NSInteger index, NSString *userTag) {
        if ([userTag isEqualToString:@"record"]) {
            [self recordClick];
        } else if ([userTag isEqualToString:@"living"]) {
            [self livingClick];
        } else if ([userTag isEqualToString:@"hide"]) {
            self.loadSmallView = !self.loadSmallView ;
            [self changeLayoutStream];
            
            if (self.sharing) {
                //                [self updatePresentSmallView];
            }
        }
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = self.topView.alpha == 0 ? 0.9 : 0 ;
        self.bottomView.alpha = self.bottomView.alpha == 0 ? 0.9 : 0 ;
        self.handCountToBtm.priority = self.topView.alpha == 0 ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow;
        [self setNeedsStatusBarAppearanceUpdate];
        [self updatePresenterFrame];
    }];
}

- (IBAction)manageConference:(id)sender {
    /*
    VCManageViewController *rootVc =  [[VCManageViewController alloc]init] ;
    rootVc.rtcHelper = self.rtcHelper ;
    rootVc.channel = self.channel ;
    rootVc.meetingInfo = self.shareUrl;
    ManageNavigationController *vc = [[ManageNavigationController alloc]initWithRootViewController:rootVc];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
     */
}


- (IBAction)down:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定离开会议室吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.vcrtc exitChannelSuccess:^(id  _Nonnull response) {
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"请检查网络状况，没能正常退出会议室。");
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ConferenceEnd" object:nil];
            [self myDismissViewControllerAnimated:YES completion:nil];
        });
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) recordClick {
    [self.confHelper conf_toggleRecordEnable:!self.isRecording];
}

- (void) livingClick {
    [self.confHelper conf_toggleLivingEnable:!self.isLiving];
}

- (IBAction)showNetQuelity:(id)sender {
    self.netQuaityView.hidden = NO ;
    self.topView.alpha = 0;
    self.bottomView.alpha = 0;
    self.handCountToBtm.priority = self.topView.alpha == 0 ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow;
    [self updatePresenterFrame];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)myDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.confHelper conf_removeAllRegister];
    [self.hiddenTimer invalidate];
    [self.recordTimer invalidate];
    [self.timeLengthTimer invalidate];
    self.hiddenTimer = nil;
    self.recordTimer = nil;
    self.timeLengthTimer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self dismissViewControllerAnimated:flag completion:nil];
    
}

-(void)conferenceHelper:(ConferenceHelper *)helper dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self myDismissViewControllerAnimated:flag completion:completion];
}


/** 时间计时器 */
- (void)addTimeLengthTimer {
    self.timeLengthTimer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSString *stringDate = @"00:00:00";
        NSDate *date = [dateFormatter dateFromString:stringDate];
        NSDate *dateTime = [[NSDate alloc]initWithTimeInterval:timeCount sinceDate:date];
        NSString *stringTime = [dateFormatter stringFromDate:dateTime];
        timeCount ++ ;
        self.timeLengthLab.text = stringTime;
    } repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timeLengthTimer forMode:NSRunLoopCommonModes];
}

- (UIView *)recordScreenView {
    if (!_recordScreenView) {
        _recordScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT , SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_HEIGHT : SCREEN_WIDTH)];
        CGFloat superViewWidth = self.view.frame.size.width ;
        CGFloat superViewHeight = self.view.frame.size.height ;
        BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
        CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
        CGFloat viewHeight = viewWidth * 9 / 16.0 ;
        UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        backgroundImage.image = [UIImage imageNamed:@"record_screen_heng"];
        backgroundImage.userInteractionEnabled = YES ;
        backgroundImage.center = CGPointMake( _recordScreenView.width/2.0, _recordScreenView.height/2.0) ;
        
        UITapGestureRecognizer *tagSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView:)];
        tagSingle.numberOfTapsRequired = 1 ;
        tagSingle.numberOfTouchesRequired = 1;
        [backgroundImage addGestureRecognizer:tagSingle];
        [_recordScreenView addSubview:backgroundImage];
        _recordScreenView.backgroundColor = [UIColor blackColor];
        
        _recordScreenView.hidden = YES ;
        
        [self.view insertSubview:_recordScreenView atIndex:1] ;
    }
    return _recordScreenView ;
}

- (UIView *)onlyAudioView {
    if (!_onlyAudioView) {
        _onlyAudioView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,  SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT , SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_HEIGHT : SCREEN_WIDTH)];
        CGFloat superViewWidth = self.view.frame.size.width ;
        CGFloat superViewHeight = self.view.frame.size.height ;
        BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
        CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
        CGFloat viewHeight = viewWidth * 9 / 16.0 ;
        UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        backgroundImage.image = [UIImage imageNamed:@"background-audio"];
        backgroundImage.userInteractionEnabled = YES ;
        backgroundImage.center = CGPointMake( _onlyAudioView.width/2.0, _onlyAudioView.height/2.0) ;
        UITapGestureRecognizer *tagSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView:)];
        tagSingle.numberOfTapsRequired = 1 ;
        tagSingle.numberOfTouchesRequired = 1;
        [backgroundImage addGestureRecognizer:tagSingle];
        [_onlyAudioView addSubview:backgroundImage];
        _onlyAudioView.hidden = YES ;
        [self.view insertSubview:_onlyAudioView atIndex:1] ;
    }
    return _onlyAudioView ;
}

//- (NSMutableArray *)streamOnwers {
//    if (!_streamOnwers) {
//        _streamOnwers = [NSMutableArray array] ;
//    }
//    return _streamOnwers ;
//}


- (NSMutableArray *)streamShareVideos {
    if (!_streamShareVideos) {
        _streamShareVideos = [NSMutableArray array] ;
    }
    return _streamShareVideos;
}

- (UIView *)manageView {
    if (!_manageView) {
        
        CGFloat superViewWidth = [UIScreen mainScreen].bounds.size.height ;
        CGFloat superViewHeight = [UIScreen mainScreen].bounds.size.width ;
        BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
        CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
        CGFloat viewHeight = viewWidth * 9 / 16.0 ;
        _manageView = [[UIView alloc]initWithFrame:CGRectMake( (superViewWidth - viewWidth) / 2.0, (superViewHeight - viewHeight) / 2.0, viewWidth, viewHeight)];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView:)];
        tapG.numberOfTouchesRequired = 1 ;
        _manageView.userInteractionEnabled = YES ;
        //        _manageView.backgroundColor = [UIColor redColor];
        [_manageView addGestureRecognizer:tapG];
        
        
    }
    return _manageView ;
}

- (VCWhiteBoardView *)whiteBoardView {
    if (!_whiteBoardView) {
        _whiteBoardView = [[VCWhiteBoardView alloc] initWithFrame:CGRectMake(0, 0,  SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_WIDTH : SCREEN_HEIGHT , SCREEN_WIDTH > SCREEN_HEIGHT ? SCREEN_HEIGHT : SCREEN_WIDTH)];
        _whiteBoardView.hidden = YES ;
        [_whiteBoardView.showSuperView addTarget:self action:@selector(hiddenView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_whiteBoardView atIndex:1];
    }
    return _whiteBoardView ;
}

- (UIView *)presentationView {
    if (!_presentationView) {
        _presentationView = [self.confHelper conf_loadPresentionView:self.selectImages PhotoSourceType:self.photoType];
        _presentationView.backgroundColor = [UIColor redColor];
    }
    return _presentationView ;
}

- (RPSystemBroadcastPickerView *)broadcastView  API_AVAILABLE(ios(12.0)){
    if (!_broadcastView) {
        _broadcastView = [[RPSystemBroadcastPickerView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        _broadcastView.preferredExtension = @"com.vcsdk-demo.phone.record";
        _broadcastView.hidden = YES ;
        [self.view addSubview:_broadcastView];
    }
    return _broadcastView ;
}

//#pragma mark - Controller 的屏幕和状态栏
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscapeRight ;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationLandscapeRight ;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent ;
//}
//
//- (BOOL )prefersStatusBarHidden {
//    return self.topView.alpha == 0 ;
//}
//
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
//    return UIStatusBarAnimationNone;
//}


@end
