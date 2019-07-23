//
//  RDRSpinnerView.m
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRSpinnerView.h"

@interface RDRSpinnerView ()

@property (nonatomic, retain) UIView *animationContentView;
@property (nonatomic, retain) UIImageView *cImageView;
@property (nonatomic, retain) UILabel *titleLabel;

@end


@implementation RDRSpinnerView

- (id)initWithView:(UIView *)view withTipInfo:(NSString *)tipStr
{
    if (self = [super initWithFrame:view.bounds]) {
        self.yOffset = 0;
        
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat h = 40.0;
        CGFloat width = 150;
        CGFloat height = 150 + h;
        
        self.animationContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [self.animationContentView setBackgroundColor:[UIColor clearColor]];
        
        {
            self.cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            self.cImageView.contentMode = UIViewContentModeCenter;
            [self.cImageView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"r_loading_0"], [UIImage imageNamed:@"r_loading_1"], nil]];
            [self.cImageView setAnimationDuration:.5];
            [self.animationContentView addSubview:self.cImageView];
        }
        
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height - h, width, h)];
            [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
            NSString *title = tipStr.length > 0 ? tipStr : @"努力加载中...";
            [self.titleLabel setText:title];
            [self.animationContentView addSubview:self.titleLabel];
        }
        
        [self addSubview:self.animationContentView];
    }
    
    return self;
}

#pragma mark -
#pragma mark layout

- (void)layoutSubviews
{
    UIView *parent = self.superview;
    if (parent) {
        [self setFrame:CGRectMake(0, self.yOffset, CGRectGetWidth(parent.bounds), CGRectGetHeight(parent.bounds) - self.yOffset)];
    }
    
    [self.animationContentView setCenter:CGPointMake(WIDTH * 0.5, CGRectGetHeight(self.bounds) * 0.5)];
}

#pragma mark -
#pragma mark Public Methods

- (void)show:(BOOL)animated
{
    /*
     if (animated)
     {
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:0.30];
     [self setAlpha:1];
     [UIView commitAnimations];
     }
     else
     //*/
    
    {
        [self setAlpha:1];
    }
    
    [self.cImageView startAnimating];
}

- (void)hide:(BOOL)animated
{
    [self setAlpha:0];
    [self.cImageView stopAnimating];
}

@end
