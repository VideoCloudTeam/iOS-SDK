//
//  VideoViewModel.m
//  iOSDemo
//
//  Created by mac on 2019/7/9.
//  Copyright © 2019 mac. All rights reserved.
//

#import "VideoViewModel.h"

@implementation VideoViewModel
- (instancetype)initWithuuid: (NSString *)uuid videoView: (VCVideoView *)videoView participant: (Participant *)participant
{
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.videoView = videoView;
        self.participant = participant;
    }
    return self;
}

@end
