//
//  ZJHUDView.m
//  hudview
//
//  Created by 李志朋 on 2018/12/29.
//  Copyright © 2018年 李志朋. All rights reserved.
//

#import "ZJHUDView.h"
#import "SPActivityIndicatorView.h"

@implementation ZJHUDView

+ (UIView *)showHUDView:(NSString *)title {
    UIView *backGroundView= [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    backGroundView.backgroundColor = [UIColor clearColor];
    backGroundView.opaque = NO ;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0);
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.68];
    SPActivityIndicatorView *activityIndicatorView = [[SPActivityIndicatorView alloc] initWithType:SPActivityIndicatorAnimationTypeBallBeat tintColor:[UIColor whiteColor]];
    CGFloat width = view.bounds.size.width - 30;
    CGFloat height = width;
    activityIndicatorView.frame = CGRectMake(15, 5, width, height);
    [view addSubview:activityIndicatorView];
    
    UILabel *showTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, view.bounds.size.height - 20 - 16, view.bounds.size.width, 20)];
    showTitle.textColor = [UIColor whiteColor];
    showTitle.text = title;
    showTitle.textAlignment = NSTextAlignmentCenter ;
    showTitle.font = [UIFont systemFontOfSize:14];
    [view addSubview:showTitle];
    
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:5];
    [activityIndicatorView startAnimating];
    
    [backGroundView addSubview:view];
    [[UIApplication sharedApplication].keyWindow addSubview:backGroundView];
    return backGroundView;
}

@end
