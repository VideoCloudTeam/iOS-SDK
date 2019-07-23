//
//  ActionModel.h
//  linphone
//
//  Created by 李志朋 on 2019/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActionModel : NSObject


- (instancetype)initWithName:(NSString *)name withUserTag:(NSString *)userTag ;
@property (nonatomic, strong ) NSString *name ;
@property (nonatomic, strong ) NSString *userTag ;

@end

NS_ASSUME_NONNULL_END
