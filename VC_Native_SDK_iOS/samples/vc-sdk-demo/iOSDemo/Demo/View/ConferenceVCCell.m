//
//  ConferenceVCCell.m
//  linphone
//
//  Created by mac on 2019/6/6.
//

#import "ConferenceVCCell.h"

@interface ConferenceVCCell ()
@property (nonatomic, strong) NSMutableArray *labelArray;
/**标题*/
@property (nonatomic, strong) UIView *titlesView;
/**底部线条*/
@property (nonatomic, strong) UIView *bottomSeperateView;
@end

@implementation ConferenceVCCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.titlesView = [[UIView alloc]init];
        [self.contentView addSubview:self.titlesView];
        self.bottomSeperateView = [[UIView alloc]init];
        self.bottomSeperateView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        [self.contentView addSubview:self.bottomSeperateView];
        self.labelArray = [NSMutableArray array];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titlesView.frame = CGRectMake(38, 0, self.contentView.frame.size.width - 38 * 2, 39);
    self.bottomSeperateView.frame = CGRectMake(38, CGRectGetMaxY(self.titlesView.frame), self.contentView.frame.size.width - 38 * 2, 1);
}

- (void)setTitleArray:(NSArray<NSString *> *)titleArray {
    if (_titleArray != titleArray) {
        _titleArray = titleArray;
        for (UIView *subView in self.titlesView.subviews) {
            [subView removeFromSuperview];
        }
        CGFloat labelWidth = (self.tableViewWidth - 38 * 2)/titleArray.count;
        for (NSInteger i = 0; i < titleArray.count; i++) {
            if (self.labelArray.count <= i) {
                UILabel *label = [[UILabel alloc]init];
                label.textAlignment = NSTextAlignmentCenter ;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont systemFontOfSize:13];
                label.hidden = YES;
                label.frame = CGRectZero;
                [self.labelArray addObject:label];
    
            } else {
                if (self.labelArray.count > titleArray.count) {
                    for (NSInteger index = self.labelArray.count; index < titleArray.count; index++) {
                        UILabel *label = self.labelArray[index];
                        label.hidden = YES;
                    }
                }
            }
            
            UILabel *label = self.labelArray[i];
            label.text = titleArray[i];
            label.frame = CGRectMake(i * labelWidth, 0, labelWidth, 39);
            [self.titlesView addSubview:label];
            label.hidden = NO;
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
