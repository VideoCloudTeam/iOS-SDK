//
//  NSDate+ZJFormatInt.m
//  zj-phone
//
//  Created by 李志朋 on 2018/12/25.
//

#import "NSDate+ZJFormatInt.h"

@implementation NSDate (ZJFormatInt)

@dynamic year ;
@dynamic month ;
@dynamic day ;
@dynamic hour ;
@dynamic minute ;
@dynamic second ;


- (instancetype) init {
    if( self = [super init]) {
        self.year   = 0;
        self.month  = 0;
        self.day    = 0;
        self.hour   = 0;
        self.minute = 0;
        self.second = 0;
    }
    return self; 
}

@end
