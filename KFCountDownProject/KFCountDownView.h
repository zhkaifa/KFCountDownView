//
//  KFCountDownView.h
//  TestProject
//
//  Created by zhkf on 2017/10/24.
//  Copyright © 2017年 zhkf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCountDownView : UIView
// 倒计时的时间
@property (nonatomic, assign) CGFloat totalTime;
// 圆圈的颜色
@property (nonatomic, strong) UIColor *countDownCircleColor;
// 粒子的颜色 默认和countDownCircleColor是一样的颜色
@property (nonatomic, strong) UIColor *countDownEmitterColor;

- (void)startAnimation;
- (void)endAnimation;
@end
