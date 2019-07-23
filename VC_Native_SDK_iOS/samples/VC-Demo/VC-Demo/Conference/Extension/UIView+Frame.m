//
//  UIView+Frame.m
//
//  Created by heqin on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIView+Frame.h"


@implementation UIView(VDNFrame)

@dynamic ott_width, ott_height,ott_posX, ott_posY, ott_centerPos, ott_top, ott_bottom, ott_right, ott_left, ott_brPos;

- (float)ott_width
{
	return self.bounds.size.width;
}

- (float)ott_height
{
	return self.frame.size.height;
}

- (float)ott_posX
{
	return self.frame.origin.x;
}

- (float)ott_posY
{
	return self.frame.origin.y;
}

- (float)ott_top{
    return self.frame.origin.y;
}

- (float)ott_bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (float)ott_left{
    return self.ott_posX;
}

- (float)ott_right{
    return self.ott_brPos.x;
}

- (CGSize)ott_size{
    return CGSizeMake(self.ott_width, self.ott_height);
}

- (void)setOtt_size:(CGSize)size{
    self.ott_width = size.width;
    self.ott_height = size.height;
}

- (CGPoint)ott_brPos
{
	return CGPointMake([self ott_posX]+[self ott_width], [self ott_posY]+[self ott_height]);
}

- (float)ott_centerX
{
    return self.center.x;
}

- (void)setOtt_centerX:(float)centerX
{
    CGPoint centerPoint  = self.center;
    centerPoint.x = centerX;
    self.center = centerPoint;
}

- (float)ott_centerY
{
    return self.center.y;
}

- (void)setOtt_centerY:(float)centerY
{
    CGPoint centerPoint  = self.center;
    centerPoint.y = centerY;
    self.center = centerPoint;
}

- (CGPoint)centerPos
{
	return CGPointMake([self ott_width]/2, [self ott_height]/2);
}

- (void)setCenterPos:(CGPoint)pos{
    self.frame = CGRectMake(pos.x - self.ott_width/2, pos.y - self.ott_height/2, self.ott_width, self.ott_height);
}

- (void)setOtt_top:(float)top{
    [self setOtt_posY:top];
}

- (void)setOtt_bottom:(float)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (void)setOtt_width:(float)width
{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void)setOtt_height:(float)height
{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (void)setOtt_posX:(float)posx
{
	self.frame = CGRectMake(posx, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setOtt_left:(float)left{
    [self setOtt_posX:left];
}

- (void)setOtt_right:(float)right{
    [self setOtt_posX:right-self.ott_width];
}

- (void)setOtt_posY:(float)posy
{
	self.frame = CGRectMake(self.frame.origin.x, posy, self.frame.size.width, self.frame.size.height);
}

- (void)ott_centerToView:(UIView *)view
{
    [self setOtt_posX:([view ott_width] - [self ott_width])/2];
    [self setOtt_posY:([view ott_height] - [self ott_height])/2];
}

- (void)ott_centerToRect:(CGRect)rect{
    [self setOtt_posX:(rect.size.width - [self ott_width])/2];
    [self setOtt_posY:(rect.size.height - [self ott_height])/2];

}


- (void)setSet_x:(CGFloat)set_x {
    if (set_x) {
        CGRect frame = self.frame ;
        frame.origin.x =  set_x ;
        self.frame = frame ;
    }
}

- (CGFloat)set_x {
    return self.frame.origin.x ;
}

- (void)setSet_y:(CGFloat)set_y {
    if (set_y) {
        CGRect frame = self.frame ;
        frame.origin.y =  set_y ;
        self.frame = frame ;
    }
}

- (CGFloat)set_y {
    return self.frame.origin.y ;
}

- (void)setSet_witdh:(CGFloat)set_witdh {
    if (set_witdh) {
        CGRect frame = self.frame ;
        frame.size.width =  set_witdh ;
        self.frame = frame ;
    }
}

- (CGFloat)set_witdh {
    return self.frame.size.width ;
}

- (void)setSet_height:(CGFloat)set_height {
    if (set_height) {
        CGRect frame = self.frame ;
        frame.size.height =  set_height ;
        self.frame = frame ;
    }
}

- (CGFloat)set_height {
    return self.frame.size.height ;
}

@end
