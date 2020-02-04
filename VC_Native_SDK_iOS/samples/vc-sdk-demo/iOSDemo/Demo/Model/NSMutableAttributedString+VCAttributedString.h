//
//  NSMutableAttributedString+VCAttributedString.h
//  linphone
//
//  Created by mac on 2019/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (VCAttributedString)
- (CGSize)cuculateAttributedStringWidthWithFontSize: (CGFloat)fontSize withLHeight: (CGFloat)height;
- (CGSize)cuculateAttributedStringHeightWithFontSize: (CGFloat)fontSize withWidth: (CGFloat)width;
@end

NS_ASSUME_NONNULL_END
