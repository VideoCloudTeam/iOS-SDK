//
//  ViewController.m
//  iOSDemo
//
//  Created by mac on 2019/6/26.
//  Copyright © 2019 mac. All rights reserved.
//

#import "ExampleVC.h"
#import "VideoViewModel.h"
#import "SmallView.h"
#import "ConferenceVCCell.h"
#import "ConferenceHeaderView.h"
#import "VCPresentionView.h"
#import "ShareModel.h"
#import "NotRecordedController.h"
#import "DocumentPickerViewController.h"
#import "PDFHandle.h"

@interface ExampleVC ()<VCRtcModuleDelegate,TZImagePickerControllerDelegate,VCPresentionViewDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) VCRtcModule *vcrtc;
/** 远端视图 */
@property (weak, nonatomic) IBOutlet UIView *othersView;
/** 远端视频views */
@property (nonatomic, strong) NSMutableArray <VideoViewModel *>*farEndViewsArray;
/** 本地视频View */
@property (nonatomic, strong) VCVideoView *localView;
/** 顶部视图 */
@property (weak, nonatomic) IBOutlet UIView *topView;
/** 底部视图 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;
/** 点击隐藏 bottomView topView */
@property (weak, nonatomic) IBOutlet UIButton *clickBtn;
/** 分享 */
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
/** 显示会议室号 */
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
/** 质量统计 */
@property (weak, nonatomic) IBOutlet UITableView *table;
/** 质量统计数据 */
@property (nonatomic, strong) NSMutableArray<NSArray<NSString *> *> *statisticsArray;
/** 显示分享图片视图 */
@property (nonatomic, strong)VCPresentionView *shareView;
/** 图片清晰度要求 */
@property (nonatomic, assign) YCPhotoSourceType photoType;
/** 分享的图片 */
@property (nonatomic, strong) NSArray *shareImages;
/** 分享相关的状态记录
 注意: isPrivateCloud 为YES时 接收分享和屏幕共享都是流 本端图片分享和屏幕共享都是流
 isPrivateCloud 为NO时, 接收分享和屏幕共享是图片 本端图片分享是图片形式本端屏幕共享是流
 */
@property (nonatomic, strong) ShareModel *shareModel;
/** 本地屏幕录制状态显示 */
@property (weak, nonatomic) IBOutlet UIImageView *screenRecordStateImg;
/** 屏幕录制由于屏幕录制关闭后, 无法及时获取该状态,所以使用定时器时刻监测该状态 */
@property (nonatomic, strong) NSTimer *recordTimer ;
/**本地自己的音视频数据模型 */
@property (nonatomic, strong) VideoViewModel *localViewModel;
/** 指定上大屏幕的参会者ID */
@property (nonatomic, copy) NSString *stickUUID;
/** 是否关闭画中画 */
@property (nonatomic, assign, getter=isClosePicterInPicter) BOOL closePicterInPicter;
@end

@implementation ExampleVC
- (void)dealloc
{
    NSLog(@"----------------dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
}

- (ShareModel *)shareModel {
    if (!_shareModel) {
        _shareModel = [[ShareModel alloc]init];
        _shareModel.shareType = @"none";
        _shareModel.isSharing = NO;
        _shareModel.uuid = @"";
    }
    return _shareModel;
}

- (VCPresentionView *)shareView {
    if (!_shareView) {
        _shareView = [[VCPresentionView alloc]initWithFrame:self.view.frame showImagesOrURLs:self.shareImages PhotoSourceType:self.photoType];
        _shareView.delegate = self;
        _shareView.backgroundColor = [UIColor clearColor];
    }
    return _shareView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewPropertySet];
    self.farEndViewsArray = [NSMutableArray array];
    [self joinMeetingSet];
    
}
//入会配置
- (void)joinMeetingSet {
    //初始化
    self.vcrtc = [VCRtcModule sharedInstance];
    //配置服务器域名
    self.vcrtc.apiServer = self.serverString;
    //遵循 VCRtcModuleDelegate方法
    self.vcrtc.delegate = self;
//    self.vcrtc.groupId = kGroupId;
    //入会类型配置 点对点
    [self.vcrtc configConnectType:VCConnectTypeUser];
    //入会音视频质量配置
    [self.vcrtc configVideoProfile:VCVideoProfile360P];
    //入会接收流的方式配置
    [self.vcrtc configMultistream:self.isMultistream];
    [self.vcrtc configPrivateCloudPlatform:YES];
    //用户账号配置(用户登录需配置,未登录不需要)
    // [self.vcrtc configLoginAccount:@"填写登录的账号"];
    //配置音视频 channel: 用户地址 password: 参会密码 name: 会中显示名称 xiaobeioldone@zijingcloud.com
    [self.vcrtc connectChannel:self.meetingNumString password:self.passwordString name:@"test_ios_demo" success:^(id _Nonnull response) {
        //记录此时会议状态
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
        [userDefault setObject:@"inmeeting" forKey:kScreenRecordMeetingState];
        
    } failure:^(NSError * _Nonnull error) {
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
        [userDefault setObject:@"outmeeting" forKey:kScreenRecordMeetingState];
    }];
    self.vcrtc.forceOrientation = UIDeviceOrientationLandscapeLeft;
    [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
}

//视图的属性设置
- (void)viewPropertySet {
    self.topView.backgroundColor = [[UIColor colorWithRed:18/255.0 green:26/255.0 blue:44/255.0 alpha:1.0] colorWithAlphaComponent:0.9];
    self.bottomView.backgroundColor = [[UIColor colorWithRed:18/255.0 green:26/255.0 blue:44/255.0 alpha:1.0] colorWithAlphaComponent:0.9];
    self.table.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.table registerClass:[ConferenceVCCell class] forCellReuseIdentifier:@"ConferenceVCCell"];
    self.nameLab.text = self.meetingNumString;
}


