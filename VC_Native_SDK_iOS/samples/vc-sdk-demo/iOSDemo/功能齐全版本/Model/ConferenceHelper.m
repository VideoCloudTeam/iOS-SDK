//
//  ConferenceHelper.m
//
//  Created by 李志朋 on 2019/3/5.
//  Copyright © 2019年 zijingcloud. All rights reserved.
//

#import "ConferenceHelper.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VCRtcModule.h"
#import "VCMediaStat.h"
#import "Participant.h"
#import "TZImagePickerController.h"
#import "DocumentPickerViewController.h"
#import "NotRecordedController.h"
#import "UIImage+PDF.h"
#import "NSDate+Utilities.h"
#import "VCVideoView.h"
#import "VCPresentionView.h"
#import "UIView+YCExtension.h"

#import <sys/sysctl.h>
#import <mach/mach.h>

#import "MXActionSheet.h"
#import "ActionModel.h"
#import "RTCHelper.h"


#import "AFNetworkReachabilityManager.h"
#import "NSMutableAttributedString+VCAttributedString.h"
#import "UIView+AddViewProperty.h"
#import "UIImage+GIF.h"
#import "NameView.h"

@interface ConferenceHelper () <UIDocumentPickerDelegate,TZImagePickerControllerDelegate,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout,VCPresentionViewDelegate,VCRtcModuleDelegate>

@property (nonatomic, strong) VCRtcModule *vcrtc ;
@property (nonatomic, strong) NSTimer *netTimeoutTimer ;
@property (nonatomic, strong) NSString *networkStatus ;
@property (nonatomic, assign) NSTimeInterval beganInterval ;

@property (nonatomic, strong) UIView *bigView ;
@property (nonatomic, strong) UIScrollView *scrollView ;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *showImagesOrURLs;

@end

@implementation ConferenceHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.vcrtc = [VCRtcModule sharedInstance];
        self.beganInterval = 0 ;
        self.networkStatus = @"none";
        self.changeIsBackground = NO ;
    }
    return self ;
}

#pragma mark - helper 主要监听程序中出现的状态问题。
- (void)conf_registerApps {
    [self conf_registerAudioStatus];
    [self conf_registerNetworkChange];
    [self conf_registerForegroundFunc];
    [self conf_registerBackgroundFunc];
    [self conf_registerTerminateFunc];
}

// 监听网络变化
- (void) conf_registerNetworkChange {    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStateChange:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    //    Reachability *reach = [Reachability reachabilityForInternetConnection];
    //    [reach startNotifier];
}

// 监听音频状态
- (void) conf_registerAudioStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStateChange:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
}

// 监听程序进入前台
- (void) conf_registerBackgroundFunc {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

// 监听程序进入后台
- (void) conf_registerForegroundFunc {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

// 监听程序被结束
- (void) conf_registerTerminateFunc {
    // 监听程序退出的状态，解决程序退出后，连接与会者没有退出会议。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification
                                               object:nil];
}

// 移除监听程序
- (void)conf_removeAllRegister {
    self.networkStatus = @"none" ;
    firstStatus = YES ;
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    [[NSNotificationCenter defaultCenter]removeObserver:self ];
}


- (void)audioStateChange:(NSNotification *)sender {
    // key - AVAudioSessionInterruptionTypeKey : 被其他应用打断音频
    if ([sender.userInfo[@"AVAudioSessionInterruptionTypeKey"] intValue] == AVAudioSessionInterruptionTypeBegan) {
        [self audioInterriptionTypeBegan];
    } else if( [sender.userInfo[@"AVAudioSessionInterruptionTypeKey"] intValue] == AVAudioSessionInterruptionTypeEnded) {
        [self audioInterriptionTypeEnded];
    }
}

- (void)audioInterriptionTypeBegan {
    // 因为考虑到此时可能应用不在后台运行，所以获取当前的时间戳作为被断开的开始标记。
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    self.beganInterval = [date timeIntervalSince1970];
    NSLog(@"[conference][helper][audio][began] - timestamp:%f",self.beganInterval);
}

- (void) audioInterriptionTypeEnded {
    // 获取结束时间的时间戳和开始时间的时间戳作比较。
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval endInterval = [date timeIntervalSince1970];
    NSLog(@"[conference][helper][audio][ended] - timestamp:%f",endInterval);
    
    // 时间超过两分钟，退出会议，发出通知，告知用户“通话被其他应用中断”
    if (endInterval >= self.beganInterval + 120) {
        [self.vcrtc exitChannelSuccess:^(id  _Nonnull response) {}
                               failure:^(NSError * _Nonnull er) {}];
        [self myDismissViewControllerAnimated:YES  completion:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kAudioInterriptionEndMeeting
                                                           object:nil];
    } else {
        // 直接回到会议室，不做任何操作。 系统会默认进入会中
    }
}


static bool firstStatus = YES ;

- (void)networkStateChange:(NSNotification *)sender {
    if (firstStatus) {
        firstStatus = NO ;
        return ;
    }
    AFNetworkReachabilityManager *reach = sender.object;
    
    if (![self.networkStatus isEqualToString:[self strNetworkStatus:reach.networkReachabilityStatus]]) {
        self.networkStatus = [self strNetworkStatus:reach.networkReachabilityStatus] ;
        if ([[self strNetworkStatus:reach.networkReachabilityStatus] isEqualToString:@"not"]) {
            NSLog(@"[conference][helper][network][status] - current status is not");
            if (@available(iOS 10.0, *)) {
                self.netTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:40 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    NSLog(@"[conference][helper][network][status] - network is not over 40s");
                    [self myDismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNetworkTimeoutEndMeeting object:nil];
                    [self.vcrtc enableRecordSuccess:^(id  _Nonnull response) {}
                                            failure:^(NSError * _Nonnull er) {}];
                }];
            } else {
                // Fallback on earlier versions
            }
        } else {
            NSLog(@"[conference][helper][network][status] - current status is %@=====%d",self.networkStatus,reach.reachable);
            if (self.netTimeoutTimer) {
                [self.netTimeoutTimer invalidate];
                self.netTimeoutTimer = nil ;
            }
            // 当app 出现在后台的时候，如果重新建立音视频，会出现音频断开，等等问题。
            if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ) {
                self.changeIsBackground = YES;
            } else {
                self.changeIsBackground = NO;
                [self.vcrtc reconstructionMediaCall];
            }
        }
    }
    self.networkStatus = [self strNetworkStatus:reach.networkReachabilityStatus] ;
}

