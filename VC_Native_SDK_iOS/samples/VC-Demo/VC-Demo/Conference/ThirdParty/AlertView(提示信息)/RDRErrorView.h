//
//  RDRErrorView.h
//  RedDrive
//
//  Created by heqin on 15/8/21.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  错误提示类型
 加载失败...
 网络出错
 */
typedef enum : NSUInteger {
    // 未出错
    kRDRErrorViewTypeNone = 0,
    
    //网络不给力哦
    kRDRErrorViewTypeReloadNetworkError,
    
    // 服务器错误，如successCode不为1的情况
    kRDRErrorViewTypeReloadServerError,
    
    // 数据为空
    kRDRErrorViewTypeEmptyList,
}kRDRErrorViewType;


@interface RDRErrorView : UIControl

@property (nonatomic, assign, readonly) kRDRErrorViewType viewType;

- (instancetype)initWithType:(kRDRErrorViewType)aType
                       frame:(CGRect)frame
                     yOffset:(CGFloat)yOffset;

+ (CGFloat)heightForContentWithType:(kRDRErrorViewType)aType;

@end
