//
//  QMButtonGroup.h
//  qmButton
//
//  Created by siweidg on 16/4/18.
//  Copyright © 2016年 siweidg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMButtonGroupExpansionDirection) {
    QMButtonGroupExpansionDirectionLeft = 0,
    QMButtonGroupExpansionDirectionRight,
    QMButtonGroupExpansionDirectionUp,
    QMButtonGroupExpansionDirectionDown
};

@interface QMButtonGroup : UIView

/**
 *  按钮组
 */
@property (nonatomic,strong) NSArray<UIButton *> * buttons;

/**
 *  按钮组隐藏标志
 */
@property (nonatomic,assign) QMButtonGroupExpansionDirection expansionDirection;

/**
 *  按钮组隐藏标志
 */
@property (nonatomic,assign,readonly) BOOL buttonsHide;

/**
 *  显示按钮组
 */
- (void)showButtons;

/**
 *  隐藏按钮组
 */
- (void)hiddenButtons;

@end
