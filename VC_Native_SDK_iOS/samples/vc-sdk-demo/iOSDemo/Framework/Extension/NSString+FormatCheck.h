//
//  NSObject+FormatCheck.h
//  linphone
//
//  Created by mac on 2019/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FormatCheck)
/**
 *  @brief  判断是否为密码
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
- (BOOL)isPassword;

/**
 *  @brief  判断是否为验证码
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
- (BOOL)isVerifyCode;

/**
 *  @brief  判断是否为邮箱
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
-(BOOL)isValidateEmail;

/**
 *  @brief  判断是否为手机号
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
-(BOOL)isValidateMobile;


/**
 *  @brief  判断是否为密码
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
-(BOOL)isValidPassword;

/**
 *  @brief  是否是纯数字
 *
 *  @return BOOL
 *
 *  @since 1.0
 */
-(BOOL)isNumber;
@end

NS_ASSUME_NONNULL_END
