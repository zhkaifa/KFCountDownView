//
//  ViewController.m
//  KFCountDownProject
//
//  Created by zhkf on 2017/10/27.
//  Copyright © 2017年 zhkf. All rights reserved.
//

#import "ViewController.h"
#import "KFCountDownProject-Swift.h"
//#import "KFCountDownView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    KFCountDownView *countDownView = [[KFCountDownView alloc] initWithFrame:CGRectMake(kWidth/2 - 30, kHeight/2 - 30, 60, 60)];
    [self.view addSubview:countDownView];
    
}

@end
