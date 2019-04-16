//
//  KFCountDownView.m
//  TestProject
//
//  Created by zhkf on 2017/10/24.
//  Copyright © 2017年 zhkf. All rights reserved.
//

#import "KFCountDownView.h"

static const CGFloat kKFCountDownTotalTime = 15;
static const CGFloat kKFTimeInterval = 0.05;
static const CGFloat kKFCircleLineWidth = 4;

@implementation KFCountDownView
{
    CGFloat _currentProgress;
    NSInteger _count;
    dispatch_source_t _gcdTimer;
    CAEmitterLayer *_eLayer;
    CAEmitterCell *_eCell;
    CAShapeLayer *_shapeLayer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeView];
//    self.backgroundColor = [UIColor redColor];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.closeButtonBackgroundColor = [UIColor grayColor];
    self.totalTime = kKFCountDownTotalTime;
    self.countDownCircleColor = [UIColor colorWithRed:102/255.0 green:1 blue:1 alpha:1];
    
    CGFloat width = self.frame.size.width - kKFCircleLineWidth;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = self.closeButtonBackgroundColor;
    [self addSubview:button];
    button.layer.cornerRadius = width/2;
    button.layer.masksToBounds = YES;
    button.frame = CGRectMake(0, 0, width, width);
    button.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [button setBackgroundImage:self.closeButtonImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _eLayer = [CAEmitterLayer layer];
    _eLayer.frame = CGRectMake(0, 0, width, width);
    
    _eLayer.emitterSize = CGSizeMake(kKFCircleLineWidth, kKFCircleLineWidth);
    _eLayer.emitterShape = kCAEmitterLayerCircle;
    _eLayer.emitterMode = kCAEmitterLayerSurface;
    _eLayer.renderMode = kCAEmitterLayerAdditive;
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name = @"countdown";
    
    cell.color = _countDownCircleColor.CGColor;
    cell.contents = (__bridge id _Nullable)([self imageWithColor:_countDownCircleColor andSize:CGSizeMake(1, 1)].CGImage);
    cell.birthRate = 0;
    cell.lifetime = 0.6;

    _eLayer.emitterCells = @[cell];
    _eCell = cell;
    
    [self.layer addSublayer:_eLayer];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 startAngle:-M_PI_2 endAngle:M_PI_2 * 2 clockwise:YES];
    shapeLayer.path = path.CGPath;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = kKFCircleLineWidth;
    shapeLayer.strokeColor = _countDownCircleColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:shapeLayer];
    
    _shapeLayer = shapeLayer;
    
    [self startAnimation];
}

- (void)setCountDownEmitterColor:(UIColor *)countDownEmitterColor
{
    _countDownEmitterColor = countDownEmitterColor;
    [self reloadEmitterColor:countDownEmitterColor];
}

- (void)reloadEmitterColor:(UIColor *)color
{
    _eCell.color = color.CGColor;
    _eCell.contents = (__bridge id _Nullable)([self imageWithColor:color andSize:CGSizeMake(1, 1)].CGImage);
}

- (void)setCountDownCircleColor:(UIColor *)countDownCircleColor
{
    _countDownCircleColor = countDownCircleColor;
    if (!_countDownEmitterColor) {
        self.countDownEmitterColor = countDownCircleColor;
    }
}

-(UIImage*)imageWithColor:(UIColor*)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *bezierPath=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:size.width/2.0];
    
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextFillPath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)startAnimation
{
    self.hidden = NO;
    _count = 0;
    _currentProgress = 0;
    
    if (_gcdTimer == nil) {
        _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, kKFTimeInterval * NSEC_PER_SEC);
        uint64_t interval = (uint64_t)(kKFTimeInterval * NSEC_PER_SEC);
        dispatch_source_set_timer(_gcdTimer, start, interval, kKFTimeInterval/2 * NSEC_PER_SEC);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_gcdTimer, ^{
            [weakSelf timeRun];
        });
    }
    dispatch_resume(_gcdTimer);
}

- (void)endAnimation
{
    dispatch_suspend(_gcdTimer);
    self.hidden = YES;
}

- (void)timeRun
{
    _count = _count + 1;
    _currentProgress = _count / (_totalTime * 1/kKFTimeInterval);
    if (_currentProgress > 1) {
        [self closeButtonClick];
        return;
    }
    if (_eCell.birthRate == 0) {
        _eCell.birthRate = 80;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat passAngle = _currentProgress * M_PI_2 * 4;
    CGPoint arcCenter = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y);
    CGFloat radius = (self.frame.size.width - kKFCircleLineWidth)/2;
    
    [path addArcWithCenter:arcCenter radius:radius startAngle:-M_PI_2 + passAngle endAngle:M_PI_2 * 3 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    CGFloat currentPointX = arcCenter.x + cosf(-M_PI_2 + passAngle)*radius;
    CGFloat currentPointY = arcCenter.y + sinf(-M_PI_2 + passAngle)*radius;
    _eLayer.emitterPosition = CGPointMake(currentPointX, currentPointY);
}

- (void)closeButtonClick
{
    [self endAnimation];
}

- (void)dealloc
{
    dispatch_cancel(_gcdTimer);
    _gcdTimer = nil;
}

@end
