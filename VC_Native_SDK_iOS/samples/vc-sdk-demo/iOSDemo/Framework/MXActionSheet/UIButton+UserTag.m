//
//  UIButton+UserTag.m
//  linphone
//
//  Created by 李志朋 on 2019/4/17.
//

#import "UIButton+UserTag.h"
#import <objc/runtime.h>

static const void *kUserTag = @"userTag";

@implementation UIButton (UserTag)

- (void)setUserTag:(NSString *)userTag {
    objc_setAssociatedObject(self, &kUserTag, userTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)userTag {
    return objc_getAssociatedObject(self, &kUserTag);
}


@end
