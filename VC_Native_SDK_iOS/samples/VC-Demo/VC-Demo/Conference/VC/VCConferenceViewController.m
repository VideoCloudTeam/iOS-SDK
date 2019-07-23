//
//  VCConferenceViewController.m
//  VCRTC
//
//  Created by 李志朋 on 2018/12/3.
//  Copyright © 2018年 zijingcloud. All rights reserved.
//

#import "VCConferenceViewController.h"
#import "VCRtcModule.h"
#import "Participant.h"
#import "VCVideoView.h"
#import "VCMediaStat.h"
#import "UIView+Frame.h"
#import "ConferenceHelper.h"
#import "RTCHelper.h"

#import <sys/sysctl.h>
#import <mach/mach.h>

#import <ReplayKit/ReplayKit.h>

#import "MXActionSheet.h"
#import "ActionModel.h"

static BOOL privateCloud = YES;

typedef void(^compate)(UIImage *image);

typedef NS_ENUM(NSInteger, VCSharingStauts){
    VCSharingStautsNone ,
    VCSharingStautsRemote ,
    VCSharingStautsLocal ,
    VCSharingStautsEx ,
    VCSharingStautsRemoteToLocal ,
    VCSharingStautsRemoteToEx ,
    VCSharingStautsLocalToRemote ,
    VCSharingStautsLocalToEx ,
    VCSharingStautsExToRemote ,
    VCSharingStautsExToLocal,
    VCSharingStautsVideo
};

API_AVAILABLE(ios(12.0))
@interface VCConferenceViewController ()
                                        <VCRtcModuleDelegate,
                                         UITableViewDelegate,
                                         UITableViewDataSource,
                                         ConferenceHelperDelegate,
                                         RTCHelperMediaDelegate> {
    int timeCount ;
    BOOL imageLock ;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;
@property (weak, nonatomic) IBOutlet UIButton *shareBbtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *netBtn;
@property (weak, nonatomic) IBOutlet UITableView *netQuailtyTable;
@property (weak, nonatomic) IBOutlet UILabel *numBer;
@property (weak, nonatomic) IBOutlet UIButton *hiddenView;
@property (weak, nonatomic) IBOutlet UIButton *onlyAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *vMute;
@property (weak, nonatomic) IBOutlet UILabel *participantCount;
@property (weak, nonatomic) IBOutlet UIButton *manageBtn;

@property (nonatomic, strong) NSString *callName ;

@property (nonatomic, strong) VCRtcModule *vcrtc ;
@property (nonatomic, strong) RTCHelper *rtcHelper ;

@property (nonatomic, strong) NSMutableArray *streamOnwers ;
@property (nonatomic, strong) NSMutableArray *streamShareVideos ;
@property (nonatomic, strong) NSMutableArray *streamFrames ;
@property (nonatomic, strong) NSMutableArray *networkArr ;
@property (   atomic, strong) NSArray *layoutParticipants ;
@property (nonatomic, strong) NSMutableDictionary *localOnwers ;

@property (nonatomic, strong) UIView *manageView ;     // 会中 全编全解/多流 展示
@property (nonatomic, strong) UIView *presentationView ; // 分享展示
@property (nonatomic, strong) UIView *recordScreenView;
@property (nonatomic, strong) UIView *onlyAudioView;
@property (nonatomic, strong) UIView *titleView ;

@property (nonatomic, strong) NSTimer *timeLengthTimer ;
@property (nonatomic, strong) NSTimer *hiddenTimer ;
@property (nonatomic, strong) NSTimer *recordTimer ;
@property (nonatomic, strong) NSArray *selectImages;
@property (nonatomic, assign) YCPhotoSourceType photoType ;
@property (nonatomic, assign) int selectImageIndex ;

@property (nonatomic, strong) NSString *shareUuid ;
@property (nonatomic, strong) NSString *stickUuid ;
@property (nonatomic, strong) NSString *sharingStuts ;
@property (nonatomic, assign) BOOL frontCamera;
@property (nonatomic, assign) BOOL loadSmallView ;
@property (nonatomic, assign) BOOL sharing ;
@property (nonatomic, assign) BOOL localSharing ;
@property (nonatomic, assign) BOOL remoteSharing ;
@property (nonatomic, assign) BOOL exSharing ;
@property (nonatomic, assign) BOOL isShowStickOpen ;
@property (nonatomic, assign) BOOL isShowStickClose ;
@property (nonatomic, assign) BOOL isStickOne ;
@property (nonatomic, assign) BOOL isRecording ;
@property (nonatomic, assign) BOOL isLiving ;
@property (nonatomic, assign) BOOL isHidding ;

@property (nonatomic, strong) ConferenceHelper *confHelper ;
@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastView ;

@end

@implementation VCConferenceViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"VCConferenceViewController" bundle:nil]) {
        [self initClass];
    }
    return self ;
}