/**
 监测本端屏幕共享是否结束
 由于屏幕录制停止了,这儿不能及时获取
 */
-(NSTimer *)recordTimer {
    if (!_recordTimer) {
        _recordTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(monitoringScreenRecordStopState) userInfo:nil repeats:YES];
    }
    return _recordTimer ;
}

- (void)monitoringScreenRecordStopState {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId];
    //屏幕共享结束 调用stopRecordScreen表示告诉服务器,自己本端屏幕共享结束了
    if ([[userDefault objectForKey:kScreenRecordState] isEqualToString:@"stop"] ||
        [[userDefault objectForKey:kScreenRecordState] isEqualToString:@"appfinsh"]) {
        [userDefault setObject:@"applaunch" forKey:kScreenRecordState];
        [self.vcrtc stopRecordScreen];
    }
}


#pragma mark - VCRtcModuleDelegate 接收会中音视频处理
//接收本地视频
- (void)VCRtc:(VCRtcModule *)module didAddLocalView:(VCVideoView *)view {
    Participant *localParticipant = [[Participant alloc] init];
    localParticipant.role = @"host";
    localParticipant.uuid = self.vcrtc.uuid ;
    localParticipant.overlayText = @"我";
    self.localViewModel = [[VideoViewModel alloc] initWithuuid:self.vcrtc.uuid videoView:view participant:localParticipant];
    [self.farEndViewsArray addObject:self.localViewModel];
    [self layoutFarEndView:self.vcrtc.layoutParticipants];
    
    
    
}
// 接收远端视频
- (void)VCRtc:(VCRtcModule *)module didAddView:(VCVideoView *)view uuid:(NSString *)uuid {
    //多流的视频处理方式
    if (self.isMultistream) {
        if (self.isPrivateCloud) {
            //isPrivateCloud 为YES 分享图片和共享屏幕是流的方式
            //该视图是否是图片分享/共享屏幕视屏流
            if (!view.isPresentation) {
                [self.farEndViewsArray addObject:[[VideoViewModel alloc] initWithuuid:uuid videoView:view participant:self.vcrtc.rosterList[uuid]]];
            } else {
                //远端图片分享/共享屏幕流时添加该视屏流视图
                [self.farEndViewsArray addObject:[[VideoViewModel alloc] initWithuuid:[uuid stringByAppendingString:@"-presentation"] videoView:view participant:self.vcrtc.rosterList[uuid]]];
            }
        } else {
            
            [self.farEndViewsArray addObject:[[VideoViewModel alloc] initWithuuid:uuid videoView:view participant:self.vcrtc.rosterList[uuid]]];
        }
        
    } else {
        //单流流处理方式
        NSMutableArray *tempArray = [NSMutableArray array];
        [tempArray addObject:[[VideoViewModel alloc] initWithuuid:uuid videoView:view participant:self.vcrtc.rosterList[uuid]]];
        for (VideoViewModel *sub in self.farEndViewsArray) {
            if ([self.vcrtc.uuid isEqualToString:sub.uuid]) {
                [tempArray addObject:sub] ;
            }
        }
        self.farEndViewsArray = tempArray;
    }
    [self layoutFarEndView:self.vcrtc.layoutParticipants];
}

//有参会者离开会议
- (void)VCRtc:(VCRtcModule *)module didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid {
    NSString * removeUUID =  uuid;
    if (view.isPresentation) {
        removeUUID = [uuid stringByAppendingString:@"-presentation"];
    }
    
    for (UIView *view in self.othersView.subviews) {
        if ([view isKindOfClass:[SmallView class]]) {
            SmallView *smallView = (SmallView *)view;
            if ([smallView.uuid isEqualToString:removeUUID]) {
                [smallView removeFromSuperview];
            }
        }
    }
    
    //从数组上移除
    [self.farEndViewsArray enumerateObjectsUsingBlock:^(VideoViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.uuid isEqualToString:removeUUID]) {
            [self.farEndViewsArray removeObject:obj];
        }
    }];
    //更新布局
    [self layoutFarEndView:self.vcrtc.layoutParticipants];
}

- (void)VCRtc:(VCRtcModule *)module didLayoutParticipants:(NSArray *)participants {
    [self layoutFarEndView:participants];
}


//连接失败
- (void)VCRtc:(VCRtcModule *)module didDisconnectedWithReason:(NSError *)reason {
    NSLog(@"失败原因: %@",reason);
}

