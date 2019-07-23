//
//  UIButton+LPUIButtonImageWithLable.m
//  linphone
//
//  Created by baidu on 16/1/4.
//
//

#import "UIButton+LPUIButtonImageWithLable.h"

@implementation UIButton (LPUIButtonImageWithLable)

//项目中经常会遇到Button上同时显示图片和文字，且图片和文字上下排列，同事用到的方法是在UIButton上添加一个UIImageView和UILable控件，这样做代码比较繁琐，然后我就试着扩展了UIButton，代码如下：
- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
//    CGSize titleSize = [title sizeWithFont:self.titleLabel.font];
//    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
//    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-8.0,
//                                              0.0,
//                                              0.0,
//                                              -1)];
//    [self setImage:image forState:stateType];
//    
//    [self.titleLabel setContentMode:UIViewContentModeCenter];
//    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
//    [self.titleLabel setFont:self.titleLabel.font];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
////    [self.titleLabel setTextColor:COLOR_ffffff];
//    [self setTitleEdgeInsets:UIEdgeInsetsMake(10.0,
////                                              -image.size.width,
//                                              2,
//                                              0.0,
//                                              0.0)];
//    [self setTitle:title forState:stateType];
}

//备注：如果不需要上下显示，只需要横向排列的时候，就不需要设置左右偏移量了，代码如下
//- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {
//    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
//    
//    CGSize titleSize = [title sizeWithFont:self.titleLabel.font];
//    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-8.0,
//                                              0.0,
//                                              0.0,
//                                              0.0)];
//    [self setImage:image forState:stateType];
//    
//    [self.titleLabel setContentMode:UIViewContentModeCenter];
//    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
//    [self.titleLabel setFont:self.titleLabel.font];
//    [self.titleLabel setTextColor:[UIColor blueColor]];
//    [self setTitleEdgeInsets:UIEdgeInsetsMake(30.0,
//                                              0.0,
//                                              0.0,
//                                              0.0)];
//    [self setTitle:title forState:stateType];
//}


@end