- (NSString *)strNetworkStatus:(AFNetworkReachabilityStatus )status {
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) return @"wifi" ;
    else if (status == AFNetworkReachabilityStatusReachableViaWWAN) return @"wwan" ;
    else return @"not" ;
}

- (void)appHasGoneInForeground:(NSNotification *)sender {
    if(self.needCloseVideo) {
        [self.vcrtc videoEnable:YES];
    }
    NSLog(@"[conference][helper][foreground]");
}

- (void)appHasGoneInBackground:(NSNotification *)sender {
    if(self.needCloseVideo) {
        [self.vcrtc videoEnable:NO];
    }
    NSLog(@"[conference][helper][foreground]");
}

- (void)applicationWillTerminate:(NSNotification *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConferenceEnd" object:nil];
    [self.vcrtc exitChannelSuccess:^(id  _Nonnull response) {
        NSLog(@"[conference][helper][application][terminate] - exit conf successful");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"[conference][helper][application][terminate] - exit conf failure");
    }];
}

- (void)myDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if([_delegate respondsToSelector:@selector(conferenceHelper:dismissViewControllerAnimated:completion:)]){
        [_delegate conferenceHelper:self dismissViewControllerAnimated:flag completion:completion];
    }
}

#pragma mark - helper 主要处理获取app 资源文件
- (void)conf_alertGetResources {
    NSArray<ActionModel *> *otherButtonTitles = nil;
    NSMutableArray *muteOtherButtonTitles = [NSMutableArray array] ;
    
    ActionModel *wxModel = [[ActionModel alloc] initWithName:@"照片" withUserTag:@"photo"];
    [muteOtherButtonTitles addObject:wxModel];
    ActionModel *booksModel = [[ActionModel alloc] initWithName:@"屏幕" withUserTag:@"screen"];
    [muteOtherButtonTitles addObject:booksModel];
    
    ActionModel *linkModel = [[ActionModel alloc] initWithName:@"iCloud" withUserTag:@"cloud"];
    [muteOtherButtonTitles addObject:linkModel];
    
    
    
    otherButtonTitles = [muteOtherButtonTitles copy];
    
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:otherButtonTitles selectedBlock:^(NSInteger index, NSString *userTag) {
        if ([userTag isEqualToString:@"photo"]) {
            [self conf_loadPhotoResources];
        } else if ([userTag isEqualToString:@"screen"]) {
            [self conf_loadNoRecording];
        } else if ([userTag isEqualToString:@"cloud"]) {
            [self conf_loadDocumentResources];
        } else if ([userTag isEqualToString:@"whiteBoard"]) {
            [self conf_openWhiteBoard];
        }
    }];
}

- (void)conf_openWhiteBoard {
    [self.vcrtc shareToWhiteOpen:YES success:^(id  _Nonnull response) {
        
    } failure:^(NSError * _Nonnull er) {
        
    }];
}

