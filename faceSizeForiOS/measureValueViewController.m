//
//  measureValueViewController.m
//  GlassesVRiOSDemo
//
//  Created by Jeavil on 16/4/5.
//  Copyright © 2016年 topplusvision. All rights reserved.
//
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#import "measureValueViewController.h"

@interface measureValueViewController (){
    
    UIImageView *dyImageView;
}

@end

@implementation measureValueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBoardView];
    //  timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(viewRotate) userInfo:nil repeats:YES];
}


- (void)createBoardView{
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    imageView.image = [UIImage imageNamed:@"尺寸测量背景.png"];
    [self.view addSubview:imageView];
    
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH / 10 * 9, (WIDTH * 2350 / 1306) / 10 * 9)];
    imageView1.center = imageView.center;
    imageView1.image = [UIImage imageNamed:@"尺寸测量边框"];
    [self.view addSubview:imageView1];
    
    //人脸图片
    CGFloat faceWidth =  (WIDTH / 3 * 2) + 10;
    CGFloat faceHeight = faceWidth * 1.3333;
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 10, HEIGHT / 12, faceWidth, faceHeight)];
    imageView2.image = self.showImage;
    [self.view addSubview:imageView2];
    
    float view3Width;
    float view4Width;
    float dyWidth;
    float labelX;
    float labelY;
    if (self.view.frame.size.width == 768) {
        view3Width = (WIDTH / 3) / 2;
        view4Width = ((WIDTH / 3) - 15) / 2;
        dyWidth = ((WIDTH / 3) - 20) / 2;
        labelX = WIDTH / 2 + 50;
        labelY = HEIGHT - 300;
    }else{
        view3Width = (WIDTH / 3);
        view4Width = ((WIDTH / 3) - 15) ;
        dyWidth = ((WIDTH / 3) - 20) ;
        labelX = WIDTH / 2 + 10;
        labelY = HEIGHT / 10 + faceHeight + 15;
    }
    //旋转圈
    UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 10, HEIGHT / 10 + faceHeight + 30, view3Width, view3Width)];
    imageView3.image = [UIImage imageNamed:@"尺寸测量圆圈"];
    [self.view addSubview:imageView3];
    UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 10, HEIGHT / 10 + faceHeight + 30, view4Width, view4Width)];
    imageView4.image = [UIImage imageNamed:@"尺寸测量蓝色圈"];
    imageView4.center = imageView3.center;
    [self.view addSubview:imageView4];
    //动态圈
    dyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 10, HEIGHT / 10 + faceHeight + 30, dyWidth, dyWidth)];
    dyImageView.center = imageView4.center;
    dyImageView.image = [UIImage imageNamed:@"动态圈"];
    [self.view addSubview:dyImageView];
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self startAnimation];
    });
    
    //显示label
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, labelY, WIDTH / 3, WIDTH / 2)];
    valueLabel.numberOfLines = 0;
    valueLabel.text = self.showValue;
    valueLabel.textAlignment = NSTextAlignmentLeft;
    [valueLabel setTextColor:[UIColor grayColor]];
    [valueLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:valueLabel];
    //能量槽
    UIImageView *imageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 3 * 2 + 27, HEIGHT / 10 + faceHeight + WIDTH / 3 + 50, WIDTH / 7, (WIDTH / 7) * 98 / 158)];
    imageView5.image = [UIImage imageNamed:@"尺寸测量能量条"];
    [self.view addSubview:imageView5];
    //top符号
    UIImageView *imageView6 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH - 75, HEIGHT - 30, 66, 25)];
    imageView6.image = [UIImage imageNamed:@"top.png"];
    [self.view addSubview:imageView6];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, HEIGHT - 50, 20, 40);
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}
- (void)backClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)startAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000;
    
    [dyImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
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
