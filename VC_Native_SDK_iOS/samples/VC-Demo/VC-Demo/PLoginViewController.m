//
//  PLoginViewController.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "PLoginViewController.h"
#import "ZJMeeting.h"

@interface PLoginViewController () <ZJMeetingDelegate>
@property (weak, nonatomic) IBOutlet UITextField *apiserver;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *status;

@property (nonatomic, strong) NSDictionary *roomInfo ;

@end

@implementation PLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录平台";
}

- (IBAction)login:(id)sender {
    ZJMeeting *meeting = [ZJMeeting ZJMeetingShareInstance] ;
    meeting.delegate = self ;
    [meeting connectServer:self.apiserver.text andPort:@"10001" ];
    [meeting userName:self.account.text andUserPassword:self.password.text andPhoneNum:@"" andNickName:@""];
}

- (void)registerOnRemotreResponseLister:(id)response {
    
    ZJJoinMeetingErrorType type = [response intValue];
    
    switch (type) {
        case ZJJoinMeetingLoginSuss :
            self.status.on = YES ;
            break;
            
        case ZJJoinMeetingSuss :
            break;
            
        case ZJJoinMeetingSeverConnetSuss :
            break;
            
        case ZJJoinMeetingSeverConnetfill:
            break;
        default:
            break;
    }
}

- (void)onMeetingVC:(UIViewController *)meetingVC {
    [self presentViewController:meetingVC animated:YES completion:nil];
}

- (void)onRoomInfoCallBack:(id)roomInfo {
    self.roomInfo = roomInfo ;
    NSLog(@"onRoomInfoCallBack - %@",self.roomInfo );
}

- (IBAction)joinMyRoom:(id)sender {
    ZJMeeting *meeting = [ZJMeeting ZJMeetingShareInstance] ;
    meeting.delegate = self ;
    [meeting connectServer:self.apiserver.text andPort:@"10001" ];
    [meeting enterMeetingSeverID:self.apiserver.text
                   andMeetingNum:self.roomInfo[@"alias"]
                   andMeetingPwd:self.roomInfo[@"hostPin"]
                    andBandwidth:1024
                     andNickName:@"ios_test"];
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