- (void)initClass {
    self.confHelper = [[ConferenceHelper alloc]init];
    self.confHelper.needCloseVideo = YES ;
    self.confHelper.delegate = self ;
    self.rtcHelper = [[RTCHelper alloc]init ];
    self.rtcHelper.media_delegate = self ;
    self.confHelper.rtcHelper = self.rtcHelper ;
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始状态参数
    [self firstStatusData];
    
    [self.view insertSubview:self.manageView atIndex:0];
    self.view.backgroundColor = [UIColor blackColor];
    [self loadTimer];
    self.netQuailtyTable.delegate = self;
    self.netQuailtyTable.dataSource = self ;
    self.muteBtn.selected = self.selectMute ;
    self.onlyAudioBtn.hidden = self.incomming ;
    self.shareBbtn.hidden = self.incomming ;
    self.moreBtn.hidden = self.incomming ;
    self.numBer.text = self.callName.length ? self.callName : self.channel ;
    self.manageBtn.hidden = self.incomming ;
    [self.confHelper conf_setShareInfo:self.shareUrl];
    
    // ios 10 之后的方法需要手动启动。
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
        [[NSRunLoop currentRunLoop] addTimer:self.hiddenTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endMeeting_host:)
                                                 name:@"endMeeting_host"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chang:)
                                                 name:@"changeToLayout"
                                               object:nil];
    
    [self.confHelper conf_registerApps];
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    self.automaticallyAdjustsScrollViewInsets = NO ;
    
    [self.vcrtc reloadLocalVideo];
}

- (void)networkStateChange:(NSNotification *)sender {
    
}

- (void)endMeeting_host:(NSNotification *)sender {
    NSError *error = [NSError errorWithDomain:@"VCRequestErrorDomain"
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
    if ( self.streamOnwers.count ) {
        [self changeLayoutStream];
    }
    
    if ([self.sharingStuts isEqualToString:@"remote"] && self.sharing){
        [self loadPresentationView];
    }
    
    if (self.confHelper.changeIsBackground) {
        self.confHelper.changeIsBackground = NO ;
        [self.vcrtc reconstructionMediaCall];
    }
    
    __block int ss = 0 ;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"view width %@ view height.",self.recordScreenView.frame.origin.y  ? @">" : @"<");
        ss ++ ;
        if ( self.sharing && ss <= 5) {
            [self.recordScreenView removeFromSuperview];
            self.recordScreenView = nil ;
            self.recordScreenView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            if([self.sharingStuts isEqualToString:@"ex"]) {
                self.recordScreenView.hidden = NO ;
            }
        } else {
            [timer invalidate];
        }
    }];
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)conferenceHelper:(ConferenceHelper *)helper didRecordTitleView:(BOOL)isShow {
    for (UIView *view in self.broadcastView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            [(UIButton*)view sendActionsForControlEvents:UIControlEventTouchDown];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.confHelper conf_removeAllRegister];
    [self.hiddenTimer invalidate];
    [self.recordTimer invalidate];
    [self.timeLengthTimer invalidate];
}

#pragma mark - VCRtcModuleDelegate 接收、更新、删除视频流。

- (void) RTCHelper:(RTCHelper *)helper didAddLocalView:(VCVideoView *)view {
    Participant *localParticipant = [[Participant alloc] init];
    localParticipant.role = @"host";
    localParticipant.uuid = self.vcrtc.uuid ;
    localParticipant.overlayText = @"我";
    self.localOnwers = [self addStreamView:view uuid:self.vcrtc.uuid owner:localParticipant] ;
    [self.streamOnwers addObject:self.localOnwers];
    [self didLayoutParticipants:self.vcrtc.layoutParticipants];
}

