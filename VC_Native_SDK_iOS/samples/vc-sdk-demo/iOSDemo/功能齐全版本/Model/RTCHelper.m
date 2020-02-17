//
//  RTCHelper.m
//  linphone
//
//  Created by 李志朋 on 2019/4/10.
//

#import "RTCHelper.h"
#import "VCRtcModule.h"

@interface RTCHelper () <VCRtcModuleDelegate>

@property (nonatomic , strong) VCRtcModule *vcrtc ;

@property (nonatomic, strong, readwrite ) NSArray *participants ;

@property (nonatomic, readwrite ) BOOL conf_is_lock ;
@property (nonatomic, readwrite ) BOOL conf_is_mute_guest ;
@property (nonatomic, readwrite ) BOOL conf_is_open_record ;
@property (nonatomic, readwrite ) BOOL conf_is_open_living ;

@end


@implementation RTCHelper

- (instancetype)init {
    if (self = [super init]) {
        self.vcrtc = [VCRtcModule sharedInstance];
        self.vcrtc.delegate = self;
        self.conf_is_lock = NO;
        self.conf_is_mute_guest = NO;
        self.conf_is_open_record = NO;
        self.conf_is_open_living = NO;
    }
    return self ;
}


#pragma mark - vcrtc delegate

- (void)VCRtc:(VCRtcModule *)module didAddChannelViewController:(UIViewController *)view {
    
}

- (void)VCRtc:(VCRtcModule *)module didDisconnectedWithReason:(NSError *)reason {
    if ([_manage_delegate respondsToSelector:@selector(RTCHelper:didDisconnectedWithReason:)]) {
        [_manage_delegate RTCHelper:self didDisconnectedWithReason:reason];
    }
    
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didDisconnectedWithReason:)]) {
        [_media_delegate RTCHelper:self didDisconnectedWithReason:reason];
    }
}

- (void)VCRtc:(VCRtcModule *)module didAddView:(VCVideoView *)view uuid:(NSString *)uuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didAddView:uuid:)]) {
        [_media_delegate RTCHelper:self didAddView:view uuid:uuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didRemoveView:uuid:)]) {
        [_media_delegate RTCHelper:self didRemoveView:view uuid:uuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didAddLocalView:(VCVideoView *)view {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didAddLocalView:)]) {
        [_media_delegate RTCHelper:self didAddLocalView:view];
    }
}

//- (void)VCRtc:(VCRtcModule *)module didAddParticipant:(Participant *)participant {
//
//}

- (void)VCRtc:(VCRtcModule *)module didUpdateParticipant:(Participant *)participant {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateParticipant:)]) {
        [_media_delegate RTCHelper:self didUpdateParticipant:participant];
    }
    if ([_manage_delegate respondsToSelector:@selector(RTCHelperDidUpdateParticipant:)]) {
        [_manage_delegate RTCHelperDidUpdateParticipant:participant];
    }
}

//- (void)VCRtc:(VCRtcModule *)module didRemoveParticipant:(Participant *)participant {
//
//}

- (void)VCRtc:(VCRtcModule *)module didReceivedMessage:(NSDictionary *)message {
    
}

- (void)VCRtc:(VCRtcModule *)module didReceivedStageVoice:(NSArray *)voices {
    
}

- (void)VCRtc:(VCRtcModule *)module didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didReceivedStatistics:)]) {
        [_media_delegate RTCHelper:self didReceivedStatistics:mediaStats];
    }
}

// by add li
- (void)VCRtc:(VCRtcModule *)module didLayoutParticipants:(NSArray *)participants {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didLayoutParticipants:)]) {
        [_media_delegate RTCHelper:self didLayoutParticipants:participants];
    }
}

- (void)VCRtc:(VCRtcModule *)module didStartImage:(NSString *)shareUuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didStartImage:)]) {
        [_media_delegate RTCHelper:self didStartImage:shareUuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didUpdateImage:(NSString *)imageStr uuid:(NSString *)uuid{
    NSLog(@"imageStr = %@", imageStr);
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateImage:uuid:)]) {
        [_media_delegate RTCHelper:self didUpdateImage:imageStr uuid:uuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didUpdateVideo:(NSString *)imageStr uuid:(NSString *)uuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateVideo:uuid:)]) {
        [_media_delegate RTCHelper:self didUpdateVideo:imageStr uuid:uuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didStopImage:(NSString *)imageStr {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didStopImage:)]) {
        [_media_delegate RTCHelper:self didStopImage:imageStr];
    }
}