- (void)conf_loadPhotoResources {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:6 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowPickingOriginalPhoto = NO;
    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if ([weakSelf.delegate respondsToSelector:@selector(conferenceHelper:didPhotoResource:)]) {
            [weakSelf.delegate conferenceHelper:self didPhotoResource:photos];
        }
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.preController presentViewController:imagePickerVc animated:true completion:nil];
}

- (void)conf_loadDocumentResources {
    DocumentPickerViewController *documentPicker = [[DocumentPickerViewController alloc]initWithDocumentTypes:@[@"public.image",@"com.adobe.pdf"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.preController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc]init];
    __block NSError *error ;
    [coordinator coordinateReadingItemAtURL:url options:NSFileCoordinatorReadingResolvesSymbolicLink error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        NSString *fileType = [[[newURL lastPathComponent] componentsSeparatedByString:@"."]lastObject];
        NSArray *arr ;
        if ([[fileType lowercaseString] isEqualToString:@"pdf"]) {
            arr = [self extractJPGsFromPDFWithPath:newURL.absoluteString];
        } else {
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            UIImage *image = [UIImage imageWithData:data];
            arr = @[image];
        }
        if ([_delegate respondsToSelector:@selector(conferenceHelper:didPhotoResource:)]) {
            [_delegate conferenceHelper:self didPhotoResource:arr];
        }
    }];
    [url stopAccessingSecurityScopedResource];
}

- (NSArray *) extractJPGsFromPDFWithPath:(NSString *)pdfPath {
    NSURL *pathURL = [NSURL URLWithString:pdfPath];
    pdfPath = [pathURL path];
    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
    if (!fileExists) return @[];
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:&error];
    if (error) return @[];
    if ([attributes objectForKey:NSFileType] == NSFileTypeDirectory) return @[];
    NSInteger pages = [PDFView pageCountForURL:pathURL];
    for(NSInteger page = 1; page <= pages; page++) {
        UIImage *image = [UIImage originalSizeImageWithPDFURL:pathURL atPage:page];
        //        image = [self scaleToFill1280W720H:image];
        NSString *filePath = [self getRandomDatePathAtPage:page filetype:@"jpg"];
        NSData *imageData = UIImageJPEGRepresentation(image,1);
        BOOL success = [imageData writeToFile:filePath atomically:NO];
        [pathArray addObject:image];
        if(!success) return @[];
    }
    return [pathArray copy];
}

- (UIImage *)scaleToFill1280W720H:(UIImage *)image {
    CGFloat const longSide = 1280;
    CGFloat const shortSide = 720;
    UIImage *newImage = image;
    CGSize size = image.size;
    if(MAX(size.width, size.height) > longSide || MIN(size.width, size.height) > shortSide){
        CGFloat longFactor = longSide / MAX(size.width, size.height);
        CGFloat shortFactor = shortSide / MIN(size.width, size.height);
        CGFloat factor = MIN(longFactor, shortFactor);
        CGSize newSize = CGSizeMake(size.width * factor, size.height * factor);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return  newImage;
}

- (NSString *)getRandomDatePathAtPage:(NSInteger)page filetype:(NSString *)filetype {
    NSDate *now = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@_%ld.%@",[now stringWithFormat:@"YYYYMMddHHmmss"], (long)page, filetype];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)conf_loadNoRecording {
    if (@available(iOS 12.0, *)) {
        if ([_delegate respondsToSelector:@selector(conferenceHelper:didRecordTitleView:)]) {
            [_delegate conferenceHelper:self didRecordTitleView:YES];
        }
    } else {
        NotRecordedController *notRecordC = [[NotRecordedController alloc]init];
        notRecordC.videoUri = notRecordC.videoUri = @[@"01FirstSet",@"02StartRecord"];
        notRecordC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.preController presentViewController:notRecordC animated:NO completion:nil];
    }
}

#pragma mark - helper 主要处理会中控制
- (void)conf_doExitChannel {
    //    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    
}

- (void)conf_errorExitChannel:(NSString *)errorStr {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"errorInforDismissControl" object:@{@"reason":errorStr}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConferenceEnd" object:nil];
    [self.vcrtc exitChannelSuccess:^(id  _Nonnull response) {
    } failure:^(NSError * _Nonnull er) {
    }];
    [self myDismissViewControllerAnimated:YES completion:nil];
}

- (void)conf_toggleLayoutTag:(NSInteger)tag {
    [self.vcrtc updateLayoutHost:[self layoutIntToString:tag]
                           guest:[self layoutIntToString:tag]
                  conferenceType:VCConferenceTypeMeeting
                         success:^(id  _Nonnull response) {}
                         failure:^(NSError * _Nonnull er) {}];
}