- (void) RTCHelper:(RTCHelper *)helper didAddView:(VCVideoView *)view uuid:(NSString *)uuid {
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
    if (!participants) {
        [mArr addObject:self.vcrtc.uuid];
        return ;
    }
    if (privateCloud && self.vcrtc.uuid) {
        BOOL isPresentation = NO ;
        BOOL stickLocal =  [self.vcrtc.uuid isEqualToString:self.stickUuid] ;
        
        for (NSString *uuid in participants) {
            if ([uuid rangeOfString:@"-presentation"].length) {
                isPresentation = YES ;
            }
        }
        
        if (!isPresentation) {
            if (stickLocal) {
                if (mArr.count < 0) {
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
    
    self.layoutParticipants = [mArr copy] ;
    NSLog(@"[conference][controller] streams layout participants %@",participants);
    [self layoutOrderParticipants];
}


- (void)layoutOrderParticipants {
    if ( privateCloud ) {
        if (!self.layoutParticipants.count) {
            return ;
        }
       
        
        NSMutableArray *mArr = [NSMutableArray array];
        BOOL isPresentation = NO ;
        BOOL hasStick = NO ;


        for (int i = 0 ; i < self.layoutParticipants.count ; i ++ ) {
            if ([self.layoutParticipants[i] isEqualToString:self.vcrtc.uuid]) {
                [mArr addObject:self.localOnwers];
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
                        [mArr addObject:subOwnerInfo];
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
        BOOL stickLocal =  [self.vcrtc.uuid isEqualToString:self.stickUuid] ;
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
                if  ([self.layoutParticipants[i] isEqualToString:subOwnerInfo[@"uuid"]]) {
                    [mArr addObject:subOwnerInfo];
                }
    
                if ([self.layoutParticipants[i] rangeOfString:@"-presentation"].length) {
                    isPresentation = YES ;
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
    
    
        if (!stickLocal) {
            for (NSMutableDictionary *subOwnerInfo in self.streamOnwers) {
                if ([self.vcrtc.uuid isEqualToString:subOwnerInfo[@"uuid"]] && subOwnerInfo[@"uuid"]) {
                    if (mArr.count >= 2) {
                        [mArr insertObject:subOwnerInfo atIndex:1] ;
                    } else {
                        [mArr addObject:subOwnerInfo] ;
                    }
                }
            }
        }
    
        if (!hasStick || ([self.sharingStuts isEqualToString:@"remote"] &&  self.layoutParticipants.count == 2) ) {
            self.isStickOne = NO ;
            self.stickUuid = @"";
            if (self.isShowStickClose) {
                [self animateShowUnlockView:@"主屏已解锁"];
                self.isShowStickClose = NO ;
            }
        }
    
        if (self.streamOnwers.count ) {
            if ([self.sharingStuts isEqualToString:@"remote"] && self.layoutParticipants.count == 2) {
                self.streamShareVideos = [mArr mutableCopy];
                self.streamOnwers = [mArr mutableCopy];
                [self.streamOnwers addObject:self.localOnwers];
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
    
//
//

}

#pragma mark - VCRtcModuleDelegate 分享。

- (void) RTCHelper:(RTCHelper *)helper didStartImage:(NSString *)shareUuid {
    NSLog(@"myuuid -- %@ shareuuid -- %@",self.vcrtc.uuid, shareUuid);
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];

    // 三种状态
    
    // 远端 、 本端发送图片 、 本端录制屏幕
    
    
     if (privateCloud) {
        self.shareUuid = shareUuid ;
        // 本端 用 shareuuid 相匹配
        if ( [shareUuid isEqualToString:self.vcrtc.uuid] ) {
            if ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]) {
                // 查看当前会诊中处于什么状态中。
                if (self.sharing) {
                    // 当前为异常情况
                    if (self.shareBbtn.selected) {
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
                        self.shareBbtn.selected = YES ;
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
                if (self.shareBbtn.selected) {
                    // 异常情况为本地正在开启分享，没有被关闭。
                    if ([self.sharingStuts isEqualToString:@"ex"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find ex is open!");
                    } else if([self.sharingStuts isEqualToString:@"remote"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find remote is open! && status is chaos!");
                    } else if([self.sharingStuts isEqualToString:@"local"]) {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find local is open!");
                    }  else if([self.sharingStuts isEqualToString:@"local_remote"]){
                        self.sharingStuts = @"remote";
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error! local_remote change to local");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self clearPresentationView];
                            [self.vcrtc shareToRemoteDisconnect];
                            [self.presentationView removeFromSuperview];
                            self.presentationView = nil ;
                            self.shareBbtn.selected = NO ;
                        });
                    } else if([self.sharingStuts isEqualToString:@"local_ex"]){
                        self.sharingStuts = @"local";
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error! local_ex change to local");
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
                    } else if([self.sharingStuts isEqualToString:@"local_remote"]){
                        self.sharingStuts = @"remote";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self clearPresentationView];
                            [self.vcrtc shareToRemoteDisconnect];
                            [self.presentationView removeFromSuperview];
                            self.presentationView = nil ;
                            self.shareBbtn.selected = NO ;
                        });
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error! local_remote change to local");
                    } else if([self.sharingStuts isEqualToString:@"local_ex"]){
                        self.sharingStuts = @"local";
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error! local_ex change to local");
                    } else {
                        NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is error!");
                    }
                }
            } else {
                // 判断当前的分享状态是否已经清除
                if ([self.sharingStuts isEqualToString:@"none"]) {
                    self.sharing = YES ;
                    self.shareBbtn.selected = NO ;
                    self.sharingStuts = @"remote";
                } else {
                    NSLog(@"[error][start][remote] warning !!!!!!!!!! \n Find share status is not none !");
                }
            }
        }
         if ([self.sharingStuts isEqualToString:@"local_remote"]) {
             self.sharingStuts = @"local" ;
         }
        [self didLayoutParticipants:self.vcrtc.layoutParticipants] ;
    } else {

        NSLog(@"[vcrtc] share start - %@,%d,%@",self.sharingStuts,self.exSharing,[userDefaults objectForKey:@"screen_record_open_state"] );
        // 正在录制屏幕的分享,出现其他端打断当前会诊。
        if (self.exSharing && [self.sharingStuts isEqualToString:@"ex"] && ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] ||[[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] )) {
            [userDefaults setObject:@"stop" forKey:@"screen_record_open_state"];
            self.sharing = YES ;
            self.remoteSharing = YES ;
            self.sharingStuts = @"remote";
            self.shareBbtn.selected = NO;
            // 出现录制屏幕,并只有屏幕录制作为分享时。
        } else if( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]){
            self.sharing = YES ;
            self.shareBbtn.selected = YES ;
            self.recordScreenView.hidden = NO ;
            self.sharingStuts = @"ex";
            self.exSharing = YES ;
            NSLog(@"share image -- ssddd ");
            // 出现其他端,并只有其他端作为分享时。
        } else {
            self.sharing = YES ;
            self.remoteSharing = YES ;
            self.sharingStuts = @"remote";
            self.shareBbtn.selected = NO ;
        }
        
        VCSharingStauts stauts = [self justSharingStopStauts];
        
        NSLog(@"--- 当前分享状态 %ld", (long)stauts);
        switch (stauts) {
            case VCSharingStautsRemoteToLocal :
            case VCSharingStautsExToLocal :
                self.selectImages = [NSArray array];
                self.selectImageIndex = 0 ;
                self.localSharing = NO ;
                self.shareUuid = @"" ;
                [self showAlert] ;
                break;
                
            case VCSharingStautsRemoteToEx :
            case VCSharingStautsLocalToEx :
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

- (void) RTCHelper:(RTCHelper *)helper didUpdateImage:(NSString *)imageStr uuid:(nonnull NSString *)uuid {
    if (self.isStickOne) [self cancelStick:nil];
    if (!imageStr.length) return ;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];

    NSLog(@"[vcrtc] share update - %@,%d,%@",imageStr,self.exSharing,[userDefaults objectForKey:@"screen_record_open_state"] );
    if ([[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] ||
        [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"]) {
        [userDefaults setObject:@"opening" forKey:@"screen_record_open_state"];
        NSLog(@"[conference]update image ex");

        self.shareBbtn.selected = YES ;
        self.recordScreenView.hidden = NO ;
        self.sharingStuts = @"ex";
        self.exSharing = YES ;

        VCSharingStauts stauts = [self justSharingStopStauts];
        switch (stauts) {
            case VCSharingStautsRemoteToLocal :
            case VCSharingStautsExToLocal :
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

        if (self.localSharing && [self.sharingStuts isEqualToString:@"local"]) return ;
        if (!self.sharing) return ;
        NSURL *url= [NSURL URLWithString:imageStr];
        NSLog(@"[conference]update image remote 1");

        imageLock = NO ;
        
        self.photoType = YCPhotoSourceType_URL ;
        
        self.selectImages = @[url];
        
        
//        [VCTools imageDownLoadByUrlASYNC:url Complete:^(UIImage *image) {
//            if (self.sharing && ! (self.localSharing && [self.sharingStuts isEqualToString:@"local"] ) ) {
//                imageLock = YES ;
//                NSLog(@"[conference]update image remote 2");
                [self loadPresentationView];
//            }
//        }];
//        [self updatePresentSmallView];
    }
}

- (void) RTCHelper:(RTCHelper *)helper didStopImage:(NSString *)imageStr {
    if(privateCloud) {
        if (self.sharing || (!self.sharing && [self.sharingStuts isEqualToString:@"local"]) ) {
            if ([self.sharingStuts isEqualToString:@"ex"]) {
                self.sharing = NO ;
                self.sharingStuts = @"none" ;
                self.recordScreenView.hidden = YES;
                self.shareBbtn.selected = NO ;
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
                if ( [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"start"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] ) {
                    [userDefaults setObject:@"stop" forKey:@"screen_record_open_state"];
                }
            } else if ([self.sharingStuts isEqualToString:@"local"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sharing = NO ;
                    [self clearPresentationView];
                    [self.vcrtc shareToRemoteDisconnect];
                    [self.presentationView removeFromSuperview];
                    self.presentationView = nil ;
                    self.sharingStuts = @"none" ;
                    self.shareBbtn.selected = NO ;
                });
            } else if ([self.sharingStuts isEqualToString:@"local_remote"]) {
                // 此时为本地正在抢其他的分享者的分享。输出日志，证明一下。
                NSLog(@"[logs][stop][remote] log .......\n local with remote, to none");
            } else if ([self.sharingStuts isEqualToString:@"local_ex"]) {
                // 此时为本地正在抢 ex 的分享。输出日志，证明一下。 (不会出现)
                NSLog(@"[logs][stop][remote] log .......\n local with ex. error");
            } else if ([self.sharingStuts isEqualToString:@"remote"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sharing = NO ;
                    [self clearPresentationView];
                    [self.vcrtc shareToRemoteDisconnect];
                    [self.presentationView removeFromSuperview];
                    self.presentationView = nil ;
                    self.sharingStuts = @"none" ;
                    self.shareBbtn.selected = NO ;
                });
            } else {
                
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sharing = NO ;
                [self clearPresentationView];
                [self.vcrtc shareToRemoteDisconnect];
                [self.presentationView removeFromSuperview];
                self.presentationView = nil ;
                self.sharingStuts = @"none" ;
                self.shareBbtn.selected = NO ;
            });
            
            NSLog(@"[error][stop][remote] warning !!!!!!!!!! \n Find share status is close ! repeat");
        }
        [self didLayoutParticipants:self.layoutParticipants] ;
    } else {
        if ([imageStr isEqualToString:@"stopex"] && [self.sharingStuts isEqualToString:@"remote"]) {
            return ;
        }
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
        if([self.sharingStuts isEqualToString:@"ex"] && self.exSharing && self.shareBbtn.selected  ) {
            if (([[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"stop"] || [[userDefaults objectForKey:@"screen_record_open_state"] isEqualToString:@"applaunch"])) {
                
            } else {
                return ;
            }
        }
        VCSharingStauts stauts = [self justSharingStopStauts];
        switch (stauts) {
            case VCSharingStautsNone :
                return;
                break;
                
            case VCSharingStautsRemote :
                self.sharing = NO ;
                [self clearPresentationView];
                [self.presentationView removeFromSuperview];
                self.presentationView = nil ;
            case VCSharingStautsExToRemote :
            case VCSharingStautsLocalToRemote :
                self.remoteSharing = NO ;
                break;
                
            case VCSharingStautsEx :
                self.sharing = NO ;
                [self clearPresentationView];
                [self.presentationView removeFromSuperview];
                self.shareBbtn.selected = NO ;
                self.presentationView = nil ;
            case VCSharingStautsRemoteToEx :
            case VCSharingStautsLocalToEx :
                self.exSharing = NO ;
                self.recordScreenView.hidden = YES;
                break;
                
            default:
                break;
        }
        [self changeLayoutStream];
    }
    [self didLayoutParticipants:self.layoutParticipants] ;
}

- (VCSharingStauts )justSharingStopStauts{
    int trueCount = 0 ;
    for (NSNumber *number in @[[NSNumber numberWithBool:self.remoteSharing],
                               [NSNumber numberWithBool:self.localSharing],
                               [NSNumber numberWithBool:self.exSharing]]) {
        if ([number boolValue]) {
            trueCount ++ ;
        }
    }
    
    if ([self.sharingStuts isEqualToString:@"video"]) {
        return VCSharingStautsVideo ;
    }
    
    if (trueCount == 1) {
        if (self.remoteSharing) {
            return VCSharingStautsRemote;
        } else if (self.localSharing) {
            return VCSharingStautsLocal ;
        } else if (self.exSharing) {
            return VCSharingStautsEx;
        }
    } else if (trueCount == 2) {
        if (self.remoteSharing && self.localSharing) {
            if ([self.sharingStuts isEqualToString:@"remote"]) {
                return VCSharingStautsRemoteToLocal ;
            } else if([self.sharingStuts isEqualToString:@"local"]){
                return VCSharingStautsLocalToRemote ;
            }
        } else if (self.remoteSharing && self.exSharing) {
            if ([self.sharingStuts isEqualToString:@"remote"]) {
                return VCSharingStautsRemoteToEx ;
            } else if([self.sharingStuts isEqualToString:@"ex"]){
                return VCSharingStautsExToRemote ;
            }
        } else if (self.localSharing && self.exSharing) {
            if ([self.sharingStuts isEqualToString:@"local"]) {
                return VCSharingStautsLocalToEx ;
            } else if([self.sharingStuts isEqualToString:@"ex"]){
                return VCSharingStautsExToLocal ;
            }
        }
    }
    return VCSharingStautsNone;
}

#pragma mark - VCRtcModuleDelegate 状态。

- (void) RTCHelper:(RTCHelper *)helper didUpdateRecordAndlive:(nonnull NSDictionary *)data{
    if (!privateCloud) {
        BOOL isRecord = [data[@"isrecord"] boolValue];
        BOOL isLiving = [data[@"isliving"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isRecording = isRecord ;
            self.isLiving = isLiving ;
        });
    }
}

- (void) RTCHelper:(RTCHelper *)helper didUpdateConferenceStatus:(NSDictionary *)data {
    if (privateCloud) {
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
    self.participantCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)participants.count];
}

- (void) RTCHelper:(RTCHelper *)helper didDisconnectedWithReason:(NSError *)reason {
    NSString *patchStr = [[NSBundle mainBundle]pathForResource:@"ErrorReason" ofType:@"plist"];
    NSDictionary *reasonDic = [NSDictionary dictionaryWithContentsOfFile:patchStr];
    NSString *reasonChair = reasonDic[reason.userInfo[NSLocalizedDescriptionKey]];
    [self errorInforDismissControl:reasonChair.length ? reasonChair : reason.userInfo[NSLocalizedDescriptionKey]];
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
    [self reloadStats:mediaStats];
}

- (void)reloadStats:(NSArray *)stats {
    for (VCMediaStat *stat in stats) {
        NSLog(@"media stat - %@", stat);
    }
    
    NSMutableArray *mArr = [NSMutableArray array];
    [mArr addObject:@[@"",@"通道名称",@"codec",@"分辨率",@"帧率",@"码率",@"丢包率"]];
    [mArr addObjectsFromArray:[self.confHelper conf_parseMediaStats:stats]];
    [mArr addObject:@[@"本端CPU",[NSString stringWithFormat:@"%0.1lf%%",[self.confHelper conf_appCPUsage]],@"--",@"内存使用",[NSString stringWithFormat:@"%0.1lfMB",[self.confHelper conf_memoryUsage]],@"",@""]];
    self.networkArr = [mArr copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.netBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_sign_%ld", (unsigned long) (self.confHelper.qualityLevel + 1)]] forState:UIControlStateNormal];
        [self.netQuailtyTable reloadData];
    });
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
    self.confHelper.livingEnable = self.isLiving && [self.vcrtc.role isEqualToString:@"HOST"] ;
    self.confHelper.recordEnable = self.isRecording && [self.vcrtc.role isEqualToString:@"HOST"] ;
    self.confHelper.sticking = self.isStickOne ;
    if (!self.sharing || privateCloud) {
        [self createBigStreamView];
        if (self.loadSmallView) {
            [self createSmallStreamView];
        }
    }
    if (self.sharing && ( [self.sharingStuts isEqualToString:@"local_remote"] || [self.sharingStuts isEqualToString:@"local"] || [self.sharingStuts isEqualToString:@"local_ex"]) ) {
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
    if (marrShows.count == 0) return ;
    NSMutableDictionary *owner = marrShows[0] ;
    NSString *uuid = owner[@"uuid"];
    BOOL isClose = [self.vcrtc.uuid isEqualToString:uuid] && self.vMute.selected ;
    if (!marrShows.count) return ;
    if(self.manageView.subviews.count == 0){
        [self.manageView addSubview:[self.confHelper conf_reloadView:YES localCutClose:isClose  withOwner:owner withIndex:0 withSize:CGSizeMake(self.manageView.ott_width, self.manageView.ott_height) streamCount:marrShows.count]];
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

    if (self.sharing) return ;
    if ([self.sharingStuts isEqualToString:@"video"] &&  self.layoutParticipants.count == 2) return ;
    NSMutableDictionary *owner = self.streamOnwers[sender.tag] ;
    self.stickUuid = owner[@"uuid"] ;
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
        self.stickUuid = owner[@"uuid"] ;
        self.isStickOne = YES ;
        self.isShowStickOpen = YES ;
        [self didLayoutParticipants:self.vcrtc.layoutParticipants];
    }
}

- (IBAction)clickCancelStick:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenView:) object:sender];
    [self cancelStick:sender];
}

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
    for (int i = 1; i < marrShows.count ; i ++) {
        if ( !(i < self.manageView.subviews.count) ) {
            NSMutableDictionary *owner = marrShows[i] ;
            NSString *uuid = owner[@"uuid"];
            BOOL isClose = [self.vcrtc.uuid isEqualToString:uuid] && self.vMute.selected ;
            [self.manageView addSubview:[self.confHelper conf_reloadView:NO localCutClose:isClose withOwner:owner withIndex:i withSize:CGSizeMake(self.manageView.ott_width, self.manageView.ott_height) streamCount:marrShows.count] ];
        }
    }
}

- (void)removeIndexVideoView  {
    UIView *samllView = self.manageView.subviews[self.manageView.subviews.count - 1];
    [samllView removeFromSuperview];
}

#pragma mark -  click item

- (void)hiddenView:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = self.topView.alpha == 0 ? 0.9 : 0 ;
        self.bottomView.alpha = self.bottomView.alpha == 0 ? 0.9 : 0 ;
        [self setNeedsStatusBarAppearanceUpdate];
    }];

    [self.hiddenTimer invalidate];
    self.hiddenTimer = nil ;
    [[NSRunLoop currentRunLoop] addTimer:self.hiddenTimer forMode:NSRunLoopCommonModes];
}

