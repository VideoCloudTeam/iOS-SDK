//
//  NSMutableAttributedString+ZJAttributedString.m
//  linphone
//
//  Created by mac on 2019/6/14.
//

#import "NSMutableAttributedString+ZJAttributedString.h"

@implementation NSMutableAttributedString (ZJAttributedString)
- (CGSize)cuculateAttributedStringWidthWithFontSize: (CGFloat)fontSize withLHeight: (CGFloat)height {
    CGSize size = CGSizeMake(1000, height);
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return rect.size;
}

- (CGSize)cuculateAttributedStringHeightWithFontSize: (CGFloat)fontSize withWidth: (CGFloat)width {
    CGSize size = CGSizeMake(width, 1000);
    CGRect rect = [self boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return rect.size;
}
@end