- (NSString *)layoutIntToString:(NSInteger )tag {
    if (tag == 0 || tag == 5) return @"1:0";
    else if(tag == 1 || tag == 6) return @"4:0";
    else if(tag == 2 || tag == 7) return @"1:7";
    else if(tag == 3 || tag == 8) return @"1:21";
    else if(tag == 4 || tag == 9) return @"2:21";
    else return @"1:0";
}

- (void)conf_toggleRecordEnable:(BOOL)enable {
    if (enable) {
        [self.vcrtc enableRecordSuccess:^(id  _Nonnull response) {
            NSLog(@"开启录制成功");
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"开启录制失败");
        }];
    } else {
        [self.vcrtc disableRecordSuccess:^(id  _Nonnull response) {
            NSLog(@"关闭录制成功");
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"关闭录制失败");
        }];
    }
}

- (void)conf_toggleLivingEnable:(BOOL)enable {
    if (enable) {
        [self.vcrtc enableLiveSuccess:^(id  _Nonnull response) {
            NSLog(@"开启直播成功");
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"开启直播成功");
        }];
    } else {
        [self.vcrtc disableLiveSuccess:^(id  _Nonnull response) {
            NSLog(@"关闭直播成功");
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"关闭录制失败");
        }];
    }
}

# pragma mark - 分享

- (void)conf_setShareInfo:(NSDictionary *)info block:(void (^)(NSString *name))block {
    [self requestUrl:info block:block];
}

- (void)requestUrl:(NSDictionary *)info block:(void (^)(NSString *name))block {
}


# pragma mark - view - model

- (UIView *)conf_reloadView:(BOOL)isBig localCutClose:(BOOL)isClose withOwner:(NSMutableDictionary *)viewOwner withIndex:(NSInteger )index withSize:(CGSize )size streamCount:(NSInteger )count {
    return isBig ? [self conf_reloadBigViewClose:isClose withOwner:viewOwner withIndex:index withSize:size streamCount:count] :
    [self conf_reloadSmallViewClose:isClose withOwner:viewOwner withIndex:index withSize:size] ;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.bigView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.bigView ;
}

