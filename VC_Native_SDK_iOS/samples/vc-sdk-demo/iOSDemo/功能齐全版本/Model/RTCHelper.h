//
//  RTCHelper.h
//  linphone
//
//  Created by 李志朋 on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "VCVideoView.h"
#import <VCVideoView.h>
#import "VCMediaStat.h"
#import "Participant.h"
NS_ASSUME_NONNULL_BEGIN

@class RTCHelper ;

@protocol RTCHelperMediaDelegate <NSObject>

@optional 
- (void) RTCHelper:(RTCHelper *)helper didAddLocalView:(VCVideoView *)view ;
- (void) RTCHelper:(RTCHelper *)helper didAddView:(VCVideoView *)view uuid:(NSString *)uuid;
- (void) RTCHelper:(RTCHelper *)helper didRemoveView:(VCVideoView *)view uuid:(NSString *)uuid ;
- (void) RTCHelper:(RTCHelper *)helper didLayoutParticipants:(NSArray *)participants ;
- (void) RTCHelper:(RTCHelper *)helper didStartImage:(NSString *)shareUuid ;
- (void) RTCHelper:(RTCHelper *)helper didUpdateVideo:(NSString *)imageStr uuid:(NSString *)uuid ;
- (void) RTCHelper:(RTCHelper *)helper didUpdateImage:(NSString *)imageStr uuid:(nonnull NSString *)uuid ;
- (void) RTCHelper:(RTCHelper *)helper didStopImage:(NSString *)imageStr ;
- (void) RTCHelper:(RTCHelper *)helper didUpdateRecordAndlive:(nonnull NSDictionary *)data ;
- (void) RTCHelper:(RTCHelper *)helper didUpdateConferenceStatus:(NSDictionary *)data ;
- (void) RTCHelper:(RTCHelper *)helper didDisconnectedWithReason:(NSError *)reason ;
- (void) RTCHelper:(RTCHelper *)helper didChangeRole:(NSString *)role ;
- (void) RTCHelper:(RTCHelper *)helper didReceivedStatistics:(NSArray<VCMediaStat *> *)mediaStats ;
- (void) RTCHelper:(RTCHelper *)helper didUpdateParticipants:(NSArray *)participants ;
- (void) RTCHelper:(RTCHelper *)helper didStartWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid ;
- (void) RTCHelper:(RTCHelper *)helper didStopWhiteBoard:(NSString *)shareUrl withUuid:(NSString *)uuid;
- (void)RTCHelper:(RTCHelper *)helper didReceivedSubtitlesMessage:(NSDictionary *)subtitlesmessage;
- (void)RTCHelper:(RTCHelper *)helper didUpdateParticipant:(Participant *)participant;

@end

@protocol RTCHelperManageDelegate <NSObject>

- (void)RTCHelperDidUpdateParticipants;
- (void)RTCHelperDidUpdateRecordAndlive;
- (void)RTCHelperDidUpdateConferenceStatus;
- (void)RTCHelper:(RTCHelper *)helper didDisconnectedWithReason:(NSError *)reason;
-  (void)RTCHelperDidUpdateParticipant: (Participant *)participant;



@end

@interface RTCHelper : NSObject

@property(nonatomic, weak) id <RTCHelperMediaDelegate> media_delegate ;
@property(nonatomic, weak) id <RTCHelperManageDelegate> manage_delegate ;
@property (nonatomic, strong, readonly ) NSArray *participants ;
@property (nonatomic, readonly ) BOOL conf_is_lock ;
@property (nonatomic, readonly ) BOOL conf_is_mute_guest ;
@property (nonatomic, readonly ) BOOL conf_is_open_record ;
@property (nonatomic, readonly ) BOOL conf_is_open_living ;
@property (nonatomic, strong ) NSString *shareUrl ;
@property (nonatomic, strong ) NSString *shareName ;

@property (nonatomic, strong ) NSDictionary *shareModel ;

- (instancetype)init ;


@end

NS_ASSUME_NONNULL_END
