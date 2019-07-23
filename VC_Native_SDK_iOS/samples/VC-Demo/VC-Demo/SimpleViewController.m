//
//  SimpleViewController.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "SimpleViewController.h"
#import "VCRTC.h"

@interface SimpleViewController () <VCRtcModuleDelegate>

@property (nonatomic, strong) VCRtcModule *vcrtc;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) VCVideoView *localView;
@property (weak, nonatomic) IBOutlet UITextField *apiserver;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *display;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"快速集成" ;
    self.views = [NSMutableArray new];
    self.vcrtc = [VCRtcModule sharedInstance];
}

- (IBAction)joinMeeting:(id)sender {
    /* 请联系管理管理员分配服务器地址 */
    self.vcrtc.apiServer = self.apiserver.text ;
    self.vcrtc.delegate = self ;
    
    /* 请联系管理管理员分配账号 */
    [self.vcrtc configConnectType:VCConnectTypeMeeting];
    [self.vcrtc configVideoProfile:VCVideoProfile360P];
    [self.vcrtc configMultistream:YES];
    /* 构建专属云环境时，使用 */
    //self.vcrtc.oemId = @"default";
    [self.vcrtc configPrivateCloudPlatform:YES];
    /* 构建屏幕录制功能时，使用 */
    //self.vcrtc.groupId = @"group.xxx";
    /* 请联系管理管理员分配会议地址 */
    [self.vcrtc connectChannel:self.number.text
                      password:self.password.text
                          name:self.display.text
                       success:^(id _Nonnull re) {
        
    } failure:^(NSError * _Nonnull er) {
        NSLog(@"--%@",er);
    }];
}
- (IBAction)leaveMeeting:(id)sender {
    for(UIView *view in self.views){
            [view removeFromSuperview];
        }
    [self.views removeAllObjects];
    [self.localView removeFromSuperview];
    [self.vcrtc exitChannelSuccess:^(id o) {
        NSLog(@"[VCrtc] end session successful");
    } failure:^(NSError *error) {
        NSLog(@"[VCrtc] end session failure");
    }];
}

/* 添加远端视频 */
- (void)VCRtc:(VCRtcModule *)module didAddView:(VCVideoView *)view uuid:(NSString *)uuid {
    static int i = 0;
    i++;
    [self.videoView addSubview:view];
    [self.views addObject:view];
    [self relayoutViews];
}

/* 移除远端视频 */
- (void)VCRtc:(VCRtcModule *)module didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid {
    [view removeFromSuperview];
    [self.views removeObject:view];
    [self relayoutViews];
    NSLog(@"uuid %@ removed view=%@", uuid, view);
}

/* 添加本端视频 */
- (void)VCRtc:(VCRtcModule *)module didAddLocalView:(VCVideoView *)view{
    [view setFrame:CGRectMake(0, 0, self.videoView.bounds.size.width, self.videoView.bounds.size.height)];
    self.localView = view;
    self.localView.objectFit = VCVideoViewObjectFitCover;
    [self.videoView insertSubview:view atIndex:0];
}

- (void)relayoutViews{
    int i = 0;
    
    NSLog(@"[layout]: begin");
    for(VCVideoView *view in self.views){
        CGRect p = CGRectMake(5, 5 +  90 * i, 160, 90);
        view.objectFit = VCVideoViewObjectFitCover;
        [view setFrame:p];
        NSLog(@"[layout]: view %d: %@", i, NSStringFromCGRect(p));
        i++;
    }
    NSLog(@"[layout]: end");
}


- (void)VCRtc:(VCRtcModule *)module didAddParticipant:(Participant *)participant;{
    //   NSLog(@"participant %@", participant);
}
- (void)VCRtc:(VCRtcModule *)module didUpdateParticipant:(Participant *)participant;{
    //    NSLog(@"participant %@", participant);
    
}
- (void)VCRtc:(VCRtcModule *)module didRemoveParticipant:(Participant *)participant;{
    //    NSLog(@"participant %@", participant);
}

- (void)VCRtc:(VCRtcModule *)module didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats;{
    //    NSLog(@"[Statistics] %@", mediaStats);
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
