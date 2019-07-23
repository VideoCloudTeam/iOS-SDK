//
//  ConferenceHeaderView.m
//  linphone
//
//  Created by mac on 2019/6/6.
//

#import "ConferenceHeaderView.h"

@interface ConferenceHeaderView ()
/**关闭按钮*/
@property (nonatomic, strong) UIButton *closeBtn;
/**标题*/
@property (nonatomic, strong) UIView *titlesView;
/**底部线条*/
@property (nonatomic, strong) UIView *bottomSeperateView;
@end

@implementation ConferenceHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.closeBtn];
        [self.closeBtn setImage:[UIImage imageNamed:@"icon_information_off"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        self.titlesView = [[UIView alloc]init];
        [self addSubview:self.titlesView];
        self.bottomSeperateView = [[UIView alloc]init];
        self.bottomSeperateView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        [self addSubview:self.bottomSeperateView];
    }
    return self;
}

- (void)closeAction {
    if (self.block) {
        self.block();        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.closeBtn.frame = CGRectMake(25, 25, 30, 30);
    self.titlesView.frame = CGRectMake(38, CGRectGetMaxY(self.closeBtn.frame), self.frame.size.width - 38 * 2, 39);
    self.bottomSeperateView.frame = CGRectMake(38, CGRectGetMaxY(self.titlesView.frame), self.frame.size.width - 38 * 2, 1);
}

- (void)setTitleArray:(NSArray<NSString *> *)titleArray {
    if (_titleArray != titleArray) {
        _titleArray = titleArray;
        CGFloat labelWidth = (self.frame.size.width - 38 * 2)/titleArray.count;
        for (NSInteger i = 0; i < titleArray.count; i++) {
            UILabel *label = [[UILabel alloc]init];
            label.textAlignment = NSTextAlignmentCenter ;
           
            label.text = titleArray[i];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.frame = CGRectMake(i * labelWidth, 0, labelWidth, 39);
            [self.titlesView addSubview:label];
        }
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
