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
