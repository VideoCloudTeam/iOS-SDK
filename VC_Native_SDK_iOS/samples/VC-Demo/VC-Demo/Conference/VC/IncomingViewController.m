//
//  IncomingViewController.m
//  VC-Demo
//
//  Created by 李志朋 on 2019/7/9.
//  Copyright © 2019 李志朋. All rights reserved.
//

#import "IncomingViewController.h"

@interface IncomingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *addressLable;

@end

@implementation IncomingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.addressLable.text = self.incomingInfo[@"conference_alias"] ;
    
}

- (IBAction)refusedToCall:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"notificationRefused" object:self.incomingInfo];
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (IBAction)receiveCall:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"notificationReceive" object:self.incomingInfo];
    [self dismissViewControllerAnimated:YES completion:nil] ;
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
