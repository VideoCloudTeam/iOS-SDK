//
//  BaseInMeetingVC.m
//  linphone
//
//  Created by mac on 2019/9/11.
//

#import "BaseInMeetingVC.h"
#import "RTCHelper.h"
#import "ConferenceVCCell.h"
#import "ConferenceHeaderView.h"

@interface BaseInMeetingVC ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation BaseInMeetingVC
- (void)dealloc
{
    NSLog(@"dealloc%@", [self class]);
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (instancetype)init {
    if (self = [super initWithNibName:@"ConferenceViewController" bundle:nil]) {

    }
    return self ;
}

- (NSMutableArray *)streamOnwers {
    if (!_streamOnwers) {
        _streamOnwers = [NSMutableArray array] ;
    }
    return _streamOnwers ;
}



- (NSTimer *)hiddenTimer {
    if (!_hiddenTimer ) {
        _hiddenTimer = [NSTimer timerWithTimeInterval:6.0 block:^(NSTimer * _Nonnull timer) {
            [UIView animateWithDuration:0.3 animations:^{
                self.topView.alpha = 0 ;
                self.bottomView.alpha = 0;
                [self setNeedsStatusBarAppearanceUpdate];
                [self updatePresenterFrame];
                self.handCountToBtm.priority = UILayoutPriorityDefaultHigh;
            }];
        } repeats:NO];
    }
    return _hiddenTimer ;
}

- (void)updatePresenterFrame {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.netQuailtyTable registerClass:[ConferenceVCCell class] forCellReuseIdentifier:@"ConferenceVCCell"];
    self.headerView.titleArray = @[@"",@"通道名称",@"编码格式",@"分辨率",@"帧率",@"码率",@"抖动",@"丢包率"];
    __weak typeof (self) weakSelf = self;
    self.headerView.block = ^{
        [weakSelf closeNetworkingView];
    };
    [self loadTimer];
}

/**
 时间长短计时
 */
- (void)loadTimer {
    __block NSInteger i = 0 ;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSString *stringDate = @"00:00:00";
    NSDate *date = [dateFormatter dateFromString:stringDate];
    self.timeLengthTimer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
            NSDate *dateTime = [[NSDate alloc]initWithTimeInterval:i sinceDate:date];
            NSString *stringTime = [dateFormatter stringFromDate:dateTime];
            i++;
            self.timeLengthLab.text = stringTime ;
    } repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timeLengthTimer forMode:NSRunLoopCommonModes];
}

- (void)closeNetworkingView {
    self.netQuaityView.hidden = YES ;
}
- (void)reloadStats:(NSArray *)stats rosterList: (NSMutableDictionary<NSString *, Participant *>*)rosterList userSelfUUID: (NSString *)uuid userChannel: (UserChannel)userChannel {
    [MediaDataHandle  mediasSatisticsHandel:stats rosterList:rosterList userSelfUUID:uuid userChannel:userChannel block:^(NSMutableArray * _Nonnull array, MediaStatsLevel level) {
        self.networkArr = array;
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.netBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_sign_%ld",level]] forState:UIControlStateNormal];
            [self.netQuailtyTable reloadData];
        });
        
    }];
}


- (void)goSettingPermissions:(NSString *)title
                  andMessage:(NSString *)message
                     success:(void (^)(bool))success {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
            NSTimeInterval timeStr =  [[NSDate date] timeIntervalSince1970];
            
            NSDictionary *settings = @{ @"go_settings" : @(YES) , @"time" : @(timeStr) };
            
            [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"go_settings_defaults"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }]];
        [self presentViewController:alertC animated:NO completion:nil];
    });
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.networkArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConferenceVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConferenceVCCell"];
    cell.tableViewWidth = self.netQuailtyTable.frame.size.width;
    cell.titleArray = self.networkArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40 ;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
