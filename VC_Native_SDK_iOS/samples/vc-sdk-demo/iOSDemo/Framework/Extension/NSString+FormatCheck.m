//
//  NSObject+FormatCheck.m
//  linphone
//
//  Created by mac on 2019/5/5.
//

#import "NSString+FormatCheck.h"

@implementation NSString (FormatCheck)
- (BOOL)isPassword
{
    NSString *regex = @"(^[A-Za-z0-9]{6,16}$)";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isVerifyCode
{
    NSString *regex = @"(^[0-9]{6}$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isValidateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isValidateMobile
{
    NSString *phoneRegex = @"^((1))\\d{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)isValidPassword
{
    NSString *passRegex = @"^[0-9A-Za-z]{6,20}";
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passRegex];
    return [passTest evaluateWithObject:self];
}


-(BOOL)isNumber
{
    NSString *passRegex = @"^[0-9]*$";
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passRegex];
    return [passTest evaluateWithObject:self];
}
@end
