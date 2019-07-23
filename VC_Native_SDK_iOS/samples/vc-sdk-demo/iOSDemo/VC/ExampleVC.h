//
//  ViewController.h
//  iOSDemo
//
//  Created by mac on 2019/6/26.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleVC : UIViewController
/** 服务器地址 */
@property (nonatomic, copy) NSString *serverString;
/** 会议室号 */
@property (nonatomic, copy) NSString *meetingNumString;
/** 参会密码 */
@property (nonatomic, copy) NSString *passwordString;
/** 是否为多流模式 多流模式清晰度较高 */
@property (nonatomic, assign) BOOL isMultistream;
/** 公有云还是专属云 */
@property (nonatomic, assign) BOOL  isPrivateCloud;
@end

