//
//  ScreenHelper.h
//  ZJScreenShare
//
//  Created by starcwl on 12/3/18.
//  Copyright © 2018 zijingcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@class ScreenHelper;

NS_ASSUME_NONNULL_BEGIN

@interface ScreenHelper : NSObject <RTCPeerConnectionDelegate>
@property (nonatomic, strong) NSString *groupId;
+ (instancetype)sharedInstance;

- (void)connect;

- (void)disconnect;

- (void)didCaptureSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
