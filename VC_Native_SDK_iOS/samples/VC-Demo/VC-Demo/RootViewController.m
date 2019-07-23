//
//  RootViewController.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/4.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "RootViewController.h"
#import "SimpleViewController.h"
#import "DefaultViewController.h"
#import "PLoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Demo" ;
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)integration:(id)sender {
    SimpleViewController *simpleVc = [[SimpleViewController alloc] init];
    [self.navigationController pushViewController:simpleVc animated:YES];
}

- (IBAction)defaultview:(id)sender {
    DefaultViewController *defaultVc = [[DefaultViewController alloc] init];
    [self.navigationController pushViewController:defaultVc animated:YES];
}

- (IBAction)loginview:(id)sender {
    PLoginViewController *loginVc = [[PLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVc animated:YES] ;
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
