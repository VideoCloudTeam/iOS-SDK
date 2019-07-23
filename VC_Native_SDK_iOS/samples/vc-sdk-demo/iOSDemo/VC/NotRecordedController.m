//
//  ZJNotRecordedController.m
//  ZjVideo
//
//  Created by 李志朋 on 2018/3/16.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "NotRecordedController.h"
#import <AVKit/AVKit.h>
//#import "UIView+Frame.h"

#define SafeTophieght (SCREEN_HEIGHT == 812.0 ? 24 : 0)

@interface NotRecordedController ()<UIScrollViewDelegate>

@property (strong, nonatomic)AVPlayer *alertPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *alertitem;//播放单元
@property (strong, nonatomic)AVPlayerLayer *alertplayerLayer;//播放界面（layer）
@property (strong, nonatomic)AVPlayer *showPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *showitem;//播放单元
@property (strong, nonatomic)AVPlayerLayer *showplayerLayer;//播放界面（layer）

@property(nonatomic,strong)UIScrollView *myScrollView;
@property(nonatomic,strong)UIView *alertView;
@property(nonatomic,strong)UIView *showView;
@property(nonatomic,strong)NSTimer *timerAlert;
@property(nonatomic,strong)NSTimer *timerShow;
@end

@implementation NotRecordedController

- (UIScrollView *)myScrollView{
  if (!_myScrollView) {
    _myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _myScrollView.scrollEnabled = YES;
    _myScrollView.pagingEnabled = YES;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.bounces = NO;
    _myScrollView.delegate = self;
  }
  return _myScrollView;
}

- (UIView *)alertView {
  if (!_alertView) {
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)];
    _alertView.backgroundColor = [UIColor whiteColor];
    NSAttributedString *text1 = [self jointAttributedStringWithItems:@[[self normorContent:@"1.打开"],[self importContent:@"设置"]]];
    NSAttributedString *text2 = [self jointAttributedStringWithItems:@[[self normorContent:@"2.选择"],[self importContent:@"控制中心"]]];
    NSAttributedString *text3 = [self jointAttributedStringWithItems:@[[self normorContent:@"3.选择"],[self importContent:@"自定控制"]]];
    NSAttributedString *text4 = [self jointAttributedStringWithItems:@[[self normorContent:@"4.点击"],[self imageContent:[UIImage imageNamed:@"icon_screen_add"]],[self normorContent:@"  添加"],[self importContent:@"屏幕录制"]]];
    [_alertView addSubview:[self addShowTextView:@"系统设置" andText1:text1 andText2:text2 andText3:text3 andText4:text4 showNext:YES]];
      
      
    NSString *loc = [[NSBundle mainBundle] pathForResource:self.videoUri[0] ofType:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:loc];
    self.alertitem = [AVPlayerItem playerItemWithURL:url];
    self.alertPlayer = [AVPlayer playerWithPlayerItem:self.alertitem];

    self.alertplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.alertPlayer];
    float height = SCREEN_HEIGHT/16.0 * 15;
    float x = ( SCREEN_WIDTH - height * 368/ 640 ) / 3.0 * 2 ;
    self.alertplayerLayer.frame = CGRectMake(x, SCREEN_HEIGHT - height, height * 368/ 640 ,height);

    [_alertView.layer addSublayer:self.alertplayerLayer];
    [self.alertPlayer play];
      if (@available(iOS 10.0, *)) {
          self.timerAlert = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
              if (CMTimeGetSeconds(self.alertPlayer.currentTime) ==  CMTimeGetSeconds(self.alertitem.duration)) {
                  [self playbackFinished];
              }
          }];
      } else {
          // Fallback on earlier versions
      }
    [[NSRunLoop currentRunLoop] addTimer:self.timerAlert forMode:NSRunLoopCommonModes];
  }

  return _alertView;
}

- (void)playbackFinished{
   [self.alertPlayer seekToTime:CMTimeMake(0, 1)];
   NSLog(@"播放完成了01");
   [self.alertPlayer play];
}