// 主屏画面视频展示。
- (UIView *)conf_reloadBigViewClose:(BOOL)isClose withOwner:(NSMutableDictionary *)viewOwner withIndex:(NSInteger )index withSize:(CGSize )size streamCount:(NSInteger )count{
    // 视频 view 容器
    CGFloat superViewWidth = size.width ;
    CGFloat superViewHeight = size.height ;
    BOOL boundsTo = superViewWidth  > superViewHeight * 16 / 9.0;
    CGFloat viewWidth = ( boundsTo ? superViewHeight * 16 / 9.0 : superViewWidth  );
    CGFloat viewHeight = viewWidth * 9 / 16.0 ;
    
    CGRect startFrame = CGRectMake(0 , 0 , 0 , 0 );
    if ([viewOwner.allKeys containsObject:@"frame"]) {
        startFrame = CGRectMake( 0 , 0 , superViewWidth , superViewHeight )  ;
    }
    
    UIView *bigView = [[UIView alloc]initWithFrame:startFrame];
    
    bigView.backgroundColor = [UIColor blackColor] ;
    //  背景图片
    UIImageView *imageView = [self manage_loadImageView:isClose forFrame:CGRectMake(0, 0, startFrame.size.width, startFrame.size.height) ];
    
    // 视频 view
    VCVideoView *view = viewOwner[@"view"] ;
    
    if ( !( [self approximatelyEqualValue1:viewWidth value2:startFrame.size.width] && [self approximatelyEqualValue1:viewHeight value2:startFrame.size.height] ) ) {
        //        imageView.hidden = YES ;
    }
    
    view.objectFit =  !view.isPresentation ? VCVideoViewObjectFitCover : VCVideoViewObjectFitContain ;
    view.frame =  CGRectMake(0, 0, startFrame.size.width, startFrame.size.height) ;
    UIView *bigViewZoom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    bigViewZoom.center = CGPointMake(superViewWidth /2.0, superViewHeight /2.0);
    
    //    [UIView animateWithDuration:0.6 animations:^{
    bigView.frame = CGRectMake( 0 , 0 , superViewWidth , superViewHeight ) ;
    imageView.frame = CGRectMake(0, 0, bigViewZoom.frame.size.width, bigViewZoom.frame.size.height);
    view.frame = CGRectMake(0, 0, bigViewZoom.frame.size.width, bigViewZoom.frame.size.height) ;
    //    } completion:^(BOOL finished) {
    //        imageView.hidden = NO ;
    //    }];
    
    UIScrollView *scrollView = [self manage_loadScrollView:bigView.frame];
    bigViewZoom.backgroundColor = [UIColor blackColor];
    [bigViewZoom addSubview:imageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, bigView.frame.size.width, bigView.frame.size.height) ;
    [btn addTarget:self action:@selector(btnTouchOne:forEvent:) forControlEvents:UIControlEventTouchDown];
    btn.tag = index ;
    [btn addTarget:self action:@selector(manage_clickStick:) forControlEvents:UIControlEventTouchDownRepeat];
    
    if (!isClose) {
        [bigViewZoom addSubview:view];
    }
    [bigViewZoom addSubview:btn];
    [scrollView addSubview:bigViewZoom];
    
    self.bigView = bigViewZoom ;
    self.scrollView = scrollView ;
    if ([self.vcrtc.uuid isEqualToString:viewOwner[@"uuid"]]) {
        [bigView addSubview:bigViewZoom];
    } else {
        [bigView addSubview:scrollView];
    }
    
    CGRect frame = bigView.frame ;
    NSArray *frameArr = @[[NSNumber numberWithFloat:frame.origin.x],
                          [NSNumber numberWithFloat:frame.origin.y],
                          [NSNumber numberWithFloat:frame.size.width],
                          [NSNumber numberWithFloat:frame.size.height]];
    [viewOwner setValue:frameArr forKey:@"frame"] ;
    
    // 显示名称
    NameView *overlayTextLabel = [self manage_loadTitleLabel:[viewOwner[@"owner"] overlayText] hidden:NO isShowMuteImage:[viewOwner[@"owner"] isMuted] isSpeaking: ([viewOwner[@"owner"] vad] == 200 || [viewOwner[@"owner"] isSpeaking]) rect:CGRectMake(view.isPresentation ? 8:1, view.isPresentation ? 58:1, 150, 20) isPresentation:view.isPresentation];
    //    [self changeLabLayoutLength:overlayTextLabel isBig:YES];
    if(![[viewOwner[@"owner"] overlayText] isEqualToString:@"双流"] && !( [self.vcrtc.uuid isEqualToString:viewOwner[@"uuid"]] && count == 1 ) )  [bigView addSubview:overlayTextLabel];
    
    
    int supportFunc = [self manage_openFuncCount];
    
    UIView *livingView = [[UIView alloc]initWithFrame:CGRectMake(10, 37,65, 21)];
    livingView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    livingView.hidden = !self.livingEnable ;
    [livingView.layer setMasksToBounds:YES];
    [livingView.layer setCornerRadius:3];
    
    UIImageView *limage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 12, 12)];
    limage.image = [UIImage imageNamed:@"icon_101"];
    limage.center = CGPointMake(limage.center.x,livingView.frame.size.height/2.0 );
    [livingView addSubview:limage];
    
    UILabel *llable = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 60, 15)];
    llable.text = @"直播中" ;
    llable.textColor = [UIColor whiteColor];
    llable.center = CGPointMake(llable.center.x,livingView.frame.size.height/2.0 );
    llable.font = [UIFont systemFontOfSize:11];
    [livingView addSubview:llable];
    
    CGFloat recordY = supportFunc == 1 ? 37 : 65 ;
    UIView *recordView = [[UIView alloc]initWithFrame:CGRectMake(10, recordY,65, 21)];
    recordView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    recordView.hidden = ! self.recordEnable;
    [recordView.layer setMasksToBounds:YES];
    [recordView.layer setCornerRadius:3];
    
    UIImageView *rimage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 12, 12)];
    rimage.image = [UIImage imageNamed:@"icon_102"];
    rimage.center = CGPointMake(rimage.center.x,recordView.frame.size.height/2.0 );
    [recordView addSubview:rimage];
    
    UILabel *rlable = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 60, 15)];
    rlable.text = @"录制中" ;
    rlable.textColor = [UIColor whiteColor];
    rlable.center = CGPointMake(rlable.center.x,recordView.frame.size.height/2.0 );
    rlable.font = [UIFont systemFontOfSize:11];
    [recordView addSubview:rlable];
    
    CGFloat lockY = supportFunc == 1 ? 65 : supportFunc == 2 ? 93 :  37 ;
    UIView *lockView = [[UIView alloc]initWithFrame:CGRectMake(10, lockY,115, 40)];
    lockView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    lockView.hidden = !self.sticking ;
    [lockView.layer setMasksToBounds:YES];
    [lockView.layer setCornerRadius:3];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 60, 15)];
    lable.text = @"主屏已锁定";
    lable.textColor = [UIColor whiteColor];
    lable.center = CGPointMake(lable.center.x,lockView.frame.size.height/2.0 );
    lable.font = [UIFont systemFontOfSize:11];
    [lockView addSubview:lable];
    
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lockBtn.frame = CGRectMake(lockView.frame.size.width - 47, 0, 40, 20);
    [lockBtn setTitle:@"解锁" forState:UIControlStateNormal];
    lockBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    lockBtn.center = CGPointMake(lockBtn.center.x,lockView.frame.size.height/2.0 );
    lockBtn.backgroundColor = [UIColor colorWithRed:14/255.0 green:140/255.0 blue:238/255.0 alpha:1];
    [lockBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lockBtn.layer setMasksToBounds:YES];
    [lockBtn.layer setCornerRadius:3];
    [lockBtn addTarget:self action:@selector(manage_clickCancelStick:) forControlEvents:UIControlEventTouchUpInside];
    [lockView addSubview:lockBtn];
    [bigView addSubview:lockView];
    [bigView addSubview:recordView];
    [bigView addSubview:livingView];
    
    return bigView ;
}

