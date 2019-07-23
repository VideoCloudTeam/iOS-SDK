//
//  RDRSpinnerView.h
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface RDRSpinnerView : UIView

@property (nonatomic, assign) CGFloat yOffset;

- (id)initWithView:(UIView *)view withTipInfo:(NSString *)tipStr;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;


@end
