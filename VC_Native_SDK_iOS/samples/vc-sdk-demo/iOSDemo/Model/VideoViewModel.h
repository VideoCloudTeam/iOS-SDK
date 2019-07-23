//
//  VideoViewModel.h
//  iOSDemo
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoViewModel : NSObject
/** 参会者唯一标识符 */
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) VCVideoView *videoView;
@property (nonatomic, strong) Participant *participant;
- (instancetype)initWithuuid: (NSString *)uuid videoView: (VCVideoView *)videoView participant: (Participant *)participant;
@end

NS_ASSUME_NONNULL_END
