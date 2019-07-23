//
//  BTMToast.h
//
//

#import <UIKit/UIKit.h>

@interface BTMToast : UIView
{
    @private 
    UILabel *_label;
    BOOL _stoped;
    BOOL _refreshed;
}

- (void)showToast:(NSString *)message inView:(UIView *)superView;
- (void)showToast:(NSString *)message inView:(UIView *)superView centerOffY:(CGFloat)centerOffY;

//windows
- (void)showToast:(NSString *)message;
- (void)showToastV:(NSString *)message;
- (void)showToast:(NSString *)message centerOffY:(CGFloat)centerOffY;

+ (id)sharedInstance;

@end