- (void)VCRtc:(VCRtcModule *)module didUpdateRecordAndlive:(NSDictionary *)data {
    
    if (!self.vcrtc.isShiTong) {
        self.conf_is_open_record = [data[@"isrecord"] boolValue];
        self.conf_is_open_living = [data[@"isliving"] boolValue];
    }
    
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateRecordAndlive:)]) {
        [_media_delegate RTCHelper:self didUpdateRecordAndlive:data];
    }
    
    if ([_manage_delegate respondsToSelector:@selector(RTCHelperDidUpdateRecordAndlive)]) {
        [_manage_delegate RTCHelperDidUpdateRecordAndlive];
    }
}

- (void)VCRtc:(VCRtcModule *)module didUpdateLayout:(NSDictionary *)data  {
    
}

- (void)VCRtc:(VCRtcModule *)module didUpdateConferenceStatus:(NSDictionary *)data {
    if (self.vcrtc.isShiTong) {
        if (!data) data = @{} ;
        if ([data.allKeys containsObject:@"record_status"]) {
            self.conf_is_open_record = [data[@"record_status"] boolValue];
        }
        if ([data.allKeys containsObject:@"live_status"]) {
            self.conf_is_open_living = [data[@"live_status"] boolValue];
        }
    }
    
    if ([data.allKeys containsObject:@"guests_muted"]) {
        self.conf_is_mute_guest = [data[@"guests_muted"] boolValue];
    }
    if ([data.allKeys containsObject:@"locked"]) {
        self.conf_is_lock = [data[@"locked"] boolValue];
    }
    
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateConferenceStatus:)]) {
        [_media_delegate RTCHelper:self didUpdateConferenceStatus:data];
    }
    
    if ([_manage_delegate respondsToSelector:@selector(RTCHelperDidUpdateConferenceStatus)]) {
        [_manage_delegate RTCHelperDidUpdateConferenceStatus];
    }
}

- (void)VCRtc:(VCRtcModule *)module didUpdateParticipants:(NSArray *)participants {
    self.participants = participants ;
    
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didUpdateParticipants:)]) {
        [_media_delegate RTCHelper:self didUpdateParticipants:participants];
    }
    
    if ([_manage_delegate respondsToSelector:@selector(RTCHelperDidUpdateParticipants)]) {
        [_manage_delegate RTCHelperDidUpdateParticipants];
    }
}

- (void)VCRtc:(VCRtcModule *)module didChangeRole:(NSString *)role {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didChangeRole:)]) {
        [_media_delegate RTCHelper:self didChangeRole:role];
    }
}

- (void)VCRtc:(VCRtcModule *)module didStartWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didStartWhiteBoard:withUuid:)]) {
        [_media_delegate RTCHelper:self didStartWhiteBoard:shareUrl withUuid:uuid];
    }
}

- (void)VCRtc:(VCRtcModule *)module didStopWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didStopWhiteBoard:withUuid:)]) {
        [_media_delegate RTCHelper:self didStopWhiteBoard:shareUrl withUuid:uuid];
    }
}


- (void)VCRtc:(VCRtcModule *)module didReceivedSubtitlesMessage:(NSDictionary *)subtitlesmessage {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didReceivedSubtitlesMessage:)]) {
        [_media_delegate RTCHelper:self didReceivedSubtitlesMessage:subtitlesmessage];
    }
}
- (void)VCRtc:(VCRtcModule *)module didAddParticipant:(Participant *)participant {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didAddParticipant:)]) {
        [_media_delegate RTCHelper:self didAddParticipant:participant];
    }
}

- (void)VCRtc:(VCRtcModule *)module didRemoveParticipant:(nonnull Participant *)participant {
    if ([_media_delegate respondsToSelector:@selector(RTCHelper:didRemoveParticipant:)]) {
        [_media_delegate RTCHelper:self didRemoveParticipant:participant];
    }
}
@end