- (void)changeLabLayoutLength:(UILabel *)lab isBig:(BOOL )isBig {
    NSString *title = lab.text;
    NSInteger fontWidth = 0;
    for (int i = 0; i < title.length; i++) {
        NSRange range=NSMakeRange(i,1);
        NSString *subString=[title substringWithRange:range];
        const char *cString=[subString UTF8String];
        if (strlen(cString)==3) fontWidth += isBig ? 16 : 12;
        else if (strlen(cString)==1) fontWidth += (isBig ? 16 : 12)/2.0;
    }
    fontWidth += 10 ;
    CGFloat maxWidth = isBig ? 100 : 70 ;
    lab.ott_width = fontWidth >= maxWidth ? maxWidth : fontWidth;
}

- (BOOL)approximatelyEqualValue1:(NSInteger )value1 value2:(NSInteger)value2 {
    if (labs(value1 - value2) <= 1 )
        return true ;
    return false ;
}


/**
 锁定主屏
 */
- (void)manage_clickStick:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(manage_hiddenView:) object:button];
    if ([_delegate respondsToSelector:@selector(conferenceHelper:didClickStick:forButton:)]) {
        [_delegate conferenceHelper:self didClickStick:!self.sticking forButton:button] ;
    }
}


/**
 取消主屏锁定
 */
- (void)manage_clickCancelStick:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(manage_hiddenView:) object:button];
    if ([_delegate respondsToSelector:@selector(conferenceHelper:didClickStick:forButton:)]) {
        [_delegate conferenceHelper:self didClickStick: NO forButton:button] ;
    }
}


/**
 设置小屏锁定
 */
- (void)manage_clickSetStick:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(manage_hiddenView:) object:button];
    if ([_delegate respondsToSelector:@selector(conferenceHelper:didClickStick:forButton:)]) {
        [_delegate conferenceHelper:self didClickStick: YES forButton:button] ;
    }
}

- (void) manage_hiddenView:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(conferenceHelper:didHiddenView:)]) {
        [_delegate conferenceHelper:self didHiddenView:YES] ;
    }
}

- (UIImageView *)manage_loadImageView:(BOOL )isClose forFrame:(CGRect )frame {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame ];
    
    if (isClose) {
        imageView.image = [UIImage imageNamed:@"background-close-video"];
    } else {
        UIImage *image1 = [UIImage imageNamed:@"icon_loding1"];
        UIImage *image2 = [UIImage imageNamed:@"icon_loding2"];
        UIImage *image3 = [UIImage imageNamed:@"icon_loding3"];
        NSArray *imagesArray = @[image1,image2,image3];
        imageView.animationImages = imagesArray;
        imageView.animationDuration = [imagesArray count];
        imageView.animationRepeatCount = 0;
        [imageView startAnimating];
    }
    return imageView ;
}



/**
 小画面和大画面昵称显示
 
 @param text 昵称内容
 @param hidden 是否移仓
 @param isShowMuteImage 参会者被静音时是否显示静音图标
 @param rect 布局  width 是最大宽度
 */
- (NameView *)manage_loadTitleLabel:(NSString *)text hidden:(BOOL )hidden isShowMuteImage: (BOOL)isShowMuteImage isSpeaking: (BOOL) isSpeaking rect: (CGRect)rect isPresentation: (BOOL)isPresentation {
    NSString *nameString = text;
    if (isPresentation) {
        nameString = [NSString stringWithFormat:@"演讲者:%@",text];
    }
    nameString = nameString.length ? nameString : @"我";
    CGFloat nameLabWidth = [nameString widthForFont:[UIFont systemFontOfSize:13]];
    CGFloat totalWidth = nameLabWidth + imgLeftMargin + imgRightMargin + imgWidth + labRightMargin;
    CGFloat maxWidth = rect.size.width - 1;
    NameView *nameView;
    if (isShowMuteImage  && !isPresentation) {
        nameView = [[NameView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y,  totalWidth> maxWidth ? maxWidth : totalWidth, 18) maxWidth:maxWidth];
        [nameView setImage:[UIImage imageNamed:@"icon-静音-30-s"] title:nameString];
    } else if (isSpeaking) {
        nameView = [[NameView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, totalWidth>maxWidth ? maxWidth : totalWidth, 18)];
        UIImage *image = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"micro_blue" ofType:@"gif"]]];
        [nameView setImage:image title:nameString];
        
    } else {
        totalWidth = nameLabWidth + noImgLabLeftMargin + labRightMargin;
        nameView = [[NameView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, totalWidth > maxWidth ? maxWidth : totalWidth, 18) maxWidth:maxWidth];
        [nameView setImage:[UIImage imageNamed:@""] title:nameString];
    }
    return nameView ;
}

