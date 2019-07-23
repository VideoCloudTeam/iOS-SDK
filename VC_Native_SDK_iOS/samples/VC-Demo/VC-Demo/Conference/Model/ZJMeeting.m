//
//  ZJMeeting.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "ZJMeeting.h"
#import "VCRTC.h"
#import "VCConferenceViewController.h"
#import "VCUserInfo.h"
#import "VCPublicModel.h"
#import "IncomingViewController.h"
#import "ZJAPPEngine.h"

#define APPENGINE ((ZJAPPEngine *)[[UIApplication sharedApplication] delegate])

@interface ZJMeeting ()<VCRtcModuleDelegate>

@property (nonatomic, strong) VCRtcModule *vcrtc;
@property (nonatomic, strong) VCUserInfo *userInfo ;
@property (nonatomic, strong) NSString *oemid ;


@end

static ZJMeeting *meeting ;

@implementation ZJMeeting

+ (instancetype)ZJMeetingShareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        meeting = [[ZJMeeting alloc]init] ;
    });
    return meeting ;
}

- (void)initSDKWithCompanyID:(NSString *)companyid {
    self.oemid = companyid ;
}

- (void)connectServer:(NSString *)server andPort:(NSString *)port {
    self.vcrtc = [VCRtcModule sharedInstance] ;
    self.vcrtc.apiServer = server ;
    [VCPublicModel shareModel].apiServer = server ;
}

- (void)enterMeetingSeverID:(NSString *)severid
              andMeetingNum:(NSString *)meetingnum
              andMeetingPwd:(NSString *)mpwd
               andBandwidth:(int )bw
                andNickName:(NSString *)nickname   {
    if (!self.vcrtc) {
        NSLog(@"请先设置Server");
        return ;
    }
    
    if (!self.vcrtc.apiServer) {
        NSLog(@"请先设置Server");
        return ;
    }
    
    self.vcrtc.delegate = self ;

    /* 请联系管理管理员分配账号 */
    self.vcrtc.bandwidth = 1024 ;
    [self.vcrtc configConnectType:VCConnectTypeMeeting];
    [self.vcrtc configVideoProfile:VCVideoProfile720P];
    [self.vcrtc configMultistream:YES];
    self.vcrtc.forceOrientation = UIDeviceOrientationLandscapeLeft ;
    /* 构建专属云环境时，使用 */
    //self.vcrtc.oemId = @"default";
    [self.vcrtc configPrivateCloudPlatform:YES];
    /* 构建屏幕录制功能时，使用 */
    //self.vcrtc.groupId = @"group.xxx";
    /* 请联系管理管理员分配会议地址 */
    [self.vcrtc connectChannel:meetingnum
                      password:mpwd
                          name:nickname
                       success:^(id _Nonnull re) {
                           [self didAddFacebookChannel:meetingnum conferenceInfo:re shareUrl:@{@"sipkey" : meetingnum , @"pwd" : mpwd } name:nickname] ;
                       } failure:^(NSError * _Nonnull er) {
                           NSLog(@"--%@",er);
                       }];
    
}

- (void)userName:(NSString *)username
 andUserPassword:(NSString *)upwd
     andPhoneNum:(NSString *)phonenum
     andNickName:(NSString *)name {
    [self loginUserName:username withPassword:upwd] ;
}

- (void)longPolling:(NSString *)sessionId {
    [ViaNetworkRequestV3API getChangesnApiServer:self.vcrtc.apiServer andSesstion:sessionId success:^(id  _Nonnull object) {
        NSArray *arrays = object;
        if (arrays.count) {
            if ([arrays[0][@"cmdid"] isEqualToString:@"webrtc_terminal_incoming"]) {
                [self webrtcTerminalIncoming:arrays[0][@"results"]] ;
            }
        }
        [self longPolling:sessionId];
    } failure:^(NSInteger code, NSString * _Nonnull message) {
        
    }];
}

