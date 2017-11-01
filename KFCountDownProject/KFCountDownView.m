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
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeView];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 40, 40)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initializeView
{
    self.backgroundColor = [UIColor clearColor];
    _totalTime = kKFCountDownTotalTime;
    _countDownCircleColor = [UIColor colorWithRed:102/255.0 green:1 blue:1 alpha:1];
    CGFloat width = self.frame.size.width - kKFCircleLineWidth;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor grayColor];
    [self addSubview:button];
    button.layer.cornerRadius = width/2;
    button.layer.masksToBounds = YES;
    button.frame = CGRectMake(0, 0, width, width);
    button.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [button addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _eLayer = [CAEmitterLayer layer];
    _eLayer.frame = CGRectMake(0, 0, width, width);
    
    _eLayer.emitterPosition = CGPointMake(width/2 + kKFCircleLineWidth/2, width/2 + kKFCircleLineWidth/2);
    _eLayer.emitterSize = CGSizeMake(kKFCircleLineWidth, kKFCircleLineWidth);
    _eLayer.emitterShape = kCAEmitterLayerCircle;
    _eLayer.emitterMode = kCAEmitterLayerSurface;
    _eLayer.renderMode = kCAEmitterLayerAdditive;
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name = @"countdown";
    
    cell.color = _countDownCircleColor.CGColor;
    cell.contents = (__bridge id _Nullable)([self imageWithColor:_countDownCircleColor andSize:CGSizeMake(1, 1)].CGImage);
    cell.birthRate = 40;
    cell.lifetime = 0.5;
    cell.velocity = 4;
    cell.velocityRange = 4;
    cell.emissionRange = M_PI_4;
    cell.emissionLongitude = 0;
    _eLayer.emitterCells = @[cell];
    _eCell = cell;
    
    [self.layer addSublayer:_eLayer];
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
        [self reloadEmitterColor:countDownCircleColor];
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
    _count = 0;
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, kKFTimeInterval * NSEC_PER_SEC);
    uint64_t interval = (uint64_t)(kKFTimeInterval * NSEC_PER_SEC);
    dispatch_source_set_timer(_gcdTimer, start, interval, kKFTimeInterval/2 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_gcdTimer, ^{
        [weakSelf timeRun];
    });
    dispatch_resume(_gcdTimer);
}

- (void)endAnimation
{
    dispatch_cancel(_gcdTimer);
    _gcdTimer = nil;
    _count = 0;
}

- (void)timeRun
{
    _count = _count + 1;
    _currentProgress = _count / (_totalTime * 1/kKFTimeInterval);
    if (_currentProgress > 1) {
        [self closeButtonClick];
        return;
    }
    [self setNeedsDisplay];
}

- (void)closeButtonClick
{
    [self endAnimation];
    [_eLayer removeFromSuperlayer];
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetFlatness(context, 2.0);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextSetLineWidth(context, kKFCircleLineWidth);
    
    CGFloat passAngle = _currentProgress * M_PI_2 * 4;
    CGPoint arcCenter = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y);
    CGFloat radius = (self.frame.size.width - kKFCircleLineWidth)/2;
    CGContextAddArc(context, arcCenter.x, arcCenter.y, radius, -M_PI_2 + passAngle,   M_PI_2 * 3, 0);
    
    CGFloat currentPointX = arcCenter.x + cosf(-M_PI_2 + passAngle)*radius;
    CGFloat currentPointY = arcCenter.y + sinf(-M_PI_2 + passAngle)*radius;
    _eLayer.emitterPosition = CGPointMake(currentPointX, currentPointY);
    _eCell.emissionLongitude = M_PI + passAngle;
    
    CGContextSetStrokeColorWithColor(context, _countDownCircleColor.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}


@end