- (UIScrollView *)manage_loadScrollView:(CGRect )rect {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //    scrollView.width -= 20;
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.multipleTouchEnabled = YES;
    scrollView.maximumZoomScale = 3.0;
    return scrollView;
}

- (int )manage_openFuncCount {
    int count = 0;
    if (self.recordEnable) count += 1 ;
    if (self.livingEnable) count += 1 ;
    return count ;
}

- (void)btnTouchOne:(UIButton *)sender forEvent:(UIEvent *)event {
    [self performSelector:@selector(manage_hiddenView:) withObject:sender afterDelay:0.3];
}

- (UIView *)conf_reloadSmallViewClose:(BOOL)isClose withOwner:(NSMutableDictionary *)viewOwner withIndex:(NSInteger )index withSize:(CGSize )size{
    // 视频 view 容器
    CGFloat superViewWidth = size.width ;
    CGFloat superViewHeight = size.height ;
    CGFloat viewWidth = superViewWidth / 5.0 - 2;
    CGFloat viewHeight = viewWidth * 9 / 16.0 ;
    CGRect startFrame = CGRectMake(superViewWidth/5.0 * (index - 1) + 4 , superViewHeight - viewHeight, 0, 0);
    if ([viewOwner.allKeys containsObject:@"frame"]) {
        startFrame = CGRectMake( 0 , 0 , superViewWidth , superViewHeight )  ;
    }
    
    UIView *bigView = [[UIView alloc]initWithFrame:startFrame];
    bigView.backgroundColor = [UIColor clearColor] ;
    
    //     背景图片
    UIImageView *imageView = [self manage_loadImageView:isClose forFrame:CGRectMake(0, 0, startFrame.size.width, startFrame.size.height) ];
    [bigView addSubview:imageView];
    
    // 视频 view
    VCVideoView *view = viewOwner[@"view"];
    //    imageView.hidden = YES ;
    
    if ( ( [self approximatelyEqualValue1:viewWidth value2:startFrame.size.width]  && [self approximatelyEqualValue1:viewHeight value2:startFrame.size.height] ) ) {
    }
    
    view.objectFit =  !view.isPresentation ? VCVideoViewObjectFitCover : VCVideoViewObjectFitContain ;
    view.frame =  CGRectMake(0, 0, startFrame.size.width, startFrame.size.height) ;
    
    //    [UIView animateWithDuration:0.6 animations:^{
    bigView.frame = CGRectMake( superViewWidth/5.0 * (index - 1) + 4, superViewHeight - viewHeight, viewWidth , viewHeight ) ;
    imageView.frame = CGRectMake(0, 0, bigView.frame.size.width, bigView.frame.size.height);
    view.frame = CGRectMake(0, 0, bigView.frame.size.width, bigView.frame.size.height) ;
    //    } completion:^(BOOL finished) {
    //        imageView.hidden = NO ;
    //    }];
    
    if (!isClose) {
        [bigView addSubview:view];
    }
    
    CGRect frame = bigView.frame ;
    NSArray *frameArr = @[[NSNumber numberWithFloat:frame.origin.x],
                          [NSNumber numberWithFloat:frame.origin.y],
                          [NSNumber numberWithFloat:frame.size.width],
                          [NSNumber numberWithFloat:frame.size.height]];
    [viewOwner setValue:frameArr forKey:@"frame"] ;
    // 显示名称
    NameView *overlayTextLabel = [self manage_loadTitleLabel:[viewOwner[@"owner"] overlayText] hidden:view.isPresentation isShowMuteImage:[viewOwner[@"owner"] isMuted] isSpeaking: ([viewOwner[@"owner"] vad] == 200 || [viewOwner[@"owner"] isSpeaking]) rect: CGRectMake(0.5, bigView.ott_height - 19, bigView.ott_width, 18) isPresentation:view.isPresentation] ;
    
    [bigView addSubview:overlayTextLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, bigView.frame.size.width, bigView.frame.size.height) ;
    btn.tag = index ;
    [btn addTarget:self action:@selector(btnTouchOne:forEvent:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(manage_clickSetStick:) forControlEvents:UIControlEventTouchDownRepeat];
    [bigView addSubview:btn];
    return bigView ;
}

- (UIView *)conf_loadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType{
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = SCREEN_HEIGHT;
    if (width < height) {
        width = SCREEN_HEIGHT;
        height = SCREEN_WIDTH;
    }
    VCPresentionView *view = [[VCPresentionView alloc]initWithFrame:CGRectMake(0, 0, width, height) showImagesOrURLs:imageUrls PhotoSourceType:sourceType] ;
    view.delegate = self ;
    return view ;
}

- (void )conf_reloadPresentionView:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType reloadView:(UIView *)presentionView {
    VCPresentionView *view = (VCPresentionView *) presentionView ;
    [view loadShowImagesOrURLs:imageUrls PhotoSourceType:sourceType];
}

- (void)VCPresentionView:(VCPresentionView *)view changePage:(NSInteger)page {
    if ([_delegate respondsToSelector:@selector(conferenceHelper:changePage:)]) {
        [_delegate conferenceHelper:self changePage:page];
    }
}

- (void)VCPresentionView:(VCPresentionView *)view zoomEndImage:(UIImage *)image {
    if ([_delegate respondsToSelector:@selector(conferenceHelper:zoomEndImage:)]) {
        [_delegate conferenceHelper:self zoomEndImage:image];
    }
}

- (void)VCPresentionView:(VCPresentionView *)view loadImageUrlFaild:(NSString *)urlStr PhotoSourceType:(YCPhotoSourceType)sourceType {
    if ([urlStr isEqualToString:self.vcrtc.shareImageURL]) {
        NSLog(@"加载Image URl %@ faild ", urlStr);
    } else {
        NSLog(@"加载Image URl %@ reload ", self.vcrtc.shareImageURL);
        [view loadShowImagesOrURLs:@[self.vcrtc.shareImageURL] PhotoSourceType:sourceType];
    }
}

/**
 会中其他参会者更改了静音状态 即使更新
 
 @param participants 最新状态的参会者
 @param marrShows 小话面
 @param manageView 小视频画面的父视图
 */
- (void)updateInConferenceParticipantMuteState:(NSArray *)participants marrShows: (NSArray *)marrShows manageView: (UIView *)manageView  {
    for (NSInteger i = 0; i<marrShows.count; i++) {
        NSDictionary *dic = marrShows[i];
        for (Participant *participant in participants) {
            if ([dic[@"uuid"] isEqualToString:participant.uuid]) {
                if (i < manageView.subviews.count) {
                    UIView *view = manageView.subviews[i];
                    NameView *nameView = (NameView *)[view subViewOfClassName:@"NameView"];
                    NSString *nameString = dic[@"overlayText"];
                    if (participant.isMuted) {
                        [nameView setImage:[UIImage imageNamed:@"icon-静音-30-s"] title:nameString];
                    } else if (participant.vad == 100 || participant.isSpeaking) {
                        UIImage *image = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"micro_blue" ofType:@"gif"]]];
                        [nameView setImage:image title:nameString];
                    } else {
                        [nameView setImage:[UIImage imageNamed:@""] title:nameString];
                    }
                    CGRect frame = nameView.frame;
                    CGFloat nameLabWidth = [nameString widthForFont:[UIFont systemFontOfSize:13]];
                    CGFloat totalWidth =  nameLabWidth + noImgLabLeftMargin + labRightMargin;
                    if (nameView.img.image) {
                        totalWidth = nameLabWidth + imgLeftMargin + imgRightMargin + imgWidth + labRightMargin;
                    }
                    nameView.frame = CGRectMake(frame.origin.x, frame.origin.y,totalWidth > nameView.superViewMaxWidth ? nameView.superViewMaxWidth : totalWidth , frame.size.height);
                }
            }
        }
    }
}

- (void)updatePresenterLabFrameWithOwner:(NSMutableDictionary *)viewOwner manageView: (UIView *)manageView isDownMigration: (BOOL)isDownMigration {
    VCVideoView *view = viewOwner[@"view"];
    if (view.isPresentation) {
        UIView *view = [manageView.subviews firstObject];
        NameView *nameView = (NameView *)[view subViewOfClassName:@"NameView"];
        CGRect frame = nameView.frame;
        CGFloat originalY = frame.origin.y;
        CGFloat y = isDownMigration ? (originalY> 50 ? originalY:originalY+50):(originalY > 50 ? originalY - 50:originalY);
        nameView.frame = CGRectMake(frame.origin.x,y, frame.size.width, frame.size.height);
    }
}



@end
