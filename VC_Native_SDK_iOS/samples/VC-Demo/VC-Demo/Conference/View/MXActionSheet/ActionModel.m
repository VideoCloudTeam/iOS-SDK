//
//  ActionModel.m
//  linphone
//
//  Created by 李志朋 on 2019/4/17.
//

#import "ActionModel.h"

@implementation ActionModel

- (instancetype)init {
    if (self = [super init]) {
        self.name = @"" ;
        self.userTag = @"" ;
    }
    return self ;
}

- (instancetype)initWithName:(NSString *)name withUserTag:(NSString *)userTag {
    if (self = [super init]) {
        self.name = name ;
        self.userTag = userTag ;
    }
    return self ;
}



@end
