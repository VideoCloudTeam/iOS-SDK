//
//  WQDevice.h
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IOS11_OR_LATER    ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0f)
#define IOS10_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 10.0f)
#define IOS9_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
#define IOS8_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)
#define IOS7_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)
#define IOS6_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 6.0f)
#define IOS5_OR_LATER	([[UIDevice currentDevice].systemVersion floatValue] >= 5.0f)

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define CONSTANT_i5(x)  (x * SCREEN_WIDTH / 320.0f)
#define CONSTANT_i6(x)  (x * SCREEN_WIDTH / 375.0f)

@interface WQDevice : NSObject

+ (NSString *)osVersion;
+ (NSString *)appVersion;
+ (NSString *)appBuild;
+ (NSString *)appIdentifier;
+ (NSString *)deviceModel;
+ (NSString *)deviceUUID;
+ (NSString *)getIPAddress;

+ (BOOL)isDevicePhone;
+ (BOOL)isDevicePad;

+ (BOOL)isPhone35;
+ (BOOL)isPhoneRetina35;
+ (BOOL)isPhoneRetina40;
+ (BOOL)isPhoneRetina47;
+ (BOOL)isPhoneRetina55;
+ (BOOL)isPhoneX;
+ (BOOL)isPadDevice;
+ (BOOL)isPadRetina;
+ (BOOL)isScreenSize:(CGSize)size;

@end
