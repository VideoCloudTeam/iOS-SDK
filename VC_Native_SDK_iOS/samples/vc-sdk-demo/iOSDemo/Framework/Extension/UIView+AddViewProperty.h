//
//  UIView+AddViewProperty.h
//  linphone
//
//  Created by mac on 2019/5/5.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DefaultEditState,
    EditingState,
    ErrorState,
} TextFieldEditState;
NS_ASSUME_NONNULL_BEGIN

@interface UIView (AddViewProperty)
- (void)addShadowWithShadowRadius:(CGFloat)shadowRadius shadowOpacity: (CGFloat)shadowOpacity shadowOffset: (CGSize)shadowOffset cornerRadius: (CGFloat)cornerRadius shadowColor: (UIColor *)shadowColor;
- (UIView*)subViewOfClassName:(NSString*)className;
- (void)changeTextFieldEditState: (TextFieldEditState)state;
@end

NS_ASSUME_NONNULL_END
