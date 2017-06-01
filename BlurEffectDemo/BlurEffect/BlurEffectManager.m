//
//  BlurEffectManager.m
//  BlurEffectDemo
//
//  Created by Paddy on 17/5/24.
//  Copyright © 2017年 Paddy. All rights reserved.
//

#import "BlurEffectManager.h"
#import "UIImage+ImageEffects.h"

@interface BlurEffectManager ()
@property (nonatomic,strong) UIImageView *maskView;
@end

@implementation BlurEffectManager

+ (void)load
{
    [[BlurEffectManager shareManager] setup];
}

+ (instancetype)shareManager
{
    static BlurEffectManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BlurEffectManager alloc] init];
    });
    return _manager;
}

#pragma mark - pulic methods
- (void)setup
{
    [self addNoticeObserve];
}


#pragma mark - private methods
- (void)addNoticeObserve
{
    NSNotificationCenter *notifiCenter = [NSNotificationCenter defaultCenter];
    [notifiCenter removeObserver:self];
    
    [notifiCenter addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notifiCenter addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)appDidBecomeActive:(id)sender
{
    //移除
    [self removeBlurView];
}

- (void)appWillResignActive:(id)sender
{
    //进入后台,实现模糊效果
    [self addBlurView];
}

- (void)addBlurView
{
    UIImage *image = [self getAppBlurImage];
    self.maskView.image = image;
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
}

- (void)removeBlurView
{
    if (_maskView) {
        [_maskView removeFromSuperview];
    }
}


#pragma mark - getter
//使用UIVisualEffectView
//- (UIView *)maskView{
//    if (!_maskView) {
//        CGRect frame = [UIScreen mainScreen].bounds;
//        _maskView = [[UIView alloc] initWithFrame:frame];
//        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//        effectview.frame = frame;
//        [_maskView addSubview:effectview];
//    }
//    return _maskView;
//}

- (UIImageView *)maskView{
    if (!_maskView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _maskView = [[UIImageView alloc] initWithFrame:frame];
        _maskView.userInteractionEnabled = YES;
        //为了防止激活的时候没有成功移除,则加一个tap手势移除
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBlurView)];
        [_maskView addGestureRecognizer:tapGR];
    }
    
    return _maskView;
}

//获取模糊图片
- (UIImage *)getAppBlurImage{
    UIImage *snapShot = [self getAppSnapshot];
    UIImage *blurImage = [snapShot blurImageWithRadius:5.0];
    return blurImage;
}

//截取当前视图为图片
- (UIImage *)getAppSnapshot
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
