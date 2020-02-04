//
//  LoginViewController.m
//  iOSDemo
//
//  Created by 李志朋 on 2019/12/4.
//  Copyright © 2019 mac. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<VCRtcModuleDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *serverTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)login:(id)sender {
    VCRtcModule *vcrtc = [VCRtcModule sharedInstance];
    vcrtc.apiServer = self.serverTF.text ;
    vcrtc.delegate = self;

    [vcrtc loginWithAccount:self.accountTF.text password:self.passwordTF.text success:^(id  _Nonnull response) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }] ;
}
- (IBAction)logout:(id)sender {
    VCRtcModule *vcrtc = [VCRtcModule sharedInstance];
    vcrtc.apiServer = self.serverTF.text ;
    vcrtc.delegate = self;
    [vcrtc logoutAccountSuccess:^(id  _Nonnull response) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }] ;
}

- (void)VCRtc:(VCRtcModule *)module didIncomingCallInfo:(NSDictionary *)incomingInfo {
    NSLog(@"接收到被叫信息 ： %@", incomingInfo) ;
    [self connectIncommingCall:incomingInfo] ;
}

- (void)connectIncommingCall:(NSDictionary *)incomingInfo {
    //初始化
    VCRtcModule *vcrtc = [VCRtcModule sharedInstance];
    //配置服务器域名
    vcrtc.apiServer = self.serverTF.text ;
    //遵循 VCRtcModuleDelegate方法
    vcrtc.delegate = self;
    vcrtc.groupId = kGroupId;
    //入会类型配置 点对点
    [vcrtc configConnectType:VCConnectTypeMeeting];
    //入会音视频质量配置
    [vcrtc configVideoProfile:VCVideoProfile360P];
    //入会接收流的方式配置
    [vcrtc configMultistream:true];
    [vcrtc configPrivateCloudPlatform:YES];
    [vcrtc configPTPOneTimeToken:incomingInfo[@"token"] andBsskey:incomingInfo[@"bsskey"] andStamp:incomingInfo[@"time"] owner:@""] ;
    //用户账号配置(用户登录需配置,未登录不需要)
//    [vcrtc configLoginAccount:@"maxx@51vmr.cn"];
    //配置音视频 channel: 用户地址 password: 参会密码 name: 会中显示名称 xiaobeioldone@zijingcloud.com
    [vcrtc connectChannel:incomingInfo[@"conference_alias"] password:@"" name:@"马晓霞" success:^(id _Nonnull response) {
        //记录此时会议状态
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
        [userDefault setObject:@"inmeeting" forKey:kScreenRecordMeetingState];
        
    } failure:^(NSError * _Nonnull error) {
        NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
        [userDefault setObject:@"outmeeting" forKey:kScreenRecordMeetingState];
    }];
    vcrtc.forceOrientation = UIDeviceOrientationLandscapeLeft;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