//质量统计数据
- (void)VCRtc:(VCRtcModule *)module didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats {
    [self statisticsHandle:mediaStats];
}

//MARK: - 分享 - 远端 本端发送图片 、 本端录制屏幕
/**
 公有云下:
 自己本端分享图片和屏幕共享的时候didStartImage方法不会调用 只有远端共享图片和屏幕共享的时候才会调用
 专属云 本端分享图片屏幕共享会调用该方法didStartImage
 */
- (void)VCRtc:(VCRtcModule *)module didStartImage:(NSString *)shareUuid {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
    if (self.isPrivateCloud) {
        //本端分享/或共享屏幕
        if ([self.vcrtc.uuid isEqualToString:shareUuid]) {
            //本端开始共享屏幕
            if (([[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"ongoing"] || [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"start"])) {
                //被抢流本端屏幕共享停止
                [userDefaults setObject:@"ongoing" forKey:kScreenRecordState];
                //分享类型是远端分享
                self.shareModel.shareType = @"localScreenShare";
                //远端正在开始准备分享
                self.shareModel.isSharing = YES;
                //远端分享者的唯一标识
                self.shareModel.uuid = shareUuid;
                //本端屏幕录制状态图隐藏
                self.screenRecordStateImg.hidden = NO;
                //本端分享按钮非选中状态
                self.shareBtn.selected = YES;
                
            } else {
                //本端分享图片
                //分享按钮选中状态
                self.shareBtn.selected = YES;
                //分享类型 本端图片分享
                self.shareModel.shareType = @"local";
                //分享人的唯一标识
                self.shareModel.uuid = shareUuid;
                //正在分享
                self.shareModel.isSharing = YES;
                
            }
        } else {
            //远端分享图片或者屏幕共享(接收分享的图片是流的形式所以不需要shareView来显示)
            [self.shareView removeFromSuperview];
            //分享按钮非选中状态
            self.shareBtn.selected = NO;
            //分享类型 远端图片分享或屏幕共享
            self.shareModel.shareType = @"remote";
            //分享人的唯一标识
            self.shareModel.uuid = shareUuid;
            //正在分享
            self.shareModel.isSharing = YES;
        }
        [self layoutFarEndView:self.vcrtc.layoutParticipants];
    } else {
        //本地屏幕共享 被远端抢流(远端屏幕共享,分享图片)
        //ongoing 本端屏幕录制进行中
        //start 本端屏幕录制开始中
        if (([[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"ongoing"] || [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"start"]) && self.shareModel.isSharing && [self.shareModel.shareType isEqualToString:@"localScreenShare"] ) {
            //被抢流本端屏幕共享停止
            [userDefaults setObject:@"stop" forKey:kScreenRecordState];
            //分享类型是远端分享
            self.shareModel.shareType = @"remote";
            //远端正在开始准备分享
            self.shareModel.isSharing = YES;
            //远端分享者的唯一标识
            self.shareModel.uuid = shareUuid;
            //本端屏幕录制状态图隐藏
            self.screenRecordStateImg.hidden = YES;
            //本端分享按钮非选中状态
            self.shareBtn.selected = NO;
            
        } else {
            //远端图片分享或屏幕共享
            if (![shareUuid isEqualToString:self.vcrtc.uuid]) {
                //分享按钮非选中状态
                self.shareBtn.selected = NO;
                //分享类型 远端图片分享或屏幕共享
                self.shareModel.shareType = @"remote";
                //分享人的唯一标识
                self.shareModel.uuid = shareUuid;
                //正在分享
                self.shareModel.isSharing = YES;
            }
        }
    }
    
}


/**
 isPrivateCloud 为NO 这个方法无论是本端或远端图片分享或屏幕共享都会调用
 isPrivateCloud 为 YES 该方法不调用 因为分享和屏幕共享都是流的形式
 */
- (void)VCRtc:(VCRtcModule *)module didUpdateImage:(NSString *)imageStr uuid:(NSString *)uuid {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
    //本端正在屏幕共享
    if ([[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"start"] || [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"ongoing"]) {
        //状态更改为正在屏幕共享进行中
        [userDefaults setObject:@"ongoing" forKey:kScreenRecordState];
        //远端在屏幕共享本端抢流
        if ([self.shareModel.shareType isEqualToString:@"remote"] && self.shareModel.isSharing) {
            [self.shareView removeFromSuperview];
        }
        //本端屏幕共享
        self.shareModel.shareType = @"localScreenShare";
        //正在屏幕共享
        self.shareModel.isSharing = YES;
        //显示屏幕共享状态图
        self.screenRecordStateImg.hidden = NO;
        //分享按钮选中状态
        self.shareBtn.selected = YES;
        
    } else {
        //分享图自己本端分享的时候不做处理 或者是屏幕录制也不做处理
        if (([self.shareModel.shareType isEqualToString:@"local"] || [self.shareModel.shareType isEqualToString:@"localScreenShare"]) && self.shareModel.isSharing ) {
            return;
        }
        //图片来源是否修改高清的链接
        self.photoType = YCPhotoSourceType_URL ;
        //远端分享或屏幕共享的图片URL
        NSURL *url= [NSURL URLWithString:imageStr];
        self.shareImages = @[url];
        [self loadPresentationView];
    }
    
}


/**
 isPrivateCloud 为NO 远端屏幕共享或图片分享结束才调用 本端不调用
 isPrivateCloud 为YES 本端和远端分享或屏幕共享结束都会调用
 */
- (void)VCRtc:(VCRtcModule *)module didStopImage:(NSString *)imageStr {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
    if (self.isPrivateCloud) {
        //本端在分享图片的时候没结束不能屏幕共享
        if (self.shareModel.isSharing && [self.shareModel.shareType isEqualToString:@"local"] && [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"start"]) {
            //更新状态 屏幕共享结束
            [userDefaults setObject:@"stop" forKey:kScreenRecordState];
            //分享按钮非选中状态
            self.shareBtn.selected = NO;
            //屏幕共享状态视图隐藏
            self.screenRecordStateImg.hidden = YES;
            //分享model数据为空
            self.shareModel = nil;
            [self.shareView removeFromSuperview];
            //分享断开
            [self.vcrtc shareToRemoteDisconnect];
            //更新屏幕显示的视频
            [self layoutFarEndView:self.vcrtc.layoutParticipants];
        } else if  (self.shareModel.isSharing && [self.shareModel.shareType isEqualToString:@"localScreenShare"] && ([[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"start"] || [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"ongoing"])) {
            //屏幕共享被远端抢流
            //更新状态 屏幕共享结束
            [userDefaults setObject:@"stop" forKey:kScreenRecordState];
            self.shareModel = nil;
            self.screenRecordStateImg.hidden = YES;
            self.shareBtn.selected = NO;
            [self layoutFarEndView:self.vcrtc.layoutParticipants];
        } else {
            //远端图片分享结束
            if ([self.shareModel.shareType isEqualToString:@"local"]) {
                self.shareBtn.selected = NO;
                //移除屏幕显示的分享的内容视图
                [self.shareView removeFromSuperview];
                [self.vcrtc shareToRemoteDisconnect];
                self.shareView = nil;
                self.shareImages = nil;
                self.shareModel = nil;
            } else if ([self.shareModel.shareType isEqualToString:@"remote"]) {
                //远端结束分享
                self.shareView = nil;
                self.shareModel = nil;
            } else if ([self.shareModel.shareType isEqualToString:@"local_remote"]) {
                // 抢远端的流 如果远端在分享 从远端抢流
            }
            //更新屏幕显示的视频
            [self layoutFarEndView:self.vcrtc.layoutParticipants];
        }
        
    } else {
        //本端屏幕共享结束
        if ([self.shareModel.shareType isEqualToString:@"localScreenShare"] && self.shareModel.isSharing && self.shareBtn.selected) {
            if ([[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"stop"] || [[userDefaults objectForKey:kScreenRecordState] isEqualToString:@"applaunch"]) {
                //更新状态 屏幕共享结束
                [userDefaults setObject:@"stop" forKey:kScreenRecordState];
                //分享按钮非选中状态
                self.shareBtn.selected = NO;
                //屏幕共享状态视图隐藏
                self.screenRecordStateImg.hidden = YES;
                //分享model数据为空
                self.shareModel = nil;
                //更新屏幕显示的视频
                [self layoutFarEndView:self.vcrtc.layoutParticipants] ;
            }
        } else {
            //远端图片分享结束
            if (![self.shareModel.shareType isEqualToString:@"local"]) {
                //移除屏幕显示的分享的内容视图
                [self.shareView removeFromSuperview];
                self.shareView = nil;
                self.shareImages = nil;
                self.shareModel = nil;
                //更新屏幕显示的视频
                [self layoutFarEndView:self.vcrtc.layoutParticipants] ;
            }
        }
        
    }
    
}

/** 远端视频布局 */
//isPrivateCloud 为YES是以流的形式共享屏幕或图片 isPrivateCloud 为NO是以图片的形式共享屏幕或图片
- (void)layoutFarEndView: (NSArray <NSString *>*)participants  {
    
    if (participants == nil || participants.count == 0) {
        [self clearAllView];
        //只有本地视图
        [self createBigView];
        if (!self.isClosePicterInPicter) {
            [self createSmallView];
        }
        
    } else {
        //是否是指定自己在大屏幕
        BOOL isStickLocal = [self.vcrtc.uuid isEqualToString:self.stickUUID];
        if (self.isPrivateCloud) {
            //是否人的共享图片或屏幕
            BOOL isPresentation = NO;
            for (NSString *uuid in participants) {
                if ([uuid rangeOfString:@"-presentation"].length) {
                    isPresentation = YES ;
                }
            }
            
            NSMutableArray *participantsArray = [participants mutableCopy];
            if (!isPresentation) {
                if (![participantsArray containsObject:self.vcrtc.uuid]) {
                    if (isStickLocal) {
                        if (participantsArray.count <= 1) {
                            [participantsArray addObject:self.vcrtc.uuid];
                        } else {
                            //把自己放在小视频的第一位
                            [participantsArray insertObject:self.vcrtc.uuid atIndex:0];
                        }
                    } else {
                        if (participantsArray.count <= 1) {
                            [participantsArray addObject:self.vcrtc.uuid];
                        } else {
                            //把自己放在小视频的第一位
                            [participantsArray insertObject:self.vcrtc.uuid atIndex:1];
                        }
                    }
                    
                }
            }
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSString *uuid in participantsArray) {
                for (VideoViewModel *viewModel in self.farEndViewsArray) {
                    if ([uuid isEqualToString:self.vcrtc.uuid]) {
                        if (![tempArray containsObject:self.localViewModel]) {
                            [tempArray addObject:self.localViewModel];
                        }
                    } else {
                        if ([uuid isEqualToString:viewModel.uuid]) {
                            //判断数组是否已经添加过该条数据
                            if (![tempArray containsObject:viewModel]) {
                                [tempArray addObject:viewModel];
                                
                            }
                        }
                    }
                    
                }
            }
            self.farEndViewsArray = tempArray;
            [self clearAllView];
            //本端分享图片
            if ([self.shareModel.shareType isEqualToString:@"local"] && self.shareModel.isSharing && isPresentation == NO) {
                [self updatePresentSmallView];
            } else {
                [self createBigView];
                if (!self.isClosePicterInPicter) {
                    [self createSmallView];
                }
            }
            
            
        } else {
            //排序规则 根据是否有人发言 有发言放在大视频上面 根据participants返回的数据排序 我自己本地始终放在小视频第一个
            NSMutableArray *tempArray = [NSMutableArray array];
            //participants
            for (NSString *uuid in participants) {
                for (VideoViewModel *videoViewModel in self.farEndViewsArray) {
                    if ([uuid isEqualToString:videoViewModel.uuid] && ![uuid isEqualToString:self.vcrtc.uuid]) {
                        if (![tempArray containsObject:videoViewModel]) {
                            //不包含自己
                            [tempArray addObject:videoViewModel];
                        }
                    }
                }
            }
            
            for (VideoViewModel *model in self.farEndViewsArray) {
                if ([model.uuid isEqualToString:self.vcrtc.uuid]) {
                    
                    //添加自己,并且把位置放在小视频的第一位
                    if (![tempArray containsObject:model]) {
                        if (isStickLocal) {
//                            if (tempArray.count >= 2) {
                                [tempArray insertObject:model atIndex:0];
//                            } else {
//                                [tempArray addObject:model];
//                            }
                        } else {
                            if (tempArray.count >= 2) {
                                [tempArray insertObject:model atIndex:1];
                            } else {
                                [tempArray addObject:model];
                            }
                        }
                        
                    }
                }
            }
            
            self.farEndViewsArray = tempArray;
            [self clearAllView];
            if (self.shareModel.isSharing) {
                [self updatePresentSmallView];
            } else {
                [self createBigView];
                if (!self.isClosePicterInPicter) {
                    [self createSmallView];
                }
            }
        }
    }
}

- (void)clearAllView {
    for (UIView *view in self.othersView.subviews) {
        if ([view isKindOfClass:[SmallView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)createBigView {
    if (self.farEndViewsArray.count < 1) {
        return;
    }
    VideoViewModel *videoViewModel = [self.farEndViewsArray firstObject];
    SmallView *bigView = [SmallView loadSmallViewWithVideoView:videoViewModel.videoView isTurnOffTheCamera:NO withParticipant:videoViewModel.participant isBig:YES uuid:videoViewModel.uuid];
    bigView.frame = self.othersView.bounds;
    [self.othersView addSubview:bigView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = bigView.bounds;
    [bigView addSubview:button];

//    [button addGestureRecognizer:tapGesuture];
    [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(cancelLockScreenAction:) forControlEvents:UIControlEventTouchDownRepeat];
    button.tag = 500;
    UIView *lockView = [[UIView alloc]initWithFrame:CGRectMake(10, 65,115, 40)];
    lockView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    lockView.hidden = !(self.stickUUID.length>0);
    [lockView.layer setMasksToBounds:YES];
    [lockView.layer setCornerRadius:3];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 60, 15)];
    lable.text = @"主屏已锁定";
    lable.textColor = [UIColor whiteColor];
    lable.center = CGPointMake(lable.center.x,lockView.frame.size.height/2.0 );
    lable.font = [UIFont systemFontOfSize:11];
    [lockView addSubview:lable];
    
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lockBtn.frame = CGRectMake(lockView.frame.size.width - 47, 0, 40, 20);
    [lockBtn setTitle:@"解锁" forState:UIControlStateNormal];
    lockBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    lockBtn.center = CGPointMake(lockBtn.center.x,lockView.frame.size.height/2.0 );
    lockBtn.backgroundColor = [UIColor colorWithRed:14/255.0 green:140/255.0 blue:238/255.0 alpha:1];
    [lockBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lockBtn.layer setMasksToBounds:YES];
    [lockBtn.layer setCornerRadius:3];
    [lockBtn addTarget:self action:@selector(cancelLockScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [lockView addSubview:lockBtn];
    [bigView addSubview:lockView];
    
}

- (void)createSmallView {
    if (self.farEndViewsArray.count < 2) {
        return;
    }
    CGFloat viewWidth = (self.othersView.frame.size.width - 20)/5;
    CGFloat viewHeight = 72 ;
    for (NSInteger i = 1 ; i < self.farEndViewsArray.count; i++) {
        //获取会中显示昵称
        VideoViewModel *videoViewModel = self.farEndViewsArray[i];
        SmallView *smallView = [SmallView loadSmallViewWithVideoView:videoViewModel.videoView isTurnOffTheCamera:NO withParticipant:videoViewModel.participant isBig:NO uuid:videoViewModel.uuid];
        [self.othersView addSubview:smallView];
        smallView.frame = CGRectMake((i - 1) * viewWidth + 10, self.othersView.frame.size.height - viewHeight, viewWidth, viewHeight);
        /*
         双击锁定主屏：指定某个参会人在大屏上
         */
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = smallView.bounds;
        [smallView addSubview:button];
        [button addTarget:self action:@selector(lockScreenAction:) forControlEvents:UIControlEventTouchDownRepeat];
        button.tag = i + 500;
        
    }
}



#pragma mark - 按钮点击方法

- (IBAction)moreAction:(UIButton *)sender {
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:!self.isClosePicterInPicter ? @"关闭画中画":@"打开画中画" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.closePicterInPicter = !self.isClosePicterInPicter;
        [self layoutFarEndView:self.vcrtc.layoutParticipants];
           }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:pictureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

//指定特定参会人上大屏幕
- (void)lockScreenAction: (UIButton *)button {
     [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clickAction:) object:button];
    if (self.shareModel.isSharing) {
        return;
    }
    NSInteger i = button.tag - 500;
    VideoViewModel *videoViewModel = self.farEndViewsArray[i];
    
    if ([videoViewModel.uuid isEqualToString:self.vcrtc.uuid]) {
        [self cancelLockScreenAction:nil];
        self.stickUUID = videoViewModel.uuid;
        [self layoutFarEndView:self.vcrtc.layoutParticipants];
        
    } else {
        self.stickUUID = videoViewModel.uuid;
        [self.vcrtc stickParticipant:videoViewModel.uuid onStick:YES success:^(id  _Nonnull response) {
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

//取消
- (void)cancelLockScreenAction: (UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clickAction:) object:button];
    if (!self.stickUUID.length || self.shareModel.isSharing) {
        return;
    }

    if (![self.stickUUID isEqualToString:self.vcrtc.uuid]) {
        [self.vcrtc stickParticipant:self.stickUUID onStick:NO success:^(id  _Nonnull response) {
            self.stickUUID = @"";
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    } else {
        self.stickUUID = @"";
        [self layoutFarEndView:self.vcrtc.layoutParticipants];
    }
}

//退出会议
- (IBAction)exitMeetingAction:(UIButton *)sender {
    
    [self.vcrtc exitChannelSuccess:^(id  _Nonnull response) {
        NSLog(@"退出会议成功");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"退出会议失败");
    }];
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//会中质量统计
- (IBAction)showQualityStatisticsAction:(UIButton *)sender {
    self.table.hidden = NO;
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];//状态栏的显示隐藏
}



//麦克风关闭打开
- (IBAction)microphoneControlAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.vcrtc micEnable:!sender.selected];
}
//分享
- (IBAction)shareAction:(id)sender {
    if (self.shareBtn.selected) {
        //如果本端是图片分享
        if ([self.shareModel.shareType isEqualToString:@"local"]) {
            if (self.isPrivateCloud) {
                //终止图片流分享
                [self.vcrtc shareToStreamImageData:[NSData data]
                                              open:NO
                                            change:NO
                                           success:^(id  _Nonnull response) {}
                                           failure:^(NSError * _Nonnull error) {}];
            } else {
                //终止图片分享
                [self.vcrtc shareImageData:[NSData data]
                                      open:NO
                                    change:NO
                                   success:^(id  _Nonnull response) {}
                                   failure:^(NSError * _Nonnull error) {}];
                
            }
            [self.shareView removeFromSuperview];
            self.shareView = nil;
            self.shareImages = nil;
            self.shareModel = nil;
            self.shareBtn.selected = NO;
        } else if ([self.shareModel.shareType isEqualToString:@"localScreenShare"]) {
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:self.vcrtc.groupId ];
            [self.vcrtc stopRecordScreen];
            //更新状态 屏幕共享结束
            [userDefaults setObject:@"stop" forKey:kScreenRecordState];
            //分享按钮非选中状态
            self.shareBtn.selected = NO;
            //屏幕共享状态视图隐藏
            self.screenRecordStateImg.hidden = YES;
            //分享model数据为空
            self.shareModel = nil;
            //更新屏幕显示的视频
            [self layoutFarEndView:self.vcrtc.layoutParticipants] ;
        }
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self photoShareAction];
        }];
        
        UIAlertAction *screenAction = [UIAlertAction actionWithTitle:@"屏幕" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self screenRecordInfo];
            
        }];
        UIAlertAction *iCloudction = [UIAlertAction actionWithTitle:@"iCloud" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self loadDocument];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:photoAction];
        [alert addAction:screenAction];
        [alert addAction:iCloudction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//屏幕共享指引
- (void)screenRecordInfo {
    NotRecordedController *notRecordC = [[NotRecordedController alloc]init];
    notRecordC.videoUri = @[@"01FirstSet",@"02StartRecord"];
    [self presentViewController:notRecordC animated:NO completion:nil];
}

//iCloud
- (void)loadDocument {
    DocumentPickerViewController *documentPicker = [[DocumentPickerViewController alloc]initWithDocumentTypes:@[@"public.image",@"com.adobe.pdf"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

//分享图片
- (void)photoShareAction {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:6 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [self shareData:photos];
    }];
    [self presentViewController:imagePickerVc animated:true completion:nil];
    
}

- (void) shareData:(NSArray *)photos {
    self.shareImages = photos;
    self.photoType = YCPhotoSourceType_Image;
    [self loadPresentationView];
    [self submitSharingImage:[photos firstObject] change:NO];
}

- (void)submitSharingImage:(UIImage *)image change:(BOOL )myChange{
    NSData* data = UIImageJPEGRepresentation(image, 1);
    if (self.isPrivateCloud) {
        // self.isPrivateCloud 为YES时,回调方法不会调用
        [self.vcrtc shareToStreamImageData:data open:YES change:myChange success:^(id  _Nonnull response) {
            
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"分享失败：%@ -- ",error);
            if(self.shareBtn.selected == NO) return ;
            self.shareBtn.selected = NO ;
            self.shareModel.isSharing = NO ;
        }];
        if (!myChange) {
            //更新shareModel的相关状态
            //local_remote 抢远端的流 如果远端在分享 从远端抢流
            self.shareModel.shareType = [ self.shareModel.shareType isEqualToString:@"none"] ? @"local" : @"local_remote";
            self.shareModel.isSharing = YES;
            self.shareModel.uuid = self.vcrtc.uuid;
            self.shareBtn.selected = YES ;
        }
        
    } else {
        [self.vcrtc shareImageData:data open:YES change: myChange success:^(id  _Nonnull response) {
            NSLog(@"分享成功：%@ -- ",response);
            //更新shareModel的相关状态
            self.shareModel.shareType = @"local";
            self.shareModel.isSharing = YES;
            self.shareModel.uuid = self.vcrtc.uuid;
            self.shareBtn.selected = YES ;
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"分享失败：%@ -- ",error);
            if(self.shareBtn.selected == NO) return ;
            self.shareBtn.selected = NO ;
            self.shareModel.isSharing = NO ;
        }];
    }
    
}


//加载显示图片分享的View
- (void)loadPresentationView {
    dispatch_async(dispatch_get_main_queue(), ^{
        //点击分享视图显示或隐藏topView和bottomView
        UITapGestureRecognizer *tagSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAction:)];
        tagSingle.numberOfTapsRequired = 1 ;
        tagSingle.numberOfTouchesRequired = 1;
        [self.shareView addGestureRecognizer:tagSingle];
        self.shareView.userInteractionEnabled = YES ;
        [self.view insertSubview:self.shareView atIndex:3];
        [self.shareView loadShowImagesOrURLs:self.shareImages PhotoSourceType:self.photoType];
        //分享图片界面放置一个小视频 (根据自己的需求)
        [self updatePresentSmallView];
    });
}

//分享图片时的小视频
- (void)updatePresentSmallView {
    if (!self.farEndViewsArray.count) {
        return ;
    }
    if (self.shareModel.isSharing) {
        VideoViewModel *model ;
        if (self.farEndViewsArray.count == 0) {
            return ;
        } else if (self.farEndViewsArray.count == 1) {
            model = [self.farEndViewsArray firstObject] ;
        } else if (self.farEndViewsArray.count > 1) {
            model = self.farEndViewsArray[1];
        }
        //查看当前这个视图上是否有小视频 如果有只是更改小视频的VCVideoView 如果没有再新建 (防止重复创建改视图)
        BOOL isContainSmallView = NO;
        for (UIView *view in self.shareView.subviews) {
            if ([view isKindOfClass:[SmallView class]]) {
                SmallView *smallView = (SmallView *)view;
                smallView.videoView = model.videoView;
                smallView.uuid = model.uuid;
                isContainSmallView = YES;
                return;
            }
        }
        if (!isContainSmallView) {
            SmallView *samllView = [SmallView loadSmallViewWithVideoView:model.videoView isTurnOffTheCamera:NO withParticipant:model.participant isBig:NO uuid:model.uuid];
            CGFloat viewWidth = (self.othersView.frame.size.width - 20)/5;
            //72 小视频的高度 viewWidth小视频的高度
            samllView.frame = CGRectMake(10, self.shareView.frame.size.height - 72, viewWidth, 72);
            [self.shareView addSubview:samllView];
        }
    }
}



//切换摄像头
- (IBAction)switchCameraAction:(id)sender {
    [self.vcrtc switchCamera];
}

//屏幕点击
- (IBAction)clickAction:(UIButton *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.topView.hidden = !self.topView.hidden;
        self.bottomView.hidden = !self.bottomView.hidden;
        [self setNeedsStatusBarAppearanceUpdate];
    });
}


