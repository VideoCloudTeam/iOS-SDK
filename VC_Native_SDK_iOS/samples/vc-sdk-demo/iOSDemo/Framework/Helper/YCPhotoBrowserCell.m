//
//  YCPhotoBrowserCell.m
//  YCToolkit
//
//  Created by 蔡亚超 on 2018/1/31.
//  Copyright © 2018年 WellsCai. All rights reserved.
//

#import "YCPhotoBrowserCell.h"
#import "YCCycleProgressView.h"
#import "UIView+YCExtension.h"
#import "UIImageView+WebCache.h"


@interface YCPhotoBrowserCell()<UIScrollViewDelegate>
@property (nonatomic,strong)UIScrollView             *scrollView;
@property (nonatomic,strong)YCCycleProgressView      *progressView;
@property (nonatomic,strong)UIButton                 *saveButton;
@property(nonatomic,strong,readwrite)UIImageView     *imageView;

// 测试的时候用的。
@property(nonatomic,strong,readwrite)UIImageView     *imageViewSmall;
@property(nonatomic,strong)UIImage     *placeholderImage;

@end

@implementation YCPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self addGestureRecognizer];
    }
    return self;
}
- (void)setupUI{
    [self.contentView addSubview:self.scrollView];
//    [self.contentView addSubview:self.progressView];
    [self.scrollView addSubview:self.imageView];
//    [self.contentView addSubview:self.imageViewSmall];
//    self.imageViewSmall.image = [UIImage imageNamed:@"Launch"] ;
}

- (void)addGestureRecognizer{
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)image{
    self.progressView.hidden = NO;
//    if (image)  [self setupImageViewFrame:image];
    [self.imageView sd_setImageWithURL:url placeholderImage:self.placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        CGFloat progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
        // 默认给它个0.01
        if (progress < 0.01) progress = 0.01;
        self.progressView.progress = progress;

    } completed:^(UIImage * _Nullable downloadImage, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        self.placeholderImage = downloadImage ;
        
        if (!downloadImage) {
            if ([self->_delegate respondsToSelector:@selector(loadImageUrlFaild:)]) {
                [self->_delegate loadImageUrlFaild:imageURL.absoluteString] ;
            }
        }
        // error 证明网络出错
//        [self setupImageViewFrame:error?image:downloadImage];
        self.progressView.hidden = error ? NO : YES ;
        if (self.placeholderImage) {
            self.imageView.backgroundColor = [UIColor whiteColor];
        }
        [self reloadFrames];
    }];
}
- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self reloadFrames];
}

