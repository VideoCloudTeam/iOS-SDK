//
//  VCPresentionView.h
//  linphone
//
//  Created by 李志朋 on 2019/4/3.
//

#import <UIKit/UIKit.h>
#import "YCPhotoBrowserConst.h"

NS_ASSUME_NONNULL_BEGIN

@class VCPresentionView ;

@protocol VCPresentionViewDelegate <NSObject>

- (void)VCPresentionView:(VCPresentionView *)view changePage:(NSInteger )page ;

- (void)VCPresentionView:(VCPresentionView *)view zoomEndImage:(UIImage *)image ;
- (void)VCPresentionView:(VCPresentionView *)view loadImageUrlFaild:(NSString *)urlStr PhotoSourceType:(YCPhotoSourceType)sourceType;
@end

@interface VCPresentionView : UIView

@property (nonatomic, weak) id<VCPresentionViewDelegate> delegate ;

- (instancetype)initWithFrame:(CGRect)frame showImagesOrURLs:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType ;

- (void)loadShowImagesOrURLs:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType ;

@end

NS_ASSUME_NONNULL_END
