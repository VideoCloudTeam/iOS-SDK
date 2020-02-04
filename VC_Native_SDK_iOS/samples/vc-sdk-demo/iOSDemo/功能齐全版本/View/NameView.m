//
//  NameView.m
//  linphone
//
//  Created by mac on 2020/1/16.
//

#import "NameView.h"

@interface NameView ()
@property (nonatomic, assign) CGFloat maxWidth;
@end

@implementation NameView
- (instancetype)initWithFrame:(CGRect)frame maxWidth: (CGFloat)maxWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.img = [[UIImageView alloc]init];
        self.nameLab = [[UILabel alloc]init];
        self.nameLab.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.nameLab.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.img];
        [self addSubview:self.nameLab];
        self.backgroundColor = [UIColor redColor];
        self.backgroundColor = [[UIColor colorWithHexString:@"121A2C"] colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = 2;
        self.clipsToBounds = YES;
        self.maxWidth = maxWidth;
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat actualLabWidth = 0.0;
    if (self.img.image) {
        self.img.frame = CGRectMake(imgLeftMargin, 1.5, imgWidth, imgWidth);
        actualLabWidth = self.maxWidth - imgWidth - imgLeftMargin - imgRightMargin - labRightMargin;
    } else {
        self.img.frame = CGRectZero;
        actualLabWidth = self.maxWidth - noImgLabLeftMargin - labRightMargin;
    }
    CGFloat nameLabWidth = [self.nameLab.text widthForFont:[UIFont systemFontOfSize:13]] > actualLabWidth ? actualLabWidth : [self.nameLab.text widthForFont:[UIFont systemFontOfSize:13]];
    self.nameLab.frame = CGRectMake(self.img.image ? CGRectGetMaxX(self.img.frame) +imgRightMargin : noImgLabLeftMargin, 0, nameLabWidth, 18);
}

- (CGFloat)superViewMaxWidth {
    return _maxWidth;
}
- (void)setImage:(UIImage *)image title:(NSString *)title {
    if (image) {
        self.img.image = image;
    } else {
        self.img.image = nil;
    }
    self.nameLab.text = title;
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
