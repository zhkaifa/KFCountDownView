//
//  KFCountDownView.h
//  TestProject
//
//  Created by zhkf on 2017/10/24.
//  Copyright © 2017年 zhkf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCountDownView : UIView
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) UIColor *countDownCircleColor;
@property (nonatomic, strong) UIColor *countDownEmitterColor;

- (void)startAnimation;
- (void)endAnimation;
@end