- (IBAction)mute:(id)sender {
    UIButton *btn = sender ;
    [self.vcrtc micEnable:btn.selected];
    btn.selected = !btn.selected ;
}

- (IBAction)vmute:(id)sender {
    UIButton *btn = sender ;
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return ;
    }
    self.confHelper.needCloseVideo = btn.selected ;
    [self.vcrtc videoEnable: btn.selected];
    btn.selected = !btn.selected ;
    if (btn.selected) {
        [self layoutOrderParticipants];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self layoutOrderParticipants];
        }];
    }
}

- (IBAction)toggle:(id)sender {
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return ;
    }
    [self.vcrtc switchCamera ];
    self.frontCamera = !self.frontCamera ;
}

- (IBAction)onlyAudio:(id)sender {
    UIButton *btn = sender ;
    if (!self.vMute.selected) {
        [self.vcrtc onlyAudioEnable: btn.selected];
    }
    self.confHelper.needCloseVideo = btn.selected ;
    if (!btn.selected) {
        self.onlyAudioView.hidden = NO ;
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer * _Nonnull timer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.onlyAudioView.hidden = YES ;
            }) ;
        }];
    }
    [self.vcrtc resetClayout: btn.selected ? @"1:4" : @"0:0"] ;
    btn.selected = !btn.selected ;
}

