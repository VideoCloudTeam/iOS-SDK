//
//  QMButtonGroup.m
//  qmButton
//
//  Created by siweidg on 16/4/18.
//  Copyright © 2016年 siweidg. All rights reserved.
//

#import "QMButtonGroup.h"

@implementation QMButtonGroup


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonsHide = YES;
        _expansionDirection = QMButtonGroupExpansionDirectionLeft;
    }
    return self;
}

- (void)setButtons:(NSArray<UIButton *> *)buttons{
    _buttons = buttons;
    for (UIButton * button in buttons) {
        button.frame = self.frame;
        button.alpha = 0;
        [self.superview addSubview:button];
        
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.superview addConstraint:[NSLayoutConstraint
                                       constraintWithItem:button
                                       attribute:NSLayoutAttributeCenterX
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeCenterX
                                       multiplier:1.0
                                       constant:0.0]];
        
        [self.superview addConstraint:[NSLayoutConstraint
                                       constraintWithItem:button
                                       attribute:NSLayoutAttributeCenterY
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0
                                       constant:0.0]];
        
        [self.superview addConstraint:[NSLayoutConstraint
                                       constraintWithItem:button
                                       attribute:NSLayoutAttributeWidth
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeWidth
                                       multiplier:1.0
                                       constant:0.0]];
        
        [self.superview addConstraint:[NSLayoutConstraint
                                       constraintWithItem:button
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeHeight
                                       multiplier:1.0
                                       constant:0.0]];
        
    }
}

- (void)showButtons{
    _buttonsHide = NO;
    CGRect rect = self.frame;
    
    for (int i=0; i<self.buttons.count; i++) {
        UIButton * button = self.buttons[i];
        button.frame = self.frame;
        [UIView animateWithDuration:1 // 动画时长
                              delay:i*0.05 // 动画延迟
             usingSpringWithDamping:2 // 类似弹簧振动效果 0~1
              initialSpringVelocity:5.0 // 初始速度
                            options:UIViewAnimationOptionCurveEaseInOut // 动画过渡效果
                         animations:^{
                             button.alpha = 1;
                             
                             switch (self.expansionDirection) {
                                 case QMButtonGroupExpansionDirectionUp:
                                     for (NSLayoutConstraint *constraint in self.superview.constraints) {
                                         if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeCenterY) {
                                             [self.superview removeConstraint:constraint];
                                         }
                                     }
                                     
                                     [self.superview addConstraint:[NSLayoutConstraint
                                                                    constraintWithItem:button
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                    attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                    constant:-(i+1)*(rect.size.height + 20)]];
                                     break;
                                     
                                 case QMButtonGroupExpansionDirectionDown:
                                     for (NSLayoutConstraint *constraint in self.superview.constraints) {
                                         if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeCenterY) {
                                             [self.superview removeConstraint:constraint];
                                         }
                                     }
                                     
                                     [self.superview addConstraint:[NSLayoutConstraint
                                                                    constraintWithItem:button
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                    constant:(i+1)*(rect.size.height + 20)]];
                                     break;
                                     
                                 case QMButtonGroupExpansionDirectionRight:
                                     for (NSLayoutConstraint *constraint in self.superview.constraints) {
                                         if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeCenterX) {
                                             [self.superview removeConstraint:constraint];
                                         }
                                     }
                                     
                                     [self.superview addConstraint:[NSLayoutConstraint
                                                                    constraintWithItem:button
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                    attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                    constant:(i+1)*(rect.size.width + 20)]];
                                     break;
                                     
                                 case QMButtonGroupExpansionDirectionLeft:
                                     for (NSLayoutConstraint *constraint in self.superview.constraints) {
                                         if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeCenterX) {
                                             [self.superview removeConstraint:constraint];
                                         }
                                     }
                                     
                                     [self.superview addConstraint:[NSLayoutConstraint
                                                                    constraintWithItem:button
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                    attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                    constant:-(i+1)*(rect.size.width + 20)]];
                                     break;
                                     
                                     
                                 default:
                                     break;
                             }
                             
                             
                             
                             
                             
                             [button setNeedsLayout];
                             [button layoutIfNeeded];
                             
                         } completion:nil];
    }
}

- (void)hiddenButtons{
    _buttonsHide = YES;
    for (int i=0; i<self.buttons.count; i++) {
        UIButton * button = self.buttons[i];
        
        [UIView animateWithDuration:0.3 delay:i*0.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.alpha = 0;
            
            switch (self.expansionDirection) {
                case QMButtonGroupExpansionDirectionUp:
                    for (NSLayoutConstraint *constraint in self.superview.constraints) {
                        if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeBottom) {
                            [self.superview removeConstraint:constraint];
                        }
                    }
                    
                    [self.superview addConstraint:[NSLayoutConstraint
                                                   constraintWithItem:button
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeCenterY
                                                   multiplier:1.0
                                                   constant:0.0]];
                    break;
                    
                case QMButtonGroupExpansionDirectionDown:
                    for (NSLayoutConstraint *constraint in self.superview.constraints) {
                        if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeTop) {
                            [self.superview removeConstraint:constraint];
                        }
                    }
                    
                    [self.superview addConstraint:[NSLayoutConstraint
                                                   constraintWithItem:button
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeCenterY
                                                   multiplier:1.0
                                                   constant:0.0]];
                    break;
                    
                case QMButtonGroupExpansionDirectionRight:
                    for (NSLayoutConstraint *constraint in self.superview.constraints) {
                        if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeLeft) {
                            [self.superview removeConstraint:constraint];
                        }
                    }
                    
                    [self.superview addConstraint:[NSLayoutConstraint
                                                   constraintWithItem:button
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeCenterX
                                                   multiplier:1.0
                                                   constant:0.0]];
                    break;
                    
                case QMButtonGroupExpansionDirectionLeft:
                    for (NSLayoutConstraint *constraint in self.superview.constraints) {
                        if ([constraint.firstItem isEqual:button] && constraint.firstAttribute == NSLayoutAttributeRight) {
                            [self.superview removeConstraint:constraint];
                        }
                    }
                    
                    [self.superview addConstraint:[NSLayoutConstraint
                                                   constraintWithItem:button
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeCenterX
                                                   multiplier:1.0
                                                   constant:0.0]];
                    break;
                    
                    
                default:
                    break;
            }
            
            
            
            [button setNeedsLayout];
            [button layoutIfNeeded];
        } completion:nil];
    }
}

@end
