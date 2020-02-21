//
//  ConferenceHeaderView.h
//  linphone
//
//  Created by mac on 2019/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^CloseBlock)(void);
@interface ConferenceHeaderView : UIView
@property (nonatomic, copy) CloseBlock block;
@property(nonatomic, strong) NSArray<NSString *> *titleArray;
@end

NS_ASSUME_NONNULL_END