- (IBAction)share:(id)sender {
    if (self.onlyAudioBtn.selected) {
        [self animateShowUnlockView:@"语音模式中..."];
        return ;
    }
    if (self.shareBbtn.selected) {
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
        if ([[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"opening"] ||  [[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"start"]) {
            [self RTCHelper:self.rtcHelper didStopImage:@""];
            [userDefault setObject:@"appstop" forKey:@"screen_record_open_state"];
        } else {
            if (privateCloud) {
                [self.vcrtc shareToStreamImageData:[NSData data]
                                              open:NO
                                            change:NO
                                           success:^(id  _Nonnull response) {}
                                           failure:^(NSError * _Nonnull error) {}];
            } else {
                [self.vcrtc shareImageData:[NSData data]
                                      open:NO
                                    change:NO
                                   success:^(id  _Nonnull response) {}
                                   failure:^(NSError * _Nonnull error) {}];
                
            }
            
            
            self.sharing = NO ;
            [self clearPresentationView];
            [self.presentationView removeFromSuperview];
            self.presentationView = nil ;
            self.selectImages = [NSArray array];
            self.selectImageIndex = 0 ;
            self.localSharing = NO ;
            self.shareUuid = @"";
        }
        self.sharing = NO ;
        self.shareBbtn.selected = NO ;
        return ;
    }
    
    [self.confHelper conf_alertGetResources];
}

- (void)vcrtc:(VCRtcModule *)module responseSuccessed:(BOOL)isSuccessed {
    if (isSuccessed) {
        self.shareUuid = @"new";
        self.shareBbtn.selected = YES ;
        self.localSharing = YES ;
        self.sharing = YES ;
    } else {
        if(self.shareBbtn.selected == NO) return ;
        self.shareBbtn.selected = NO ;
        self.sharing = NO ;
        self.localSharing = NO ;
        [self animateShowUnlockView:@"分享失败"];
    }
}

- (void)submitSharingImage:(UIImage *)image {
    self.sharing = YES ;
    NSData* data = UIImageJPEGRepresentation(image, 1);
    
    if (privateCloud) {
        
        
        [self.vcrtc shareToStreamImageData:data open:YES change:self.shareUuid.length ? YES : NO success:^(id  _Nonnull response) {
        } failure:^(NSError * _Nonnull error) {
        }];
        self.shareUuid = @"new";
        self.shareBbtn.selected = YES ;
        self.localSharing = YES ;
        self.sharingStuts = !self.sharing ? @"local" : @"local_remote" ;

        self.sharing = YES ;
    } else {
        [self.vcrtc shareImageData:data open:YES change:self.shareUuid.length ? YES : NO success:^(id  _Nonnull response) {
            NSLog(@"分享成功：%@ -- ",response);
            self.shareUuid = @"new";
            self.shareBbtn.selected = YES ;
            self.localSharing = YES ;
            self.sharing = YES ;
            self.sharingStuts = @"local";
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"分享失败：%@ -- ",error);
            if(self.shareBbtn.selected == NO) return ;
            self.shareBbtn.selected = NO ;
            self.sharing = NO ;
            self.localSharing = NO ;
        }];
    }
    
    }

#pragma mark - 辅助视图更换的方法

- (void)conferenceHelper:(ConferenceHelper *)helper didPhotoResource:(NSArray *)selectImages{
    self.selectImages = selectImages ;
    self.photoType = YCPhotoSourceType_Image ;
    [self.vcrtc shareToRemoteDisconnect];
    [self loadPresentationView];
    [self submitSharingImage:self.selectImages[0]];
}

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
    [self submitSharingImage:self.selectImages[page]];
}

