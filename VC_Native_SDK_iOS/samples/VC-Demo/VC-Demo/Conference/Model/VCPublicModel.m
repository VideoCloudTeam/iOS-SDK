//
//  VCPublicModel.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/8.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "VCPublicModel.h"

static VCPublicModel *model ;
@implementation VCPublicModel

+ (instancetype)shareModel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[self alloc]init];
    });
    return model ;
}

- (instancetype)init {
    if (self = [super init]) {
        _apiServer = @"" ;
    }
    return self ;
}

- (void)setApiServer:(NSString *)apiServer {
    if (apiServer) {
        BOOL isIP = [self judgmentIsIP:apiServer];
        NSString *newApiServer =  [NSString stringWithFormat:@"%@%@",isIP ? @"http://" : @"https://" , apiServer] ;
        _apiServer = newApiServer ;
    }
}

- (BOOL )judgmentIsIP: (NSString *)serverAddress {
    NSString *ipserver ;
    if ([serverAddress rangeOfString:@":"].length) {
        ipserver = [[serverAddress componentsSeparatedByString:@":"]firstObject];
    } else {
        ipserver = serverAddress ;
    }
    for (NSString *subAddr in [ipserver componentsSeparatedByString:@"."]) {
        NSString * newSubAddr = [subAddr stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] ;
        if (newSubAddr.length > 0) {
            return NO;
        }
    }
    return YES ;
}


@end
