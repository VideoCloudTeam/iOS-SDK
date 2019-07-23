//
//  ConferenceVCCell.h
//  linphone
//
//  Created by mac on 2019/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceVCCell : UITableViewCell
@property(nonatomic, strong) NSArray<NSString *> *titleArray;
@property (nonatomic, assign) CGFloat tableViewWidth;//table宽度
@end

NS_ASSUME_NONNULL_END