- (void)conferenceHelper:(ConferenceHelper *)helper zoomEndImage:(UIImage *)image {
    [self submitSharingImage:image];
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
//        if(self.presentationView.subviews.count == 2){
//            [self.presentationView.subviews[1] removeFromSuperview];
//        }
        
        UIView *samllView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - self.view.frame.size.width/5.0 * 9/16, self.view.frame.size.width/5.0-1 , self.view.frame.size.width/5.0 * 9/16)];
        VCVideoView *view ;
        if (self.streamOnwers.count == 0) {
            return ;
        } else if (self.streamOnwers.count == 1) {
            view = self.streamOnwers[0][@"view"] ;
        } else if (self.streamOnwers.count > 1) {
            view = self.streamOnwers[0][@"view"] ;
        }
        // 背景图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, samllView.frame.size.width, samllView.frame.size.height) ];
        imageView.image = [UIImage imageNamed:@"background-close-video"];
        [samllView addSubview:imageView];
        
        view.objectFit = VCVideoViewObjectFitCover ;
        view.frame = CGRectMake(0, 0, samllView.frame.size.width, samllView.frame.size.height)  ;
        [samllView addSubview:view];
//        samllView.hidden = !self.loadSmallView;
        samllView.layer.zPosition = 1;
        [self.presentationView addSubview:samllView];
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
                [self updatePresentSmallView];
            }
        }
    }];
   
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = self.topView.alpha == 0 ? 0.9 : 0 ;
        self.bottomView.alpha = self.bottomView.alpha == 0 ? 0.9 : 0 ;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (IBAction)manageConference:(id)sender {
    
}


