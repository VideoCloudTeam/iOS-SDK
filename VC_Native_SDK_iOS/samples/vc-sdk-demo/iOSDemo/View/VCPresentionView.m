//
//  VCPresentionView.m
//  linphone
//
//  Created by 李志朋 on 2019/4/3.
//

#import "VCPresentionView.h"
#import "YCPhotoBrowserCell.h"
#import "YCPhotoBrowserCellHelper.h"
#import "UIView+YCExtension.h"

#import "UIImage+tag.h"

#import "VCCollectionViewFlowLayout.h"


@interface VCPresentionView() <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,YCPhotoBrowserCellDelegate>
{
    long           _imagesCount;
    YCPhotoSourceType   _photoSourceType;
}

@property(nonatomic,strong)UIView                   *presentitionView ;
@property(nonatomic,strong)NSArray                  *showImagesOrURLs;
@property(nonatomic,strong)UICollectionView         *collectionView;

@end

@implementation VCPresentionView

static NSString *const PhotoBrowserCellID = @"PhotoBrowserCell";

- (instancetype)initWithFrame:(CGRect)frame showImagesOrURLs:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType {
    if (self = [super initWithFrame:frame]) {
        _showImagesOrURLs = [imageUrls copy];
        _photoSourceType = sourceType;
//        if (sourceType == YCPhotoSourceType_Image) [self changeImage:0];
        _imagesCount = _showImagesOrURLs.count;
//        self.width += 20;
        [self.collectionView registerClass:YCPhotoBrowserCell.class forCellWithReuseIdentifier:PhotoBrowserCellID];
        [self addSubview:self.collectionView];
    }
    return self ;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _showImagesOrURLs = [NSArray array];
        _photoSourceType = YCPhotoSourceType_URL;
        _imagesCount = _showImagesOrURLs.count;
    }
    return self ;
}

- (instancetype)init {
    if (self = [super init]) {
        _showImagesOrURLs = [NSArray array];
        _photoSourceType = YCPhotoSourceType_URL;
        _imagesCount = _showImagesOrURLs.count;
    }
    return self ;
}

- (void)VCPresentionView:(VCPresentionView *)view loadImageUrlFaild:(NSString *)urlStr {
    if ([_delegate respondsToSelector:@selector(VCPresentionView:loadImageUrlFaild:PhotoSourceType:)]) {
        [_delegate VCPresentionView:self
                  loadImageUrlFaild:urlStr PhotoSourceType:_photoSourceType];
    }
}

- (void)loadShowImagesOrURLs:(NSArray *)imageUrls PhotoSourceType:(YCPhotoSourceType)sourceType {
    _showImagesOrURLs = [imageUrls copy];
    _photoSourceType = sourceType;
//    if (sourceType == YCPhotoSourceType_Image) [self changeImage:0];
    _imagesCount = _showImagesOrURLs.count;
    // 解决collection view reloadview 不刷新cellForItemAtIndexPath 方法。
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    });
}

- (void)changeImage:(NSInteger )index {
    NSMutableArray *arr = [NSMutableArray array];
    int i = 0 ;
    for (UIImage *image in _showImagesOrURLs) {
        if (i == index) {
            [arr addObject:[self createShareImage:image ContextImage:[UIImage imageNamed:@"black-background"]]];
        } else {
            [arr addObject:image];
        }
        i ++ ;
    }
    _showImagesOrURLs = [arr copy];
}


