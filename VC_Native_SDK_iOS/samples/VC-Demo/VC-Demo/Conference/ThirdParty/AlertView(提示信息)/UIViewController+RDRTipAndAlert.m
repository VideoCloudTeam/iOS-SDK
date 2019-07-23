//
//  UIViewController+RDRTipAndAlert.m
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+RDRTipAndAlert.h"
#import "BTMToast.h"

static char const * const kAssociatedRDRErrroView = "AssociatedRDRErrorView";
static char const * const kAssociatedRDRActivityView = "AssociatedRDRActivityView";
static char const * const kAssociatedRDRHudView = "AssociatedRDRHudView";


@implementation UIViewController (RDRTipAndAlert)

@dynamic role;
- (RDRErrorView *)rdrErrorView
{
    RDRErrorView *_erroView = objc_getAssociatedObject(self, &kAssociatedRDRErrroView);
    return _erroView;
}


- (void)setRdrErrorView:(RDRErrorView *)errorView
{
    objc_setAssociatedObject(self, &kAssociatedRDRErrroView, errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RDRSpinnerView *)rdrActivityView
{
    RDRSpinnerView *_erroView = objc_getAssociatedObject(self, &kAssociatedRDRActivityView);
    return _erroView;
}


- (void)setRdrActivityView:(RDRSpinnerView *)activityView
{
    objc_setAssociatedObject(self, &kAssociatedRDRActivityView, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)rdrHudView
{
    MBProgressHUD *_hud = objc_getAssociatedObject(self, &kAssociatedRDRHudView);
    return _hud;
}


- (void)setRdrHudView:(MBProgressHUD *)hud
{
    objc_setAssociatedObject(self, &kAssociatedRDRHudView, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
#pragma mark 错误提示

- (void)showErrorViewWithType:(kRDRErrorViewType)aType {
    [self showErrorViewWithType:aType atYOffset:0];
}

- (void)showErrorViewWithType:(kRDRErrorViewType)aType atYOffset:(CGFloat)yOffset {
    return [self showErrorViewOnView:self.view
                            withType:aType
                           atYOffset:yOffset];
}


- (void)showErrorViewOnView:(UIView *)aView
                   withType:(kRDRErrorViewType)aType {
    return [self showErrorViewOnView:aView
                            withType:aType
                           atYOffset:0];
}

- (void)showErrorViewOnView:(UIView *)aView
                   withType:(kRDRErrorViewType)aType
                  atYOffset:(CGFloat)yOffset {
    //
    [self hideErrorView];
    
    //
    CGFloat height = [RDRErrorView heightForContentWithType:aType];
    
    //
    CGRect rt = aView.bounds;
    CGFloat yMargin = 0.5 * (CGRectGetHeight(aView.bounds) - height);
    CGFloat inset = 0.0;
    
    rt.origin.y = [self navigationBarSize] + yOffset;
    if (yMargin - rt.origin.y > 0) {
        inset = yMargin - rt.origin.y;
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && [aView isKindOfClass:[UIScrollView class]]) {
        inset -= 0.5 * ((UIScrollView *)aView).contentInset.top;
    }
    
    //
    self.rdrErrorView = [[RDRErrorView alloc] initWithType:aType
                                                  frame:rt
                                                yOffset:inset];
    [self.rdrErrorView addTarget:self action:@selector(actionRDRErrorViewDiaTap:) forControlEvents:UIControlEventApplicationReserved];
    [aView addSubview:self.rdrErrorView];
}

- (CGFloat)navigationBarSize {
    return 0.0f;
}

- (void)hideErrorView {
    if (self.rdrErrorView.superview != nil) {
        [self.rdrErrorView removeFromSuperview];
    }
}

- (void)actionRDRErrorViewDiaTap:(RDRErrorView *)errorView {
    // 重新加载数据
    if ([self respondsToSelector:@selector(reloadViewControllerData)]) {
        // TODO 重新加载数据时的请求
        [self reloadViewControllerData];
    }
}

- (void)reloadViewControllerData {
    NSLog(@"in RDRTipAndAlert, reloadViewControllerData called, need to override by sub viewcontroller,self=%@", self);
}

#pragma mark -
#pragma mark Loading

- (void)showRDRIndicatorView {
    [self showRDRIndicatorViewWithTitle:@"努力加载中..."];
}

- (void)showRDRIndicatorViewWithTitle:(NSString *)title
{
    [self showRDRIndicatorViewAtYOffset:0.0 withTitle:title];
}

- (void)showRDRIndicatorViewAtYOffset:(CGFloat)yOffset withTitle:(NSString *)title
{
    [self showRDRIndicatorOnView:self.view
                         yOffset:yOffset
                       withTitle:title];
}

- (void)showRDRIndicatorOnView:(UIView *)aView yOffset:(CGFloat)yOffset withTitle:(NSString *)title
{
    if (self.rdrActivityView.superview != nil) {
        [self.rdrActivityView removeFromSuperview];
    }
    
    //
    self.rdrActivityView = [[RDRSpinnerView alloc] initWithView:aView withTipInfo:title];
    
    //
    CGFloat y = 0.0;
    y = yOffset + [self navigationBarSize];
    
    [self.rdrActivityView setYOffset:y];
    [aView addSubview:self.rdrActivityView];
    [self.rdrActivityView show:YES];
}

#pragma mark -
#pragma mark HUD

// 1使用Hud动画，0使用Indicator
#define kLoadingUseHudOrIndicator 1

/**
 *  下面来决定使用哪种加载动画
 */
- (void)showLoadingView:(NSString *)title {
    if (kLoadingUseHudOrIndicator) {
        [self showHudLoadingView:title];
    }else {
        [self showRDRIndicatorView];
    }
}

- (void)showHudLoadingView:(NSString *)title{
    [self showHudViewWithTitle:title];
}

- (void)showHudViewWithTitle:(NSString *)title
{
    [self showHudViewWithTitle:title onView:self.view yOffset:0.0];
}

- (void)showHudViewAtYOffset:(CGFloat)yOffset
{
    [self showHudViewWithTitle:nil
                        onView:self.view
                       yOffset:yOffset];
}

- (void)showHudViewWithTitle:(NSString *)title onView:(UIView *)aView yOffset:(CGFloat)yOffset
{
    if (self.rdrHudView == nil) {
        
        self.rdrHudView = [[MBProgressHUD alloc] initWithView:aView];
        
        [self.rdrHudView setLabelFont:[UIFont systemFontOfSize:14.0]];
        [self.rdrHudView setMode:MBProgressHUDModeCustomView];
        
        [aView addSubview:self.rdrHudView];
    }
    
    //
    [self.rdrHudView setLabelText:title];
    [self.rdrHudView show:YES];
}

- (void)hideHudAndIndicatorView
{
    if (self.rdrActivityView != nil) {
        [self.rdrActivityView hide:YES];
    }
    
    //
    if (self.rdrHudView != nil) {
        [self.rdrHudView hide:YES];
    }
}

#pragma mark -
#pragma mark Toast、弹框提示

+ (void)showToastWithmessage:(NSString *)msg {
    [[BTMToast sharedInstance] showToast:msg];
}

//
- (void)showToastWithMessage:(NSString *)message {
    [[BTMToast sharedInstance] showToast:message];
}

- (void)showToastWithMessageDelay:(NSString *)message {
    [self performSelector:@selector(showToastWithMessage:) withObject:message afterDelay:.6];
}


- (void)showToastOnNetworkError {
    [self showToastWithMessage:NSLocalizedString(@"网络不给力哦~\n再试试吧", nil)];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *tipAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [tipAlertView show];
}

@end