//开启关闭摄像头
- (IBAction)cameraHandleAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    //YES开启摄像头 NO关闭摄像头
    [self.vcrtc videoEnable:!sender.selected];
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

//setNeedsStatusBarAppearanceUpdate 调用这个方法
- (BOOL )prefersStatusBarHidden {
    return self.topView.hidden ;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}



#pragma mark - tableViewDelegate & datasoruce

/** 质量统计数据处理 */
- (void)statisticsHandle:(NSArray<VCMediaStat *> *)mediaStats {
    self.statisticsArray = [NSMutableArray array];
    [self.statisticsArray addObject:@[@"",@"通道名称",@"编码格式",@"分辨率",@"帧率",@"码率",@"抖动",@"丢包率"]];
    
    for (VCMediaStat *stat in mediaStats) {
        //        if ([stat.direction isEqualToString:@"recv"] && [stat.mediaType isEqualToString:@"video"]&& [stat.uuid isEqualToString:self.vcrtc.uuid]) {
        //            continue;
        //        }
        NSMutableArray *tempArray = [NSMutableArray array];
        NSString *display = @"";
        if ([self.vcrtc.rosterList.allKeys containsObject:stat.uuid]) {
            Participant *p = self.vcrtc.rosterList[stat.uuid];
            display = p.displayName ;
        }
        [tempArray addObject:([stat.direction isEqualToString:@"send"] ? @"本端" : ( display.length && stat.uuid != self.vcrtc.uuid ) ? display : @"远端")] ;
        [tempArray addObject:[NSString stringWithFormat:@"%@%@",([stat.mediaType isEqualToString:@"audio"] ? @"音频" : @"视频" ),([stat.direction isEqualToString:@"send"] ? @"发送" : @"接收")]];
        [tempArray addObject:stat.codec];
        [tempArray addObject:stat.resolution ? stat.resolution : @"--" ];
        [tempArray addObject:stat.frameRate ? [NSString stringWithFormat:@"%ld",(long)stat.frameRate] : @"--"];
        [tempArray addObject:[NSString stringWithFormat:@"%ld",(long)stat.bitrate]];
        [tempArray addObject:[NSString stringWithFormat:@"%.0fms",stat.jitter]];
        [tempArray addObject:[NSString stringWithFormat:@"%.1f%%",stat.percentageLost]];
        [self.statisticsArray addObject:tempArray];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 95 ;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ConferenceHeaderView *headerView = [[ConferenceHeaderView alloc]init];
    headerView.frame = CGRectMake(0, 0, self.table.frame.size.width, 95);
    headerView.titleArray = [self.statisticsArray firstObject];
    __weak typeof (self) weakSelf = self;
    headerView.block = ^{
        [weakSelf closeNetworkingView];
    };
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
    
}

- (void)closeNetworkingView {
    self.table.hidden = YES ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.statisticsArray.count - 1 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConferenceVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConferenceVCCell"];
    cell.tableViewWidth = self.table.frame.size.width;
    cell.titleArray = self.statisticsArray[indexPath.row + 1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40 ;
}

#pragma mark - VCPresentionViewDelegate(分享图片, 远端屏幕共享)

//多张图片时切换图片
- (void)VCPresentionView:(VCPresentionView *)view changePage:(NSInteger )page  {
    self.photoType = YCPhotoSourceType_Image ;
    [self submitSharingImage:self.shareImages[page] change:YES];
}

//图片缩放
- (void)VCPresentionView:(VCPresentionView *)view zoomEndImage:(UIImage *)image {
    [self submitSharingImage:image change:YES];
}
//图片加载失败
- (void)VCPresentionView:(VCPresentionView *)view loadImageUrlFaild:(NSString *)urlStr PhotoSourceType:(YCPhotoSourceType)sourceType {
    if ([urlStr isEqualToString:self.vcrtc.shareImageURL]) {
        NSLog(@"加载Image URl %@ faild ", urlStr);
    } else {
        NSLog(@"加载Image URl %@ reload ", self.vcrtc.shareImageURL);
        [view loadShowImagesOrURLs:@[self.vcrtc.shareImageURL] PhotoSourceType:sourceType];
    }
}
#pragma mark - UIDocumentPickerDelegate iCloud分享文件
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc]init];
    __block NSError *error ;
    [coordinator coordinateReadingItemAtURL:url options:NSFileCoordinatorReadingResolvesSymbolicLink error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        NSString *fileType = [[[newURL lastPathComponent] componentsSeparatedByString:@"."]lastObject];
        NSArray *arr ;
        if ([[fileType lowercaseString] isEqualToString:@"pdf"]) {
            arr = [PDFHandle extractJPGsFromPDFWithPath:newURL.absoluteString];
        } else {
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            UIImage *image = [UIImage imageWithData:data];
            arr = @[image];
        }
        [self shareData:arr];
    }];
    [url stopAccessingSecurityScopedResource];
}


@end
