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
#import "UICollectionView+Fix.h"


@interface VCPresentionView() <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,YCPhotoBrowserCellDelegate>
{
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
        [self.collectionView registerClass:YCPhotoBrowserCell.class forCellWithReuseIdentifier:PhotoBrowserCellID];
        [self addSubview:self.collectionView];
    }
    return self ;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _showImagesOrURLs = [NSArray array];
        _photoSourceType = YCPhotoSourceType_URL;
    }
    return self ;
}

- (instancetype)init {
    if (self = [super init]) {
        _showImagesOrURLs = [NSArray array];
        _photoSourceType = YCPhotoSourceType_URL;
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
    _showImagesOrURLs = imageUrls;
    _photoSourceType = sourceType;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"section = %ld=============%ld",section,_showImagesOrURLs.count);
    return _showImagesOrURLs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoBrowserCellID forIndexPath:indexPath];
    cell.delegate = self ;
    YCPhotoBrowserCellHelper *helper = [YCPhotoBrowserCellHelper helperWithPhotoSourceType:_photoSourceType imagesOrURL:self.showImagesOrURLs[indexPath.row] urlReplacing:@{}];
        [cell updateImageToZoomOne];
        if (helper.isLoaclImage) {
            [cell setImage:helper.localImage];
        } else {
            [cell setImageWithURL:helper.downloadURL placeholderImage:helper.placeholderImage];
        }
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
        [SVProgressHUD showInfoWithStatus:@"当前为最后一页，不可以再滑动。"];
    }
    
    
    if (_showImagesOrURLs.count == 1) return ;
    
    if (scrollView.contentOffset.x  < 0) {
        [SVProgressHUD showInfoWithStatus:@"当前为第一页，不可以再滑动。"];
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
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
    
        _collectionView.contentInset = UIEdgeInsetsMake( 0, 36 - ( IS_PhoneXAll ? 80 : 64), 0, 0);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}



@end
