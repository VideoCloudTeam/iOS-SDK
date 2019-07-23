//
//  WQDevice.m
//  CoreFramework
//
//  Created by Jayla on 16/1/14.
//  Copyright © 2016年 Anzogame. All rights reserved.
//

#import "WQDevice.h"
//获取ip地址引入的库
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation WQDevice

+ (NSString *)osVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuild{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)appIdentifier{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)deviceModel{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)deviceUUID{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (BOOL)isDevicePhone{
    NSString * deviceType = [UIDevice currentDevice].model;
    if ([deviceType rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].length > 0 ||
        [deviceType rangeOfString:@"iPod" options:NSCaseInsensitiveSearch].length > 0 ||
        [deviceType rangeOfString:@"iTouch" options:NSCaseInsensitiveSearch].length > 0 ){
        return YES;
    }
    return NO;
}

+ (BOOL)isDevicePad{
    NSString * deviceType = [UIDevice currentDevice].model;
    if ( [deviceType rangeOfString:@"iPad" options:NSCaseInsensitiveSearch].length > 0 ){
        return YES;
    }
    return NO;
}

+ (BOOL)isPhone35{
    return [self isScreenSize:CGSizeMake(320, 480)];
}

+ (BOOL)isPhoneRetina35{
    return [self isScreenSize:CGSizeMake(640, 960)];
}

+ (BOOL)isPhoneRetina40{
    return [self isScreenSize:CGSizeMake(640, 1136)];
}

+ (BOOL)isPhoneRetina47{
    return [self isScreenSize:CGSizeMake(750, 1334)];
}

+ (BOOL)isPhoneRetina55{
    return [self isScreenSize:CGSizeMake(1242, 2208)];
}

+ (BOOL)isPhoneX{
    return [self isScreenSize:CGSizeMake(1125, 2436)];
}

+ (BOOL)isPadDevice{
    return [self isScreenSize:CGSizeMake(768, 1024)];
}

+ (BOOL)isPadRetina{
    return [self isScreenSize:CGSizeMake(1536, 2048)];
}

+ (BOOL)isScreenSize:(CGSize)size{
    if ( [UIScreen instancesRespondToSelector:@selector(currentMode)] ){
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        CGSize size2 = CGSizeMake( size.height, size.width );
        if ( CGSizeEqualToSize(size, screenSize) || CGSizeEqualToSize(size2, screenSize) ){
            return YES;
        }
    }
    
    return NO;
}
+ (NSString *)getIPAddress{
    NSMutableString* address = [[NSMutableString alloc] init];
    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                NSString* ifa_name = [NSString stringWithUTF8String: temp_addr->ifa_name];
                NSString* ip = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                NSString* name = [NSString stringWithFormat: @"%@: %@ ", ifa_name, ip];
                [address appendString: name];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    return address;
}

//for js native
+(NSInteger)NSNotFound {
    return NSNotFound;
}

@end
