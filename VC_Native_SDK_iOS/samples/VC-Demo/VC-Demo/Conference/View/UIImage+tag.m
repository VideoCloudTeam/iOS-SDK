//
//  UIImage+tag.m
//  zj-phone
//
//  Created by 李志朋 on 2019/4/15.
//

#import "UIImage+tag.h"
#import <objc/runtime.h>

static const void *kTag = @"tag";


@implementation UIImage (tag)

- (void)setTag:(BOOL)tag {
    objc_setAssociatedObject(self, &kTag, [NSNumber numberWithBool:tag], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)tag {
    return [objc_getAssociatedObject(self, &kTag) boolValue];
}

@end
