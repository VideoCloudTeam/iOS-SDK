//
//  BaseInMeetingVC.h
//  linphone
//
//  Created by mac on 2019/9/11.
//

#import <UIKit/UIKit.h>
#import "Participant.h"
#import "MediaDataHandle.h"
#import "YYText.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SharingStauts){
    SharingStautsNone ,//会中没有分享
    SharingStautsRemote,//远端在分享
    SharingStautsLocal,//本地在分享
    SharingStautsEx,//本地屏幕在分享
    SharingStautsRemoteToLocal,//本地在分享,被远端抢断
    SharingStautsRemoteToEx ,//本地屏幕在分享,被远端抢断
    SharingStautsLocalToRemote ,//远端在分享,被本地抢断
    SharingStautsLocalToEx ,//本地屏幕在分享,被本地抢断
    SharingStautsExToRemote ,//远端在分享,被本地屏幕抢断
    SharingStautsExToLocal,//本地在分享,被本地屏幕抢断
    SharingStautsVideo//分享成视频
};

@class ConferenceHeaderView;
@class VCRtcModule;
@class RTCHelper;



@interface BaseInMeetingVC : UIViewController
@property(nonatomic, strong) NSString *channel;
@property (nonatomic, assign) BOOL isSupportLive ;
@property (nonatomic, assign) BOOL isSupportRecord ;
@property (nonatomic, assign) BOOL selectMute ;
@property (nonatomic, assign) BOOL incomming;
@property (nonatomic, strong) NSDictionary *shareUrl;

/** 通话质量信息 */
@property (weak, nonatomic) IBOutlet UIButton *netBtn;
/** 会议室号 */
@property (weak, nonatomic) IBOutlet UILabel *meetingRoomNumLab;
/** 时间长度 */
@property (weak, nonatomic) IBOutlet UILabel *timeLengthLab;
/** 顶部视图 */
@property (weak, nonatomic) IBOutlet UIView *topView;

/** 麦克风静音 */
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
/** 关闭本端视频 */
@property (weak, nonatomic) IBOutlet UIButton *closeLocalVideoBtn;
/** 只有音频 (专属云) */
@property (weak, nonatomic) IBOutlet UIButton *onlyAudioBtn;

/** 分享 */
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
/** 参会人 */
@property (weak, nonatomic) IBOutlet UIButton *manageBtn;
/** 更多 */
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
/** 参会人数 */
@property (weak, nonatomic) IBOutlet UILabel *participantCountLab;
/** 底部视图 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;

/** 网络质量 */
@property (weak, nonatomic) IBOutlet UITableView *netQuailtyTable;
/** 点击隐藏TopView bottomView */
@property (weak, nonatomic) IBOutlet UIButton *hiddenBtn;

/** 通话质量信息 */
@property (weak, nonatomic) IBOutlet UIView *netQuaityView;
/** 通话质量信息头部视图 */
@property (nonatomic, strong) IBOutlet  ConferenceHeaderView *headerView;
/** 字幕 */
@property (nonatomic, strong) IBOutlet YYLabel * subtitleLab;

@property (weak, nonatomic) IBOutlet UIButton *handCountBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *handCountToBtm;

@property (nonatomic, strong) VCRtcModule *vcrtc;
@property (nonatomic, strong) RTCHelper *rtcHelper;
@property(nonatomic, strong) NSString *callName;

@property (nonatomic, strong) NSMutableArray *streamOnwers;
//@property (nonatomic, strong) UIView *onlyAudioView;
@property (nonatomic, strong) NSMutableArray *networkArr;
@property (nonatomic, assign) int selectImageIndex;

@property (nonatomic, strong, nullable) NSTimer *timeLengthTimer;
@property (nonatomic, strong) NSString *shareUuid;
@property (nonatomic, strong) NSArray *selectImages;
@property (nonatomic, strong, nullable) NSTimer *hiddenTimer;
@property (nonatomic, assign) BOOL isMute;
@property (nonatomic, assign) BOOL isLocalMute;


/**
 视屏质量
 
 @param stats 质量统计数据
 @param rosterList 会中参会人
 @param uuid 用户自己的ID
 @param userChannel 使用的地方
 */
- (void)reloadStats:(NSArray *)stats rosterList: (NSMutableDictionary<NSString *, Participant *>*)rosterList userSelfUUID: (NSString *)uuid userChannel: (UserChannel)userChannel;
- (void)updatePresenterFrame;
- (void)goSettingPermissions:(NSString *)title
                  andMessage:(NSString *)message
                     success:(void (^)(bool))success;
@end

NS_ASSUME_NONNULL_END