- (IBAction)down:(id)sender {
    [self.confHelper conf_doExitChannel];
}

- (void) recordClick {
    [self.confHelper conf_toggleRecordEnable:!self.isRecording];
}

- (void) livingClick {
    [self.confHelper conf_toggleLivingEnable:!self.isLiving];
}

- (IBAction)showNetQuelity:(id)sender {
    self.netQuailtyTable.hidden = NO ;
}

- (void)myDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self dismissViewControllerAnimated:flag completion:nil];
    [self.confHelper conf_removeAllRegister];
    [self.hiddenTimer invalidate];
    [self.recordTimer invalidate];
    [self.timeLengthTimer invalidate];
}

#pragma mark - table view delegate & datasoruce

- (CGFloat ) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44 ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width , 44)];
    UIButton *btnView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnView.frame = CGRectMake(0, 0, 44, 44) ;
    [btnView setTitle:@"关闭" forState:UIControlStateNormal ];
    [btnView setTintColor:[UIColor whiteColor]];
    btnView.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnView addTarget:self action:@selector(closeNetworkingView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnView];
    return view ;
}

- (void)closeNetworkingView:(UIButton *)btn {
    self.netQuailtyTable.hidden = YES ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.networkArr.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"joinconferecnce_table_cellid_sdk";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId] ;
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    } else {
        for (UIView *view  in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    [cell.layer setBorderWidth:0.5];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    [cell.contentView addSubview:[self addLandscapeView:cell datas:self.networkArr[indexPath.row]]];
    
    return cell;
}

- (UIView *)addLandscapeView:(UITableViewCell *)cell  datas:(NSArray *)datas {
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.netQuailtyTable.frame.size.width, 30)];
    for (int i = 0 ; i < datas.count; i ++) {
        UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(i * ( self.netQuailtyTable.frame.size.width/ (float)datas.count), 0, self.netQuailtyTable.frame.size.width/ (float)datas.count , 30)];
        [subView.layer setBorderWidth:0.5];
        [subView.layer setMasksToBounds:YES];
        [subView.layer setBorderColor:[UIColor whiteColor].CGColor];
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView.frame.size.width, 30)];
        lab.textAlignment = NSTextAlignmentCenter ;
        lab.center = CGPointMake(subView.frame.size.width/2.0, subView.frame.size.height/2.0);
        lab.text = datas[i];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:14];
        
        [subView addSubview:lab];
        [cellView addSubview:subView];
    }
    return cellView ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30 ;
}

