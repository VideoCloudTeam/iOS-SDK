//
//  NameView.h
//  linphone
//
//  Created by mac on 2020/1/16.
//

#import <UIKit/UIKit.h>

static CGFloat imgWidth = 15.0;//图标宽度
static CGFloat imgLeftMargin = 2.0;//图标左边距
static CGFloat imgRightMargin = 2.0;//图标右边距
static CGFloat noImgLabLeftMargin = 5.0;//无图标Label左边距
static CGFloat labRightMargin = 5.0;//label右边距

NS_ASSUME_NONNULL_BEGIN

@interface NameView : UIView
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, assign, readonly) CGFloat superViewMaxWidth;
- (instancetype)initWithFrame:(CGRect)frame maxWidth: (CGFloat)maxWidth;
- (void)setImage: (UIImage *)image title: (NSString *)title;
@end

NS_ASSUME_NONNULL_END
