//
//  ZJAPPEngine.h
//  linphone
//
//  Created by mac on 2019/5/11.
//

#import <UIKit/UIKit.h>
#import "WQNetworkProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJAPPEngine : UIResponder
@property (nullable, nonatomic, strong) id<WQNetworkProtocol> networkManager;
@end

NS_ASSUME_NONNULL_END
