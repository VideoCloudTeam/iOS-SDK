//
//  VCPublicModel.h
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/8.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCPublicModel : NSObject

+ (instancetype) shareModel ;

@property (nonatomic, strong) NSString *apiServer ;

@end

NS_ASSUME_NONNULL_END
