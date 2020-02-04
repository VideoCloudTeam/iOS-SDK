//
//  ManageNavigationController.m
//
//  Created by 李志朋 on 2019/4/15.
//

#import "ManageNavigationController.h"

@interface ManageNavigationController ()

@end

@implementation ManageNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight ;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight ;
}

@end
