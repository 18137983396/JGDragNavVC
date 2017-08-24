//
//  JGDragNavVC.m
//  JGDragNavVC-example
//
//  Created by 极光 on 2017/8/21.
//  Copyright © 2017年 极光. All rights reserved.
//

#import "JGDragNavVC.h"

@interface JGDragNavVC ()
{
    UIPanGestureRecognizer  * _recognizer;          //手势
    NSMutableArray          * _screenShotList;      //截屏数组
    UIImageView             * _lastScreenShotView;  //截屏图
    UIView                  * _backgroundView;      //背景底图
    UIView                  * _blackMask;           //蒙层图
    CGFloat                   _maxWidth;            //最大宽度
    CGPoint                   _startTouch;          //开始触碰点
    BOOL                      _isMoving;            //挪动状态
    BOOL                      _enableDragClose;     //是否开启拖拽功能 - 默认开启
    BOOL                      _tempEnableDragBack;  //是否启用拖拽返回 - 用于临时 临时禁用拖拽返回 比如在显示阻塞界面等情况下）
}

@end

@implementation JGDragNavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpConfiguration];
}

#pragma mark - 配置信息
- (void)setUpConfiguration {
    
    self.interactivePopGestureRecognizer.enabled = NO;
    _enableDragClose = YES; //是否开启拖拽功能 - 默认开启
    _tempEnableDragBack = YES;
    
    if (_enableDragClose) {
        _maxWidth = [[UIScreen mainScreen] bounds].size.width;
        _screenShotList = [[NSMutableArray alloc] init];
        _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paningGestureReceive:)];
        _recognizer.delaysTouchesBegan = NO;        //  不延迟处理 - 延迟处理会导致各种点击变的奇怪
        _recognizer.cancelsTouchesInView = YES;     //  响应手势后吞掉事件 - 向其他view送cancel事件取消处理
        _recognizer.enabled = NO;                   //  默认不启用 - 只有vc大于1时才启用返回拖拽功能
        [self.view addGestureRecognizer:_recognizer];
    }
    
    [self.navigationBar setTranslucent:NO];
}

#pragma mark - 重写push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (_enableDragClose)
        [_screenShotList addObject:[self capture]];
    
    [super pushViewController:viewController animated:animated];
    
    if (_enableDragClose)
        _recognizer.enabled = _tempEnableDragBack && self.viewControllers.count >= 2;
}

#pragma mark - 重写pop方法
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    if (_enableDragClose)
        [_screenShotList removeLastObject];
    
    UIViewController * pop = [super popViewControllerAnimated:animated];
    
    if (_enableDragClose)
        _recognizer.enabled = _tempEnableDragBack && self.viewControllers.count >= 2;
    
    return pop;
}