- (void)updateImageToZoomOne  {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

- (void)reloadFrames{
    CGRect frame = self.scrollView.frame;
    if(self.imageView.image){
        
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (frame.size.width <= frame.size.height) { // if scrollView.width <= height
            // let width of the image set as width of scrollView, height become radio
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = frame.size.width;
        }else{
            // let width of the image set as width of scrollView, height become radio
            CGFloat ratio = frame.size.height / imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        [self.imageView setFrame:(CGRect){CGPointZero,imageFrame.size}];
        
        // set scrollView contentsize
        self.scrollView.contentSize = _imageView.frame.size;
        
        // set scrollView.contentsize as image.size , and get center of the image
        _imageView.center = [self centerOfScrollViewContent:self.scrollView];
        // get the radio of scrollView.height and image.height
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        // get radio of the width
        CGFloat widthRadit = frame.size.width / imageFrame.size.width;
        
        // get the max radio
        maxScale = widthRadit > maxScale?widthRadit:maxScale;
        // if the max radio >= PhotoBrowerImageMaxScale, get max radio , else PhotoBrowerImageMaxScale
        maxScale = maxScale > 2.f ? maxScale :2.f;
        
        // set max and min radio of scrollView
        self.scrollView.minimumZoomScale = 1.f;
        self.scrollView.maximumZoomScale = maxScale;
        
        // set scrollView zoom original
        self.scrollView.zoomScale = 1.0f;
        
    }else{
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        self.scrollView.contentSize = self.imageView.size;
    }
    self.scrollView.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView{
    // scrollView.bounds.size.width > scrollView.contentSize.width :that means scrollView.size > image.size
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark - UIScrollViewDelegate
// 返回一个放大或者缩小的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

// 视图放大或缩小
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = self.imageView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"--- - - -  - - -  - -ssssssss");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self scrollViewDidEnd:scrollView];
}

- (void) scrollViewDidEnd:(UIScrollView *)scrollView {
    // 放大、缩小结束之后 执行此方法。
    
    // 获得当前图片的UIImage
    UIImage *image = self.imageView.image ;
    
    // 转换为CIImage
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    static CGFloat sss = 0 ;
    
    BOOL isWidth = ciImage.extent.size.width / ciImage.extent.size.height < [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height ;
    
    // 获取当前放大缩小之后的图片的x 、y 、width 、height
    CGFloat x = ( scrollView.contentOffset.x / scrollView.zoomScale ) * ciImage.extent.size.width / self.frame.size.width ;
    CGFloat y = ( scrollView.contentOffset.y / scrollView.zoomScale ) * ciImage.extent.size.height / self.frame.size.height  ;
    CGFloat width = isWidth ? ciImage.extent.size.width : ( ciImage.extent.size.width / scrollView.zoomScale )  ;
    CGFloat height = !isWidth ? ciImage.extent.size.height : (ciImage.extent.size.height / scrollView.zoomScale )  ;
    
    

    // 因为图片绘制的方式为正坐标轴方式, 所以需要转换一下 y 的值。
    
    /*
     
     y
     ^              s  : 表示图片的高
     |              h  : 表示要截取图片的高
     |              y1 : 表示view 方式的y坐标
     |              y2 : 表示正坐标轴方式的y坐标
    -+- - - -> x
     |              则 y2 = s - h - y1 ;
     
     */
    
    
    CGFloat cgY = ciImage.extent.size.height - ( height + ( y >= 0 ? y : 0 ) ) >= 0 ?  ciImage.extent.size.height - ( height + ( y >= 0 ? y : 0 ) ) : 0;
    
    NSLog(@"- cgy %.2lf - h %.2lf ", x, y);
    
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(isWidth ? 0 : x, cgY ,width,height)];
    
    sss += 1 ;
    
    UIImage *imageChange = [[UIImage alloc] initWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    temporaryContext = nil;
    self.imageViewSmall.image = imageChange ;
    
    if ([_delegate respondsToSelector:@selector(zoomEndImage:)]) {
        [_delegate zoomEndImage:imageChange];
    }
}

#pragma mark - GestureRecognizer

- (void)doubleTap:(UIGestureRecognizer *)recognizer{
    if(self.scrollView.zoomScale <= 1){
        // 1.catch the postion of the gesture
        // 2.contentOffset.x of scrollView  + location x of gesture
        CGFloat x = [recognizer locationInView:self].x + self.scrollView.contentOffset.x;
        
        // 3.contentOffset.y + location y of gesture
        CGFloat y = [recognizer locationInView:self].y + self.scrollView.contentOffset.y;
        [self.scrollView zoomToRect:(CGRect){{x,y},CGSizeZero} animated:true];
    }else{
        // set scrollView zoom to original
        [self.scrollView setZoomScale:1.f animated:true];
    }
    [self scrollViewDidEnd:self.scrollView];
}

- (void)longPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(longPressPhotoBrowserCell:)]) {
            [self.delegate longPressPhotoBrowserCell:self];
        }
    }
}

#pragma mark - 属性
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.contentView.bounds;
        _scrollView.contentInset = UIEdgeInsetsMake( 0, -10, 0, 0);
        _scrollView.width += 10 ;
        _scrollView.delegate = self;
        _scrollView.bouncesZoom = NO ;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.maximumZoomScale = 3.0;
    }
    return _scrollView;
}
- (YCCycleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[YCCycleProgressView alloc] init];
        _progressView.bounds = CGRectMake(0, 0, 60, 60);
        _progressView.center = self.contentView.center;
        _progressView.hidden = YES;
        _progressView.backgroundColor = [UIColor clearColor];
    }
    return _progressView;
}
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.contentView.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIImageView *)imageViewSmall{
    if (!_imageViewSmall) {
        _imageViewSmall = [[UIImageView alloc] init];
        _imageViewSmall.frame = CGRectMake(self.frame.size.width /2.0, self.frame.size.height /2.0, self.frame.size.width /2.0, self.frame.size.height /2.0);
        
    }
    return _imageViewSmall;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _saveButton;
}
@end
