//
//  ZjDocumentPickerViewController.m
//  ZJRTC
//
//  Created by 李志朋 on 2019/2/21.
//  Copyright © 2019年 zijingcloud. All rights reserved.
//

#import "DocumentPickerViewController.h"

@interface DocumentPickerViewController ()

@end

@implementation DocumentPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarStyle:UIBarStyleDefault];
    [bar setTintColor:[UIColor colorWithRed:14/255.0 green:140/255.0 blue:238/255.0 alpha:1.0]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault ;
}

- (BOOL)prefersStatusBarHidden {
    return NO ;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