#pragma mark - 截屏
- (UIImage *)capture {
    
    UIView * pView = nil;
    if (self.tabBarController) {
        pView = self.tabBarController.view;
    }else if (self.navigationController) {
        pView = self.navigationController.view;
    }else {
        pView = self.view;
    }
    
    if (pView) { //此地方有webVC的判断
//        if ([self containsWKWebView:pView]) {
//            if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
//                UIGraphicsBeginImageContextWithOptions(pView.bounds.size, true, 0);
//                [pView drawViewHierarchyInRect:pView.bounds afterScreenUpdates:true];
//                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                return image;
//            }else {
//                UIGraphicsBeginImageContextWithOptions(pView.bounds.size, pView.opaque, 0.0);
//                [pView.layer renderInContext:UIGraphicsGetCurrentContext()];
//                UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                return img;
//            }
//        }else {
        
            UIGraphicsBeginImageContextWithOptions(pView.bounds.size, pView.opaque, 0.0);
            [pView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return img;
//        }
    }else {
        return nil;
    }
}

#pragma mark - 手势响应事件
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer {
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"navigationController" object:nil]];
    
    //  顶层视图直接返回
    if (self.viewControllers.count <= 1)
        return;
    
    if (!_tempEnableDragBack) {
        return;
    }
    
    //  获取坐标
    CGPoint touchPoint = [recoginzer locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    ///<    开始拖拽
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        _startTouch = touchPoint;
        
        ///<    背景视图              > 当前视图
        ///<    上个视图的截屏 > 暗视图 > 当前视图
        
        if (!_backgroundView) {
            CGRect frame = self.view.frame;
            _backgroundView = [[UIView alloc] initWithFrame:frame];
            _backgroundView.backgroundColor = [UIColor whiteColor];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            _blackMask = [[UIView alloc] initWithFrame:frame];
            _blackMask.backgroundColor = [UIColor blackColor];
            [_backgroundView addSubview:_blackMask];
        }
        _backgroundView.hidden = NO;
        [_backgroundView removeFromSuperview];
        [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
        
        if (_lastScreenShotView)
            [_lastScreenShotView removeFromSuperview];
        _lastScreenShotView = [[UIImageView alloc] initWithImage:[_screenShotList lastObject]];
        [_backgroundView insertSubview:_lastScreenShotView belowSubview:_blackMask];
        
        //        [self onDragBackStart];
        ///<    拖拽结束（返回or复原）
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
//        NSLog(@"Ended Ended");
        
        if (touchPoint.x - _startTouch.x > _maxWidth * 0.156f) {
            [self animationMoveToTarget];
            [self onDragBackFinish:YES];
        }else {
            [self animationMoveToOrigin];
            [self onDragBackFinish:NO];
        }
        return;
        ///<    拖拽取消
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [self animationMoveToOrigin];
        [self onDragBackFinish:NO];
        return;
    }
    ///<    拖拽中
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

#pragma mark- drag back event
- (void)onDragBackStart {
    
    UIViewController * vc = self.topViewController;
    if (vc && [vc respondsToSelector:@selector(onDragBackStart)]) {
        [(id)vc onDragBackStart];
    }
}

- (void)onDragBackFinish:(BOOL)bToTarget {
    
    UIViewController* vc = self.topViewController;
    if (vc && [vc respondsToSelector:@selector(onDragBackFinish:)]) {
        [(id)vc onDragBackFinish:bToTarget];
    }
}

/**
 *  移动到指定x位置
 */
- (void)moveViewWithX:(float)x {
    
    x = x > _maxWidth ? _maxWidth : x;
    x = x < 0 ? 0 : x;
//    NSLog(@"x=%f",x);
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x * 0.05f / _maxWidth) + 0.95f;
    float alpha = 0.4f - (x * 0.4f / _maxWidth);
//    NSLog(@"scale=%f",scale);
//    NSLog(@"alpha=%f",alpha);
    _lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    _blackMask.alpha = alpha;
}

/**
 *  移动到目标位置
 */
- (void)animationMoveToTarget {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self moveViewWithX:_maxWidth];
    } completion:^(BOOL finished) {
        [self popViewControllerAnimated:NO];
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        self.view.frame = frame;
        _isMoving = NO;
    }];
}

/**
 *  移动到原来位置
 */
- (void)animationMoveToOrigin {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self moveViewWithX:0];
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _backgroundView.hidden = YES;
    }];
}

// 递归判断视图及其子视图中是否包含 WKWebView
//- (BOOL)containsWKWebView:(UIView *)view {
//    if ([view isKindOfClass:[WKWebView class]]) {
//        return YES;
//    }
//    for (UIView *subView in view.subviews) {
//        if ([self containsWKWebView:subView]) {
//            return YES;
//        }
//    }
//    return NO;
//}

#pragma mark- drag back control
- (void)tempEnableDragBack {
    
    if (!_tempEnableDragBack) {
        _tempEnableDragBack = YES;
    }
}

- (void)tempDisableDragBack {
    
    if (_tempEnableDragBack) {
        _tempEnableDragBack = NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
