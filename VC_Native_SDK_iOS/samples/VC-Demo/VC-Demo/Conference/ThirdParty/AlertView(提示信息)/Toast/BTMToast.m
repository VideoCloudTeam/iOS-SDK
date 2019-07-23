//
//  BTMToast.m
//
//

#import "BTMToast.h"
#import <QuartzCore/QuartzCore.h>

#define kToastFont [UIFont systemFontOfSize:15.0f]
#define kHorizontalPadding          20.0
#define kVerticalPadding            10.0
#define kCornerRadius               8.0
#define kMaxLines                   2
#define kMaxWidth                   260.0f
#define kMaxHeight                  100.0f
#define kFadeDuration               0.6
#define kOpacity                    0.8

@implementation BTMToast

#pragma mark - 
#pragma mark - Singleton Stuff

static BTMToast *_instance = nil;

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    
    return nil;   
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kOpacity];
        self.layer.cornerRadius = kCornerRadius;     
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:6.0];
        [self.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
        
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:kToastFont];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:kMaxLines];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
        _label = label;
        _stoped = YES;
        _refreshed = NO;
    }
    return self;
}

- (void)startAnimate
{   
    [UIView beginAnimations:@"fade_in" context:( void*)self];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:kOpacity];
    [UIView commitAnimations];
}

- (void)showToast:(NSString *)message inView:(UIView *)superView
{
    [self showToast:message inView:superView centerOffY:0];
}

- (void)showToast:(NSString *)message inView:(UIView *)superView centerOffY:(CGFloat)centerOffY
{
    if ([self isToastMessageEqual:message]) {
        return;
    }
    
//    CGSize text_size = [message sizeWithFont:kToastFont constrainedToSize:CGSizeMake(kMaxWidth, kMaxHeight) lineBreakMode:_label.lineBreakMode];
    
    CGSize text_size = [message boundingRectWithSize:CGSizeMake(kMaxWidth, kMaxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_label.font}
                                             context:nil].size;
    
    [_label setText:message];
    [_label setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, text_size.width, text_size.height)];
    [self setFrame:CGRectMake(0.0f, 0.0f, text_size.width + kHorizontalPadding * 2, text_size.height + kVerticalPadding * 2)];
    self.center = CGPointMake(superView.frame.size.width / 2, superView.frame.size.height/2 - self.frame.size.height / 2 - kVerticalPadding + centerOffY);
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else
    {
        _refreshed = YES;
    }
    
    [self startAnimate];
}


- (void)showToast:(NSString *)message {
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [[BTMToast sharedInstance] showToast:message centerOffY:(CGRectGetHeight(keywindow.bounds) * 0.12)];
}

-(void)showToastV:(NSString *)message {
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [[BTMToast sharedInstance] showToastV:message centerOffY:(CGRectGetWidth(keywindow.bounds) * 0.12)];
}

- (BOOL)isToastMessageEqual:(NSString *)newMessage
{
    return [_label.text isEqualToString:newMessage] && !_stoped;
}

- (void)showToastV:(NSString *)message centerOffY:(CGFloat)centerOffY {
    
    if ([self isToastMessageEqual:message]) {
        return;
    }
    
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];
    
    //    CGSize text_size = [message sizeWithFont:kToastFont constrainedToSize:CGSizeMake(kMaxWidth, kMaxHeight) lineBreakMode:_label.lineBreakMode];
    
    CGSize text_size = [message boundingRectWithSize:CGSizeMake(kMaxWidth, kMaxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_label.font}
                                             context:nil].size;
    
    [_label setText:message];
    [_label setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, text_size.width, text_size.height)];
    [self setFrame:CGRectMake(0.0f, 0.0f, text_size.width + kHorizontalPadding * 2, text_size.height + kVerticalPadding * 2)];
    self.center = CGPointMake(superView.frame.size.height / 2, superView.frame.size.width/2 - self.frame.size.width / 2 - kHorizontalPadding - 55.0f + centerOffY);
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else{
        _refreshed = YES;
    }
    [self startAnimate];
}

- (void)showToast:(NSString *)message centerOffY:(CGFloat)centerOffY {
    
    if ([self isToastMessageEqual:message]) {
        return;
    }
    
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];
    
//    CGSize text_size = [message sizeWithFont:kToastFont constrainedToSize:CGSizeMake(kMaxWidth, kMaxHeight) lineBreakMode:_label.lineBreakMode];
    
    CGSize text_size = [message boundingRectWithSize:CGSizeMake(kMaxWidth, kMaxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_label.font}
                                             context:nil].size;

    [_label setText:message];
    [_label setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, text_size.width, text_size.height)];
    [self setFrame:CGRectMake(0.0f, 0.0f, text_size.width + kHorizontalPadding * 2, text_size.height + kVerticalPadding * 2)];
    self.center = CGPointMake(superView.frame.size.width / 2, superView.frame.size.height/2 - self.frame.size.height / 2 - kVerticalPadding - 55.0f + centerOffY);
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else{
        _refreshed = YES;
    }
    [self startAnimate];
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context
{    
    UIView *toast = (__bridge UIView *)context;
    
    if([animationID isEqualToString:@"fade_in"]) {
        [UIView beginAnimations:@"fade_out" context:context];
        [UIView setAnimationDelay:_label.text.length > 10 ? 1.5 : 1.0];     // 设置当内容较多时，显示的时间稍长一些
        [UIView setAnimationDuration:kFadeDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [toast setAlpha:0.0];
        [UIView commitAnimations];
    } 
    else if ([animationID isEqualToString:@"fade_out"]) {
        if (_refreshed) {
            //not remove because of refresh
            _refreshed = NO;
        }else{
            toast.hidden = YES;
            [toast removeFromSuperview];
            _stoped = YES;
        }
    }
}

@end
