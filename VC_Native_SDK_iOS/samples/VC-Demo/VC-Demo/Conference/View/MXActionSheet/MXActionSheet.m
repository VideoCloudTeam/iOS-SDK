//
//  MXActionSheet.m
//  0816 - MXActionSheet
//
//  Created by Apple on 2016/8/16.
//  Copyright © 2016年 HuaXiaCollege. All rights reserved.
//

#import "MXActionSheet.h"
#import "UIButton+UserTag.h"
#import "ActionModel.h"

#define MXAS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define MXAS_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define BTN_MXAS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width /2.0 : [UIScreen mainScreen].bounds.size.width)

#define kTitleFontSize [UIFont systemFontOfSize:14]
#define kButtonFontSize [UIFont systemFontOfSize:17]

static const CGFloat kRowHeight = 50.0;
static BOOL isCliked = NO;

#define kCancelButtonTopGap  6.0f

@interface MXActionSheet() {
    
    __weak UIView *_maskView;
}

@property(nonatomic, copy) void (^selectedBLock)(NSInteger index, NSString *userTag);

@end

@implementation MXActionSheet
- (void)dealloc {
    
//    YunluLog(@"%@", _maskView);//null
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles selectedBlock:(void (^)(NSInteger index, NSString *userTag))selectedBlock {
    
    self = [super init];
    if (self) {
     
        //在keyWindow上添加一个带点透明黑色背景
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MXAS_SCREEN_WIDTH, MXAS_SCREEN_HEIGHT)];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureInvoked:)];
        [maskView addGestureRecognizer:singleTap];
        [[UIApplication sharedApplication].keyWindow addSubview:maskView];
        _maskView = maskView;
        
        //在keyWindow上底部添加一个背景的actionSheet
        self.frame = CGRectMake(0, MXAS_SCREEN_HEIGHT, BTN_MXAS_SCREEN_WIDTH + 20 , 0);
        self.ott_centerX = BTN_MXAS_SCREEN_WIDTH ;

//        self.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        CGFloat actionSheetH = 0;
        if (title) {

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BTN_MXAS_SCREEN_WIDTH, [self getSizeWithString:title font:kTitleFontSize].height + 2 * 15)];
            titleLabel.backgroundColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.numberOfLines = 0;
            titleLabel.text = title;
            titleLabel.font = kTitleFontSize;
            titleLabel.textColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];//64
            [self addSubview:titleLabel];
            
            actionSheetH = CGRectGetMaxY(titleLabel.frame) + 0.5;
        }
        
        UIImage *normalImage = [self getImageWithColor:[UIColor whiteColor]];
        UIImage *highlightedImage = [self getImageWithColor:[UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f]];
        if (destructiveButtonTitle) {
            
            UIButton *destructiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            destructiveButton.frame = CGRectMake(0, actionSheetH, BTN_MXAS_SCREEN_WIDTH, kRowHeight);
            destructiveButton.ott_centerX = self.ott_width / 2 ;
            destructiveButton.tag = -1;
            destructiveButton.titleLabel.font = kButtonFontSize;
            [destructiveButton setTitle:destructiveButtonTitle forState:UIControlStateNormal];
            [destructiveButton setTitleColor:[UIColor colorWithRed:230.0f/255.0f green:66.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [destructiveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [destructiveButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:destructiveButton];
            
            actionSheetH = CGRectGetMaxY(destructiveButton.frame) + 0.5;
        }
        if (otherButtonTitles.count) {
            
            int index = 1;
            for (ActionModel *actionModel in otherButtonTitles) {
                NSString *otherButtonTitle = actionModel.name ;
                NSString *userTag = actionModel.userTag ;
                UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
                otherButton.userTag = userTag ;
                otherButton.frame = CGRectMake(0, actionSheetH, BTN_MXAS_SCREEN_WIDTH , kRowHeight);
                otherButton.ott_centerX =  self.ott_width / 2;
                otherButton.tag = index;
                otherButton.titleLabel.font = kButtonFontSize;
                [otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
                [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [otherButton setBackgroundImage:normalImage forState:UIControlStateNormal];
                [otherButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
                [otherButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:otherButton];
                
                actionSheetH = CGRectGetMaxY(otherButton.frame) + 1;
                index++;
            }
        }
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BTN_MXAS_SCREEN_WIDTH, actionSheetH - 0.5)];
        backgroundView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1] ;
        backgroundView.ott_centerX = self.ott_width / 2 ;
        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
        
        
        if (cancelButtonTitle) {

            actionSheetH += kCancelButtonTopGap;
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.frame = CGRectMake(0, actionSheetH, BTN_MXAS_SCREEN_WIDTH, kRowHeight);
            cancelButton.ott_centerX =  self.ott_width / 2 ;
            cancelButton.tag = 0;
            cancelButton.titleLabel.font = kButtonFontSize;
            [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            [cancelButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelButton];
            
            actionSheetH = CGRectGetMaxY(cancelButton.frame) + 0.5;
            CGRect frame = self.frame;
            frame.size.height = actionSheetH;
            self.frame = frame;
        }
        
        
        
    }
    return self;
}

- (void)hide {
    
    [UIView animateWithDuration:0.35f animations:^{
        
        CGRect frame = self.frame;
        frame.origin.y = MXAS_SCREEN_HEIGHT;
        self.frame = frame;
        _maskView.alpha = 0.01;
    } completion: ^(BOOL finished) {
        
        [self removeFromSuperview];
        [_maskView removeFromSuperview];
    }];
}

- (void)show {
    
    _maskView.alpha = 0.01f;
    [UIView animateWithDuration:0.35f animations:^{
        
        //在动画过程中禁止遮罩视图响应用户手势
        _maskView.alpha = 1.0f;
        _maskView.userInteractionEnabled = NO;
        
        CGRect frame = self.frame;
        frame.origin.y = MXAS_SCREEN_HEIGHT - self.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        
        //在动画结束后允许遮罩视图响应用户手势
        _maskView.userInteractionEnabled = YES;
    }];
}

+ (void)showWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle   destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles selectedBlock:(void (^)(NSInteger index, NSString *userTag))selectedBlock {
    
    if (isCliked) {
        return;
    }
    MXActionSheet *actionSheet = [[MXActionSheet alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles selectedBlock:selectedBlock];
    actionSheet.selectedBLock = selectedBlock;
    [actionSheet show];
    
    isCliked = YES;
}

#pragma mark - button actions
- (void)buttonClicked:(UIButton *)sender {
    
    self.selectedBLock ? self.selectedBLock(sender.tag, sender.userTag) : nil;
    [self hide];
    isCliked = NO;
}

#pragma mark - gesture actions
- (void)singleTapGestureInvoked:(UITapGestureRecognizer *)recognizer {
    
    [self hide];
    isCliked = NO;
}

#pragma mark - private methods
- (CGSize)getSizeWithString:(NSString *)string font:(UIFont *)font{

    return [string boundingRectWithSize:CGSizeMake(MXAS_SCREEN_WIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
}

- (UIImage *)getImageWithColor:(UIColor *)color {
    
    CGSize imageSize = CGSizeMake(MXAS_SCREEN_WIDTH, 1.0f);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, color.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