- (UIImage *)createShareImage:(UIImage *)tImage ContextImage:(UIImage *)image2
{
    @autoreleasepool {
        if (tImage.tag) return tImage ;
        UIImage *sourceImage = tImage;
        
        CGFloat sWidth = SCREEN_WIDTH ;
        CGFloat sHeight = SCREEN_HEIGHT ;
        CGFloat iWidth = sourceImage.size.width ;
        CGFloat iHeight = sourceImage.size.height ;
        CGFloat nHeight = iHeight ;
        CGFloat nWidth = sWidth * nHeight / sHeight ;
        // 根据图片绘制画布。
        CGSize imageSize = CGSizeMake(nWidth, nHeight);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        
        CGRect rect = CGRectMake( 0 , 0 , nWidth, nHeight);
        [image2 drawInRect:rect];

        //获得 图形上下文
        CGContextRef context=UIGraphicsGetCurrentContext();
        //画 自己想要画的内容(添加的图片)
        CGContextDrawPath(context, kCGPathStroke);
        CGContextAddEllipseInRect(context, rect);
        
        UIImage *image3 = [UIImage imageNamed:@"white-background"] ;
        CGRect rect2 = CGRectMake( (nWidth - iWidth) /2.0, 0, iWidth, iHeight);
        [image3 drawInRect:rect2] ;

        [sourceImage drawAtPoint:CGPointMake((nWidth - iWidth) /2.0, 0)];
        
        //返回绘制的新图形
        UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        newImage.tag = YES ;
        return newImage;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imagesCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoBrowserCellID forIndexPath:indexPath];
    cell.delegate = self ;
    
//    if (_photoSourceType == YCPhotoSourceType_Image) [self changeImage:indexPath.row];

    YCPhotoBrowserCellHelper *helper = [YCPhotoBrowserCellHelper helperWithPhotoSourceType:_photoSourceType imagesOrURL:self.showImagesOrURLs[indexPath.row] urlReplacing:@{}];
    NSLog(@"----------00000000000000000");
//    [helper setPlaceholderImage:[UIImage imageNamed:@""]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell updateImageToZoomOne];
        if (helper.isLoaclImage) {
            [cell setImage:helper.localImage];
        }else{
            [cell setImageWithURL:helper.downloadURL placeholderImage:helper.placeholderImage];
        }
    });
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    view.backgroundColor = [UIColor blueColor];
//    [cell.contentView addSubview:view];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 5, [UIScreen mainScreen].bounds.size.height - 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return  5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return  5;
}

static int page = 0 ;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page1 = scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5 ;
    if (page != page1 ) {
        [self changePage:page1] ;
    }
    page = page1 ;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_photoSourceType != YCPhotoSourceType_Image) return ;
   
    // 缓动大约为 0.02 个 width 的长度
    float page1 = scrollView.contentOffset.x / scrollView.bounds.size.width - 0.0002 ;

    if (page1 > self.showImagesOrURLs.count - 1 ) {
//        [[BTMToast sharedInstance]showToast:@"当前为最后一页，不可以再滑动。"];
    }
    
    
    if (_showImagesOrURLs.count == 1) return ;
    
    if (scrollView.contentOffset.x  < 0) {
//        [[BTMToast sharedInstance]showToast:@"当前为第一页，不可以再滑动。"];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float page1 = scrollView.contentOffset.x / scrollView.bounds.size.width - 0.0002 ;
    
    if (page1 > self.showImagesOrURLs.count - 1 ) {
        [self.collectionView setContentOffset:CGPointMake( SCREEN_WIDTH * ( self.showImagesOrURLs.count - 1 ),  0) animated: true];
    }
}


- (void)changePage:(NSInteger )page {
    [self.collectionView reloadData];
    if (_photoSourceType == YCPhotoSourceType_URL) return ;
    if ([_delegate respondsToSelector:@selector(VCPresentionView:changePage:)]) {
        [_delegate VCPresentionView:self changePage:page];
    }
}

- (void)zoomEndImage:(UIImage *)image {
    if (_photoSourceType == YCPhotoSourceType_URL) return ;
    if ([_delegate respondsToSelector:@selector(VCPresentionView:zoomEndImage:)]) {
        [_delegate VCPresentionView:self zoomEndImage:image];
    }
}

#pragma mark - 属性
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        VCCollectionViewFlowLayout *layout = [[VCCollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
//        layout.itemSize = [UIScreen mainScreen].bounds.size;
        
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
//        _collectionView.bounces = NO;
//        _collectionView.width += 24 ;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentInset = UIEdgeInsetsMake( 0, 36 - 64, 0, 0);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}



@end
