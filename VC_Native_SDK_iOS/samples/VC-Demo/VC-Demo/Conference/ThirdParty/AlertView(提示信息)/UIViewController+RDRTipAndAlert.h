//
//  UIViewController+RDRTipAndAlert.h
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDRErrorView.h"
#import "RDRSpinnerView.h"
#import "MBProgressHUD.h"

@interface UIViewController (RDRTipAndAlert)

@property (nonatomic, strong) RDRErrorView *rdrErrorView;
@property (nonatomic, strong) RDRSpinnerView *rdrActivityView;
@property (nonatomic, strong) MBProgressHUD *rdrHudView;

@property (nonatomic, assign) int role;
/**
 *  错误页面
 *
 *  @param aType 错误类型
 */
- (void)showErrorViewWithType:(kRDRErrorViewType)aType;

- (void)showErrorViewWithType:(kRDRErrorViewType)aType atYOffset:(CGFloat)yOffset;

- (void)showErrorViewOnView:(UIView *)aView
                   withType:(kRDRErrorViewType)aType;

/**
 *  错误页面
 *
 *  @param aView 错误页面父View
 *  @param aType 错误类型
 *  @param yOffset y偏移
 */
- (void)showErrorViewOnView:(UIView *)aView
                   withType:(kRDRErrorViewType)aType
                  atYOffset:(CGFloat)yOffset;

/**
 *  隐藏错误提示页面
 */
- (void)hideErrorView;

/**
 *  Loading， 小车摇晃加载
 */
//- (void)showRDRIndicatorView;
- (void)showRDRIndicatorViewWithTitle:(NSString *)title;
- (void)showRDRIndicatorViewAtYOffset:(CGFloat)yOffset withTitle:(NSString *)title;
- (void)showRDRIndicatorOnView:(UIView *)aView yOffset:(CGFloat)yOffset withTitle:(NSString *)title;

/**
 *  HUD Loading，HUD动画加载
 */
//- (void)showHudLoadingView;
- (void)showHudViewWithTitle:(NSString *)title;
- (void)showHudViewAtYOffset:(CGFloat)yOffset;
- (void)showHudViewWithTitle:(NSString *)title onView:(UIView *)aView yOffset:(CGFloat)yOffset;

/**
 *  公共使用加载动画
 */
- (void)showLoadingView:(NSString *)title;

/**
 *  隐藏加载动画
 */
- (void)hideHudAndIndicatorView;

/**
 *  弹出Toast提示， 约1.5秒后消失
 *
 *  @param message 提示信息
 */
- (void)showToastWithMessage:(NSString *)message;

+ (void)showToastWithmessage:(NSString *)msg;

/**
 *  弹出Toast提示 默认2s后消失 延时.6秒弹出
 *
 *  @param message 提示信息
 */
- (void)showToastWithMessageDelay:(NSString *)message;

/**
 *  弹出网络不给力Toast提示
 */
- (void)showToastOnNetworkError;

/**
 *  弹出UIAlertView的提示
 *
 *  @param title
 *  @param message
 */
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

@end
