//
//  UIView+AddViewProperty.h
//  linphone
//
//  Created by mac on 2019/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AddViewProperty)
- (void)addShodow:(CGFloat)shadowRadius shadowOpacity: (CGFloat)shadowOpacity shadowOffset: (CGSize)shadowOffset cornerRadius: (CGFloat)cornerRadius shadowColor: (UIColor *)shadowColor;
@end

NS_ASSUME_NONNULL_END
