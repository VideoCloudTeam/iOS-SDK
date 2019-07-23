//
//  VCCollectionViewFlowLayout.m
//  zj-phone
//
//  Created by 李志朋 on 2019/4/29.
//

#import "VCCollectionViewFlowLayout.h"

@implementation VCCollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5 ;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset) ;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES ;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGRect rect ;
    rect.origin.y = 0 ;
    rect.origin.x = proposedContentOffset.x ;
    
    NSArray *arrray = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat centerX =proposedContentOffset.x + self.collectionView.frame.size.width * 0.5 ;
    
    CGFloat minDelta = 5 ;
    
    for (UICollectionViewLayoutAttributes *attrs in arrray ) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX ;
        }
    }
    
    proposedContentOffset.x += minDelta ;
    return proposedContentOffset ;
}

@end
