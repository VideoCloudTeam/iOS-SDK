//
//  SmallView.m
//  iOSDemo
//
//  Created by mac on 2019/7/8.
//  Copyright © 2019 mac. All rights reserved.
//

#import "SmallView.h"
#import "NSMutableAttributedString+ZJAttributedString.h"


@interface SmallView ()
/** 参会者会中显示的名 */
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
/** 加载状态 */
@property (weak, nonatomic) IBOutlet UIImageView *stateImg;

/** nameLab的宽度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabWidthConstant;
/** nameLab的高度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabHeight;
/** nameLab距离父视图顶部的距离 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabTopToSuperView;

/** 是否是最大的视频视图 */
@property (nonatomic, assign) BOOL isBig;

@end

@implementation SmallView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLab.backgroundColor = [[UIColor colorWithRed:18/255.0 green:26/255.0 blue:44/255.0 alpha:1.0] colorWithAlphaComponent:0.2];
}

+ (instancetype)smallView {
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [SmallView smallView];
    }
    return self;
}

- (void)setVideoView:(VCVideoView *)videoView {
    //    if (_videoView != videoView) {
    _videoView = videoView;
    [self insertSubview:videoView atIndex:1];
    videoView.frame = self.bounds;
    videoView.objectFit = VCVideoViewObjectFitCover;
    //    }
}

+ (instancetype)loadSmallViewWithVideoView: (VCVideoView *)videoView isTurnOffTheCamera: (BOOL)isTurnOffTheCamera withParticipant: (Participant *)participant isBig: (BOOL) isBig uuid: (NSString *)uuid {
    SmallView *smallView = [SmallView smallView];
    [smallView insertSubview:videoView atIndex:1];
    [smallView bringSubviewToFront:smallView.nameLab];
    videoView.objectFit =  !videoView.isPresentation ? VCVideoViewObjectFitCover : VCVideoViewObjectFitContain ;
    smallView.videoView = videoView;
    if (isTurnOffTheCamera) {
        smallView.stateImg.image = [UIImage imageNamed:@"background-close-video"];
    } else {
        [smallView addAnimationImageWithImageView:smallView.stateImg];
    }
    
    if (participant.overlayText.length > 0) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:@""];
        NSAttributedString * nameString =  [[NSAttributedString alloc]initWithString:participant.overlayText];
        [attributedText appendAttributedString:nameString];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributedText.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attributedText.length)];
        //计算会中显示名的宽度 18 是nameLab的高度
        CGFloat width = [attributedText cuculateAttributedStringWidthWithFontSize:13 withLHeight:18].width + 10 > 100 ? 100 : [attributedText cuculateAttributedStringWidthWithFontSize:13 withLHeight:18].width + 10;
        smallView.nameLab.attributedText = attributedText;
        smallView.nameLabWidthConstant.constant = width;
    } else {
        smallView.nameLab.hidden = YES;
    }

    smallView.isBig = isBig;
    smallView.uuid = uuid;
    return smallView;
}


/** 加载动画视图 */
- (void)addAnimationImageWithImageView: (UIImageView *)img {
    UIImage *image1 = [UIImage imageNamed:@"icon_loding1"];
    UIImage *image2 = [UIImage imageNamed:@"icon_loding2"];
    UIImage *image3 = [UIImage imageNamed:@"icon_loding3"];
    NSArray *imagesArray = @[image1,image2,image3];
    img.animationImages = imagesArray;
    img.animationDuration = [imagesArray count];
    img.animationRepeatCount = 0;
    [img startAnimating];
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoView.frame = self.bounds;
    NSLog(@"--------------%@", NSStringFromCGRect(self.videoView.frame));
    if (self.isBig) {
        self.nameLab.frame = CGRectMake(1, 1, self.nameLabWidthConstant.constant, self.nameLabHeight.constant);
    } else {
        //1是nameLab距离底部的距离
        self.nameLab.frame = CGRectMake(1, self.bounds.size.height - self.nameLabHeight.constant - 1, self.nameLabWidthConstant.constant, self.nameLabHeight.constant);
    }
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