-(void)conferenceHelper:(ConferenceHelper *)helper dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self myDismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - 界面和数据存储的加载

-(NSTimer *)recordTimer {
    if (!_recordTimer) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
            NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
            _recordTimer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if ([[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"stop"] ||
                    [[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"appfinsh"]) {
                    [userDefault setObject:@"applaunch" forKey:@"screen_record_open_state"];
                    NSLog(@"定时器 检测到stop... +++++++++++++++++++++++++++++++++++++++++");
                    [self.vcrtc stopRecordScreen];
                    if (!privateCloud) {
                        [self RTCHelper:self.rtcHelper didStopImage:@"stopex"];
                    }
                }
            }];
        } else {
            _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
                if ([[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"stop"] ||
                    [[userDefault objectForKey:@"screen_record_open_state"] isEqualToString:@"appfinsh"]) {
                    [userDefault setObject:@"applaunch" forKey:@"screen_record_open_state"];
                    [self.vcrtc stopRecordScreen];
                }
            }];
        }
    }
    return _recordTimer ;
}

- (NSTimer *)hiddenTimer {
    if (!_hiddenTimer ) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
            _hiddenTimer = [NSTimer timerWithTimeInterval:6 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topView.alpha = 0 ;
                    self.bottomView.alpha = 0 ;
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            }];
        } else {
            _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:6 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.topView.alpha = 0 ;
                    self.bottomView.alpha = 0 ;
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            }];
        }
    }
    return _hiddenTimer ;
}

- (void)changeTimeLengthText {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSString *stringDate = @"00:00:00";
    NSDate *date = [dateFormatter dateFromString:stringDate];
    NSDate *dateTime = [[NSDate alloc]initWithTimeInterval:timeCount sinceDate:date];
    NSString *stringTime = [dateFormatter stringFromDate:dateTime];
    timeCount ++ ;
    self.timeLength.text = stringTime ;
}

- (void)loadTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( @available(iOS 10.0, *)) {
            self.timeLengthTimer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [self changeTimeLengthText] ;
            }];
            [[NSRunLoop currentRunLoop]addTimer:self.timeLengthTimer forMode:NSRunLoopCommonModes];
        } else {
            self.timeLengthTimer = [NSTimer scheduledTimerWithTimeInterval:6 repeats:NO block:^(NSTimer * _Nonnull timer) {
               [self changeTimeLengthText] ;
            }];
        }
    });
}

- (UIView *)recordScreenView {
    if (!_recordScreenView) {
        _recordScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGFloat superViewWidth = self.view.frame.size.width ;
        CGFloat superViewHeight = self.view.frame.size.height ;
        BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
        CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
        CGFloat viewHeight = viewWidth * 9 / 16.0 ;
        UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        backgroundImage.image = [UIImage imageNamed:@"record_screen"];
        backgroundImage.userInteractionEnabled = YES ;
        backgroundImage.center = CGPointMake( self.view.frame.size.width/2.0, self.view.frame.size.height/2.0) ;
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
        _onlyAudioView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGFloat superViewWidth = self.view.frame.size.width ;
        CGFloat superViewHeight = self.view.frame.size.height ;
        BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
        CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
        CGFloat viewHeight = viewWidth * 9 / 16.0 ;
        UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        backgroundImage.image = [UIImage imageNamed:@"background-audio"];
        backgroundImage.userInteractionEnabled = YES ;
        backgroundImage.center = CGPointMake( self.view.frame.size.width/2.0, self.view.frame.size.height/2.0) ;
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

- (NSMutableArray *)streamOnwers {
    if (!_streamOnwers) {
        _streamOnwers = [NSMutableArray array] ;
    }
    return _streamOnwers ;
}


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
        [_manageView addGestureRecognizer:tapG];
        
    }
    return _manageView ;
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
        _broadcastView.preferredExtension = kVCConfig_Extension ;
        _broadcastView.hidden = YES ;
        [self.view addSubview:_broadcastView];
    }
    return _broadcastView ;
}

#pragma mark - Controller 的屏幕和状态栏

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight ;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight ;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent ;
}

- (BOOL )prefersStatusBarHidden {
    return self.topView.alpha == 0 ;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


@end
