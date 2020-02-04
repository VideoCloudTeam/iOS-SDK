//
//  ViewController.m
//  iOSDemo
//
//  Created by mac on 2019/7/8.
//  Copyright © 2019 mac. All rights reserved.
//

#import "ViewController.h"
#import "ExampleVC.h"
#import "LoginViewController.h"
#import "ConferenceViewController.h"

@interface ViewController ()
/** 服务器地址 */
@property (weak, nonatomic) IBOutlet UITextField *severField;
/** 会议室号 */
@property (weak, nonatomic) IBOutlet UITextField *meetingNumField;
/** 参会密码 */
@property (weak, nonatomic) IBOutlet UITextField *joinPwdField;
//是否是多流
@property (weak, nonatomic) IBOutlet UISwitch *multistreamSwitch;
/** 是否是专属云 公有云才有多流和单流之分 专属云只有多流 */
@property (weak, nonatomic) IBOutlet UISwitch *privateCloudSwitch;
/** YES执行Demo NO功能齐全版本  */
@property (weak, nonatomic) IBOutlet UISwitch *versionSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.severField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"serverAddress"];
    self.meetingNumField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"meetingNumber"];
    self.joinPwdField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"joinPassword"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(loginAction:)];
    
}

- (void)loginAction:(UIBarButtonItem *) barButton {
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVc animated:YES] ;
}

- (IBAction)mutistreamAction:(UISwitch *)sender {
    
    
}

- (IBAction)privateCloudAction:(UISwitch *)sender {
    if (sender.on) {
        self.multistreamSwitch.on = sender.on;
    }
    
}


/*
 注意： 专属云 只有多流模式
 公有云 有多流模式和非多流模式
 
 */
- (IBAction)jumpAction:(UIButton *)sender {
    if (self.severField.text.length < 1) {
        NSLog(@"请输入服务器地址");
        return;
    }
    if (self.meetingNumField.text.length < 1) {
        NSLog(@"请输入会议室号");
        return;
    }
    [[NSUserDefaults standardUserDefaults]setObject:self.severField.text forKey:@"serverAddress"];
    [[NSUserDefaults standardUserDefaults]setObject:self.meetingNumField.text forKey:@"meetingNumber"];
    [[NSUserDefaults standardUserDefaults]setObject:self.joinPwdField.text forKey:@"joinPassword"];
    if (self.versionSwitch.on) {
        ExampleVC *vc = [ExampleVC new];
        vc.serverString = self.severField.text;
        vc.meetingNumString = self.meetingNumField.text;
        vc.passwordString = self.joinPwdField.text;
        vc.isMultistream = self.multistreamSwitch.on;
        vc.isPrivateCloud = self.privateCloudSwitch.on;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    } else {
        VCRtcModule *manager = [VCRtcModule sharedInstance];
        //配置服务器域名
        manager.apiServer = self.severField.text;
        manager.groupId = kGroupId;
        [manager configConnectType:VCConnectTypeMeeting];
        //入会音视频质量配置
        if (!self.privateCloudSwitch.on && !self.multistreamSwitch.on) {
            [manager configBandwidth:800];
            [manager configVideoProfile:VCVideoProfile360P];
        } else {
            [manager configBandwidth:1024];
            [manager configVideoProfile:VCVideoProfile540P];
        }
        //入会接收流的方式配置
        [manager configMultistream:self.multistreamSwitch.on];
        //是否是专属云
        [manager configPrivateCloudPlatform:self.privateCloudSwitch.on];
        //用户账号配置(用户登录需配置,未登录不需要)
        // [self.vcrtc configLoginAccount:@"填写登录的账号"];
        //配置音视频 channel: 用户地址 password: 参会密码 name: 会中显示名称 xiaobeioldone@zijingcloud.com
        [manager connectChannel:self.meetingNumField.text password:self.joinPwdField.text name:@"test_ios_demo" success:^(id _Nonnull response) {
            //记录此时会议状态
            NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
            [userDefault setObject:@"inmeeting" forKey:kScreenRecordMeetingState];
            
        } failure:^(NSError * _Nonnull error) {
            NSUserDefaults *userDefault = [[NSUserDefaults alloc]initWithSuiteName:kGroupId];
            [userDefault setObject:@"outmeeting" forKey:kScreenRecordMeetingState];
        }];
        manager.forceOrientation = UIDeviceOrientationLandscapeLeft;
        ConferenceViewController *vc = [ConferenceViewController new];
        vc.channel = self.meetingNumField.text;
        vc.isSupportLive = [VCRtcModule sharedInstance].isSupportLive;
        vc.isSupportRecord = [VCRtcModule sharedInstance].isSupportRecord;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.severField.isExclusiveTouch) {
        [self.severField resignFirstResponder] ;
    }
    
    if (!self.meetingNumField.isExclusiveTouch) {
        [self.meetingNumField resignFirstResponder] ;
    }
    
    if (!self.joinPwdField.isExclusiveTouch) {
        [self.joinPwdField resignFirstResponder] ;
    }
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
