//
//  UINavigationController+Category.m
//  linphone
//
//  Created by 李志鹏 on 16/10/21.
//
//

#import "UINavigationController+Category.h"

@implementation UINavigationController (Category)

-(void)setBackBtnItem{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 80, 20);
    [btn setTitle:@"返回"];
    [btn setTintColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(reBackVC) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
}

-(void)reBackVC{
    [self popViewControllerAnimated:YES];
}

@end
