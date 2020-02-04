//
//  UIView+AddViewProperty.m
//  linphone
//
//  Created by mac on 2019/5/5.
//

#import "UIView+AddViewProperty.h"

@implementation UIView (AddViewProperty)
- (void)addShadowWithShadowRadius:(CGFloat)shadowRadius shadowOpacity: (CGFloat)shadowOpacity shadowOffset: (CGSize)shadowOffset cornerRadius: (CGFloat)cornerRadius shadowColor: (UIColor *)shadowColor {
    shadowRadius = (shadowRadius == 0.0 ? 18.5 : shadowRadius);
    shadowOpacity = (shadowOpacity == 0.0 ? 1 : shadowOpacity);
    shadowOffset = (shadowOffset.height == 0 && shadowOffset.width == 0 ? CGSizeMake(0, 4) : shadowOffset);
    cornerRadius = (cornerRadius == 0 ? 18.5 : cornerRadius);
    shadowColor = (shadowColor == nil ? [UIColor colorWithRed:202/255.0 green:202/255.0 blue:202/255.0 alpha:0.42] : shadowColor);
    self.layer.cornerRadius = cornerRadius;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = shadowRadius;
}
- (UIView*)subViewOfClassName:(NSString*)className {
    for (UIView* subView in self.subviews) {
        if ([NSStringFromClass(subView.class) isEqualToString:className]) {
            return subView;
        }
        
        UIView* resultFound = [subView subViewOfClassName:className];
        if (resultFound) {
            return resultFound;
        }
    }
    return nil;
}

- (void)changeTextFieldEditState:(TextFieldEditState)state {
    switch (state) {
        case ErrorState:
            self.backgroundColor = [UIColor colorWithHexString:@"FF605C"];
            break;
            case DefaultEditState:
            self.backgroundColor = [UIColor colorWithHexString:@"EDEFF2"];
            break;
            case EditingState:
            self.backgroundColor = [UIColor colorWithHexString:@"408CFF"];
        default:
            break;
    }
}
@end
