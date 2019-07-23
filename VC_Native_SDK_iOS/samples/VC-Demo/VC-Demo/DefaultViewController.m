//
//  DefaultViewController.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "DefaultViewController.h"
#import "ZJMeeting.h"

@interface DefaultViewController ()<ZJMeetingDelegate>
@property (weak, nonatomic) IBOutlet UITextField *apiserver;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *display;

@end

@implementation DefaultViewController

- (void)viewDidLoad {
    self.title = @"默认界面" ;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)joinMeeting:(id)sender {
    ZJMeeting *meeting = [ZJMeeting ZJMeetingShareInstance] ;
    meeting.delegate = self ;
    [meeting connectServer:self.apiserver.text andPort:@"10001" ];
    [meeting enterMeetingSeverID:self.apiserver.text
                   andMeetingNum:self.number.text
                   andMeetingPwd:self.password.text
                    andBandwidth:1024
                     andNickName:self.display.text];
}

- (void)onMeetingVC:(UIViewController *)meetingVC {
    [self presentViewController:meetingVC animated:YES completion:nil];
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