- (void)playShowFinished{
  [self.showPlayer seekToTime:CMTimeMake(0, 1)];
  NSLog(@"播放完成了02");
  [self.showPlayer play];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSArray *)videoUri{
  if (!_videoUri) {
    _videoUri = [NSArray array];
  }
  return _videoUri;
}


-(UIView *)showView{
  if(!_showView) {
    _showView = [[UIView alloc]initWithFrame:CGRectMake( SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

    _showView.backgroundColor = [UIColor whiteColor];
    NSAttributedString *text1 = [self jointAttributedStringWithItems:@[[self normorContent:@"1.从屏幕底部上滑打开控制中心"]]];
    NSAttributedString *text2 = [self jointAttributedStringWithItems:@[[self normorContent:@"2.用力按压录制按钮"],[self imageContent:[UIImage imageNamed:@"icon_screen_anniu"]]]];
    NSAttributedString *text3 = [self jointAttributedStringWithItems:@[[self normorContent:[NSString stringWithFormat:@"%@%@%@", @"3.在列表找到",app_Name,NSLocalizedString(@"zjxuzhong", nil)]]]];
    NSAttributedString *text4 = [self jointAttributedStringWithItems:@[[self normorContent:@"4.点击开始直播"]]];
    
    [_showView addSubview:[self addShowTextView:@"开始共享" andText1:text1 andText2:text2 andText3:text3 andText4:text4 showNext:NO]];
    
    NSString *loc = [[NSBundle mainBundle] pathForResource:self.videoUri[1] ofType:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:loc];
    self.showitem = [AVPlayerItem playerItemWithURL:url];
    self.showPlayer = [AVPlayer playerWithPlayerItem:self.showitem];

    self.showplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.showPlayer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.showplayerLayer.bounds   byRoundingCorners:UIRectCornerTopRight |    UIRectCornerTopLeft    cornerRadii:CGSizeMake(74, 74)];
    self.showplayerLayer.mask.shadowPath = maskPath.CGPath;

    float height = SCREEN_HEIGHT/16.0 * 15 ;
    float x = ( SCREEN_WIDTH - height * 368/ 640 ) / 3.0 * 2  ;
    self.showplayerLayer.frame = CGRectMake(x, SCREEN_HEIGHT - height, height * 368/ 640 ,height);

    [_showView.layer addSublayer:self.showplayerLayer];
    [self.showPlayer play];
      if (@available(iOS 10.0, *)) {
          self.timerShow = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
              if (CMTimeGetSeconds(self.showPlayer.currentTime) ==  CMTimeGetSeconds(self.showitem.duration)) {
                  [self playShowFinished];
              }
          }];
      } else {
          // Fallback on earlier versions
      }
    if (@available(iOS 10.0, *)) {
        [[NSRunLoop currentRunLoop] addTimer:self.timerShow forMode:NSRunLoopCommonModes];
    }
  }
  return _showView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.myScrollView];
  
  float x = 0 ;
  for (UIView * view in @[self.alertView,self.showView]) {
      [self.myScrollView addSubview:view];
      x=x+SCREEN_WIDTH;
  }

  [self.myScrollView setContentSize:CGSizeMake(x, SCREEN_HEIGHT)];
  [self.myScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (UIView *)addShowTextView:(NSString *)title andText1:(NSAttributedString *)sub1 andText2:(NSAttributedString *)sub2 andText3:(NSAttributedString *)sub3 andText4:(NSAttributedString *)sub4 showNext:(BOOL)show{
    CGFloat screenWidth = SCREEN_WIDTH - 40;
    CGFloat screenHeight = SCREEN_HEIGHT - 40 ;
    
    CGFloat x = 100 ;
    CGFloat y = 100;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 20, screenWidth, screenHeight)];
    view.center = CGPointMake(view.center.x, SCREEN_HEIGHT / 2.0);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 10, 40, 40);
    [btn setImage:[[UIImage imageNamed:@"icon_screen_close"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dissPlayController) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
  
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, screenWidth/3.0, 30)];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    UILabel *contentLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(x, titleLabel.frame.size.height + titleLabel.frame.origin.y + 15, screenWidth, 20)];
    contentLabel1.attributedText = sub1;
    contentLabel1.textAlignment = NSTextAlignmentLeft;
    UILabel *contentLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(x, contentLabel1.frame.size.height + contentLabel1.frame.origin.y + 10, screenWidth, 20)];
    contentLabel2.attributedText = sub2;
    contentLabel2.textAlignment = NSTextAlignmentLeft;
  
    UILabel *contentLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(x, contentLabel2.frame.size.height + contentLabel2.frame.origin.y + 10, screenWidth, 20)];
    contentLabel3.attributedText = sub3;
    contentLabel3.textAlignment = NSTextAlignmentLeft;
  
    UILabel *contentLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(x, contentLabel3.frame.size.height + contentLabel3.frame.origin.y + 10, screenWidth, 20)];
    contentLabel4.attributedText = sub4;
    contentLabel4.textAlignment = NSTextAlignmentLeft;
  
    UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth -50,contentLabel2.frame.origin.y, 15, 33)];
    rightImage.hidden = !show;
    rightImage.image = [[UIImage imageNamed:@"icon_screen_youhua"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [view addSubview:rightImage];
  
    [view addSubview:titleLabel];
    [view addSubview:contentLabel1];
    [view addSubview:contentLabel2];
    [view addSubview:contentLabel3];
    [view addSubview:contentLabel4];
    return view;
}

- (void)dissPlayController{
  [self.timerAlert invalidate];
  [self.timerShow invalidate];
  [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeToLayout" object:nil];
}

// 1. 由文本生成attributedString
- (NSAttributedString *)attributedStringWithText:(NSString *)text textColor:(UIColor *)color textFont:(UIFont *)font hasUnderlineStyle:(BOOL)hasUnderLineStyle lineSpacing:(float)line paragraphSpacing:(float)paragraph {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
//  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  NSRange range = NSMakeRange(0, text.length);
//  [paragraphStyle setLineSpacing:line];
//  [paragraphStyle setParagraphSpacing:paragraph];
//  [paragraphStyle setAlignment:NSTextAlignmentCenter];
//  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
  [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
  [attributedString addAttribute:NSFontAttributeName value:font range:range];
  
  if (hasUnderLineStyle) {
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
  }
  
  return attributedString;
}

// 2. 由图片生成attributedString
- (NSAttributedString *)attributedStringWithImage:(UIImage *)image imageBounds:(CGRect)bounds {
  NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
  textAttachment.image = image;
  textAttachment.bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
  NSAttributedString *attachmentAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
  
  return attachmentAttributedString;
}

// 3. 多个AttributedString拼接成一个resultAttributedString
- (NSAttributedString *)jointAttributedStringWithItems:(NSArray *)items {
  NSMutableAttributedString *resultAttributedString = [[NSMutableAttributedString alloc] init];
  
  for (int i = 0; i < items.count; i++) {
    if ([items[i] isKindOfClass:[NSAttributedString class]]) {
      [resultAttributedString appendAttributedString:items[i]];
    }
  }
  
  return resultAttributedString;
}

- (NSAttributedString *)normorContent:(NSString *)text{
  NSAttributedString *textAttachment = [self attributedStringWithText:text textColor:[UIColor blackColor] textFont:[UIFont systemFontOfSize:15] hasUnderlineStyle:NO lineSpacing:0 paragraphSpacing:0];
  return textAttachment;
}

-(NSAttributedString *)importContent:(NSString *)text{
  NSAttributedString *textAttachment = [self attributedStringWithText:text textColor:[UIColor blackColor] textFont:[UIFont boldSystemFontOfSize:15] hasUnderlineStyle:NO lineSpacing:0 paragraphSpacing:0];
  return textAttachment;
}

-(NSAttributedString *)imageContent:(UIImage *)image{
  NSAttributedString *textAttachment = [self attributedStringWithImage:image imageBounds:CGRectMake(4, -4, 20, 20)];
  return textAttachment;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

//支持旋转
-(BOOL)shouldAutorotate{
  return YES;
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskLandscapeRight;
}

//一开始的方向  很重要
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
  return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