- (void)notificationReceive:(NSNotification *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    
    if (!self.vcrtc) {
        NSLog(@"请先设置Server");
        return ;
    }
    
    if (!self.vcrtc.apiServer) {
        NSLog(@"请先设置Server");
        return ;
    }
    
    self.vcrtc.delegate = self ;
    
    /* 请联系管理管理员分配账号 */
    self.vcrtc.bandwidth = 1024 ;
    [self.vcrtc configConnectType:VCConnectTypeMeeting];
    [self.vcrtc configVideoProfile:VCVideoProfile720P];
    [self.vcrtc configMultistream:YES];
    self.vcrtc.forceOrientation = UIDeviceOrientationLandscapeLeft ;
    /* 构建专属云环境时，使用 */
    //self.vcrtc.oemId = @"default";
    [self.vcrtc configPrivateCloudPlatform:YES];
    /* 构建屏幕录制功能时，使用 */
    //self.vcrtc.groupId = @"group.xxx";
    /* 请联系管理管理员分配会议地址 */
    
    NSDictionary *incomingInfo = sender.object ;
    
    [self.vcrtc configPTPOneTimeToken:incomingInfo[@"conference_alias"] andBsskey:incomingInfo[@"bsskey"] andStamp:incomingInfo[@"time"] owner:@""];
    
    [self.vcrtc connectChannel:incomingInfo[@"conference_alias"]
                      password:@""
                          name:self.userInfo.trueName
                       success:^(id _Nonnull re) {
                           [self didAddFacebookChannel:incomingInfo[@"conference_alias"] conferenceInfo:re shareUrl:@{@"sipkey" : incomingInfo[@"conference_alias"] , @"pwd" : @"" } name:self.userInfo.trueName] ;
                       } failure:^(NSError * _Nonnull er) {
                           NSLog(@"--%@",er);
                       }];
}

- (void)notificationRefused:(NSNotification *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}

- (void)webrtcTerminalIncoming:(NSDictionary *)incomingInfo {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceive:)
                                                 name:@"notificationReceive"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationRefused:)
                                                 name:@"notificationRefused"
                                               object:nil];
    
    IncomingViewController *incomingVc = [[IncomingViewController alloc] init];
    incomingVc.incomingInfo = incomingInfo ;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:incomingVc animated:YES completion:nil];
}

- (void)loginUserName:(NSString *)userId withPassword:(NSString *)pwd {
    NSString *passwird = [self.oemid isEqualToString:@"zhongtie"] ? [NSString stringWithFormat:@"%@_%@",@"zhongtie",userId] : pwd;
    [ViaNetworkRequestV3API loginApiServer:self.vcrtc.apiServer withUserName:userId password:passwird  success:^(id  _Nonnull object) {
        self.userInfo = [VCUserInfo yy_modelWithJSON:object[@"results"] ] ;
        if ([object[@"code"] intValue]== 200) {
            [self longPolling:self.userInfo.session_id];
            
            [APPENGINE.networkManager setSessionId:self.userInfo.session_id andKey:@"sessionId"] ;

            [self obtainRoom:self.userInfo.account];
            
            if ([_delegate respondsToSelector:@selector(registerOnRemotreResponseLister:)]) {
                [_delegate registerOnRemotreResponseLister:[NSNumber numberWithInt:ZJJoinMeetingLoginSuss]] ;
            }
        }
        
    } failure:^(NSInteger code, NSString * _Nonnull message) {
        if ([_delegate respondsToSelector:@selector(registerOnRemotreResponseLister:)]) {
            [_delegate registerOnRemotreResponseLister:[NSNumber numberWithInt:ZJJoinMeetingLoginFailure]] ;
        }
    }];
}

- (void)obtainRoom:(NSString *)account {

    [NetworkRequstAPI cloudMeeting:account success:^(id  _Nonnull object) {
        if ([object[@"code"] intValue] == 200) {
            if ([_delegate respondsToSelector:@selector(onRoomInfoCallBack:)]) {
                [_delegate onRoomInfoCallBack:object[@"results"][0]] ;
            }
        }
        
    } failure:^(NSInteger code, NSString * _Nonnull message) {
        
    }];
}

- (void)didAddFacebookChannel:(NSString *)channel
               conferenceInfo:(id) info
                     shareUrl:(NSDictionary *)dicInfo
                         name:(NSString *)name {
    VCConferenceViewController *confVc = [[VCConferenceViewController alloc]init];
    confVc.channel = channel ;
    confVc.isSupportLive = [VCRtcModule sharedInstance].isSupportLive;
    confVc.isSupportRecord = [VCRtcModule sharedInstance].isSupportRecord;
    confVc.selectMute = NO ;
    confVc.shareUrl = [dicInfo copy];
    if ([_delegate respondsToSelector:@selector(onMeetingVC:)]) {
        [_delegate onMeetingVC:confVc];
    }
}



@end
