//
//  VCVideoView.h
//  webrtc-iOS-demo
//
//  Created by starcwl on 10/12/18.
//  Copyright © 2018 zijingcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>

typedef NS_ENUM(NSInteger, RTCVideoViewObjectFit) {
    /**
     * The replaced content is sized to maintain its aspect ratio while fitting
     * within the element's content box.
     */
    VCVideoViewObjectFitContain,
    /**
     * The replaced content is sized to maintain its aspect ratio while filling
     * the element's entire content box.
     */
    VCVideoViewObjectFitCover
};



NS_ASSUME_NONNULL_BEGIN

@interface VCVideoView : UIView <RTCVideoViewDelegate>
/**
 * The indicator which determines whether this {@code RTCVideoView} is to mirror
 * the video specified by {@link #videoTrack} during its rendering. Typically,
 * applications choose to mirror the front/user-facing camera.
 */

@property (nonatomic) BOOL isPresentation;
@property (nonatomic) BOOL mirror;
@property (nonatomic) BOOL isLocalView;

/**
 * In the fashion of
 * https://www.w3.org/TR/html5/embedded-content-0.html#dom-video-videowidth
 * and https://www.w3.org/TR/html5/rendering.html#video-object-fit, resembles
 * the CSS style {@code object-fit}.
 */
@property (nonatomic) RTCVideoViewObjectFit objectFit;

/**
 * The {@link RTCEAGLVideoView} which implements the actual
 * {@link RTCVideoRenderer} of this instance and which this instance fits within
 * itself so that the rendered video preserves the aspect ratio of
 * {@link #_videoSize}.
 */
@property (nonatomic, readonly) __kindof UIView<RTCVideoRenderer> *videoView;

/**
 * The {@link RTCVideoTrack}, if any, which this instance renders.
 */
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@end

NS_ASSUME_NONNULL_END
