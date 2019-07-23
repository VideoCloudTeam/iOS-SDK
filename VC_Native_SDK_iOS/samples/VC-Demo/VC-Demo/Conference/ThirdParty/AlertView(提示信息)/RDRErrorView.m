//
//  RDRErrorView.m
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRErrorView.h"

@interface RDRErrorView()

@property (nonatomic, assign) kRDRErrorViewType viewType;


@end


@implementation RDRErrorView

#pragma mark -
#pragma mark init

- (id)initWithFrame:(CGRect)frame {
    return [self initWithType:kRDRErrorViewTypeReloadServerError
                        frame:frame
                      yOffset:0];
}

- (instancetype)initWithType:(kRDRErrorViewType)aType
                       frame:(CGRect)frame
                     yOffset:(CGFloat)yOffset {
    
    if (self = [super initWithFrame:frame]) {

        // 默认背景色
        self.backgroundColor = [UIColor whiteColor];

        //
        UIImage *errorImage = nil;
        NSString *errorTitle = nil;
        
        //
        CGFloat width = CGRectGetWidth(frame);
        
        //
        switch (aType) {
            case kRDRErrorViewTypeReloadNetworkError: {
                errorImage = [UIImage imageNamed:@"error_net_notgood"];
                errorTitle = @"网络不给力哦...";
            }
                break;
                
            case kRDRErrorViewTypeReloadServerError: {
                errorImage = [UIImage imageNamed:@"error_server"];
                errorTitle = @"服务器出错了，请稍候再试";
            }
                break;
                
            case kRDRErrorViewTypeEmptyList: {
                errorImage = [UIImage imageNamed:@"error_emptylist"];
                errorTitle = @"暂时没有数据";
            }
                break;

            case kRDRErrorViewTypeNone:
            default: {
            }
                break;
        }
        
        //
        {
            UIImageView *aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5 * (width - 150), yOffset, 150, 150)];
            [aImageView setImage:errorImage];
            [self addSubview:aImageView];
            aImageView.backgroundColor = [UIColor greenColor];
            
            //
            yOffset = CGRectGetMaxY(aImageView.frame) + 15;
        }
        
        //
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, width, 40)];
            [label setNumberOfLines:0];
            [label setFont:[UIFont systemFontOfSize:14.0]];
            [label setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x88/255.0 blue:0x88/255.0 alpha:1.0]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            [label setText:errorTitle];
            [self addSubview:label];
            
            //
            yOffset = CGRectGetMaxY(label.frame) + 10;
        }
        
        // 网络出错或者未知，都有重试按钮
        if (aType == kRDRErrorViewTypeReloadNetworkError ||
            aType == kRDRErrorViewTypeReloadServerError)
        {
            UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
            aButton.frame = CGRectMake(0.5 * (width - 144), yOffset, 144, 26);
            aButton.layer.cornerRadius = 5.0;
            aButton.layer.borderWidth = 1.0;
            
            [aButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            [aButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [aButton setTitle:@"重试" forState:UIControlStateNormal];
            [aButton addTarget:self action:@selector(actionReloadButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:aButton];
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark Action Methods

- (void)actionReloadButtonDidTap:(UIButton *)aButton {
    [self sendActionsForControlEvents:UIControlEventApplicationReserved];
}


#pragma mark -
#pragma mark Public Methods

+ (CGFloat)heightForContentWithType:(kRDRErrorViewType)aType {
    
    //
    CGFloat height = 190.0;
    
    if (aType == kRDRErrorViewTypeReloadNetworkError ||
        aType == kRDRErrorViewTypeReloadServerError) {
        // 有重试按钮， 所以高度增加
        height = 190 + 26 + 15 + 15;
    }
    
    return height;
}




@end
