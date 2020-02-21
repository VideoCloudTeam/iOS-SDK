//
//  UIView+Frame.h
//
//  Created by heqin on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView(VDNFrame)

@property (nonatomic, assign) float ott_width;
@property (nonatomic, assign) float ott_height;
@property (nonatomic, assign) float ott_posX;
@property (nonatomic, assign) float ott_posY;
@property (nonatomic, assign) CGPoint ott_centerPos;
@property (nonatomic, assign) float ott_top;
@property (nonatomic, assign) float ott_bottom;
@property (nonatomic, assign) float ott_left;
@property (nonatomic, assign) float ott_right;
@property (nonatomic, assign) CGSize ott_size;
@property (nonatomic, assign) float ott_centerX;
@property (nonatomic, assign) float ott_centerY;
@property (nonatomic, assign) CGPoint ott_brPos;

@property (nonatomic, assign) CGFloat set_x;
@property (nonatomic, assign) CGFloat set_y;
@property (nonatomic, assign) CGFloat set_witdh;
@property (nonatomic, assign) CGFloat set_height;

//- (void)ott_centerToView:(UIView *)view;
//- (void)ott_centerToRect:(CGRect)rect;
- (float)ott_width;


@end
