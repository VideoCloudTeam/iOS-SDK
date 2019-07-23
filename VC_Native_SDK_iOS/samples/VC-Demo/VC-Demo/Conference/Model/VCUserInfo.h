//
//  VCUserInfo.h
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/5.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCUserInfo : NSObject

@property (nonatomic, copy)NSString *trueName;
@property (nonatomic, copy)NSString *userName;
@property (nonatomic, copy)NSString *account;
@property (nonatomic, copy)NSString *sipkey;
@property (nonatomic, assign)NSString *userType;
@property (nonatomic, assign)NSString *session_id ;
@property (nonatomic, strong)NSNumber *companyId;



@end

NS_ASSUME_NONNULL_END
