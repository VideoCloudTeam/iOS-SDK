//
//  VCWhiteBoardView.m
//
//  Created by 李志朋 on 2019/6/26.
//

#import "VCWhiteBoardView.h"

@implementation VCWhiteBoardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIWebView *webView= [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width,  frame.size.height)];
        webView.backgroundColor = [UIColor blackColor];
        webView.scrollView.scrollEnabled = NO ;
        self.webView = webView ;
        [self addSubview:self.webView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(80, 60, 30, 30);

        [btn setImage:[[UIImage imageNamed:@"xianshi-white-board"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal] ;
        self.showSuperView = btn ;
        [self addSubview:self.showSuperView];
        
    }
    return self ;
}

@end
