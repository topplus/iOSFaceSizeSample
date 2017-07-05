//
//  measurementViewController.m
//  GlassesVRiOSDemo
//
//  Created by Jeavil on 16/2/26.
//  Copyright © 2016年 topplusvision. All rights reserved.
//

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#import "measureViewController.h"
#import "faceSizeForiOS_SDK.h"
#import "measureValueViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
@interface measureViewController ()<AVAudioPlayerDelegate>{
    
    CMMotionManager *motionManager;
    UIImageView *imageFirst;
    UIImageView *imageSecond;
    UIImage* imgResult;
    
    UIButton *hintBtn;
    UIButton *startBtn;
    UIImageView *heard;
    UIImageView *boardView;
    
    NSMutableArray *FacePartPupilDs;
    NSMutableArray *FacePartFaceDs;
    NSMutableArray *FacePartNoseDs;
    NSMutableArray *FacePartInnerEyeDs;
    NSMutableArray *FacePartOuterEyeDs;
    NSMutableArray *FacePartPic;
    //UILabel *label;
    
}

@property (weak, nonatomic) CameraView *cameraView;
@property (nonatomic, weak) UIImageView* heardView;
@property (nonatomic, weak)UILabel *label;
@property (nonatomic, strong)AVAudioPlayer *audioPlayer;
@end
static bool isStart = NO;//控制警示框是否显示，控制只调用一次报数动画
static BOOL isValid = NO;
static BOOL shouldStop = NO;
@implementation measureViewController
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"尺寸测量.wav" ofType:nil];
        NSURL *url = nil;
        if (urlStr) {
            url=[NSURL fileURLWithPath:urlStr];
        }
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initArrayForAVG];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"轻触屏幕";
    CGFloat x = 0;
    CGFloat y = 0;
    CameraView *testView = [[CameraView alloc]initWithFrame:CGRectMake(x, y, WIDTH, WIDTH * 4 / 3)];
   
    [testView SDKInit];
#ifdef RELEASE
    NSLog(@"RELEASE");
    [testView saveLogToFile:nil];
    
#endif

    _cameraView = testView;
    
    boardView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64 + 70, WIDTH, WIDTH + 50)];
    boardView.clipsToBounds = YES;
    boardView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:boardView];
    [boardView addSubview:testView];
    [boardView sendSubviewToBack:testView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test:) name:@"MessageFaceSize" object:nil];
    

    [self guidance];
    [self usePicker];
    
}

- (void)initArrayForAVG{
    FacePartPupilDs = [[NSMutableArray alloc]init];
    FacePartFaceDs = [[NSMutableArray alloc]init];
    FacePartNoseDs = [[NSMutableArray alloc]init];
    FacePartInnerEyeDs = [[NSMutableArray alloc]init];
    FacePartOuterEyeDs = [[NSMutableArray alloc]init];
    FacePartPic = [[NSMutableArray alloc]init];
    
}

- (void)creatStartBtn{
    
    startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake((WIDTH-60)/2, HEIGHT - 140, 60, 60);
    [startBtn addTarget:self action:@selector(startClick:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setImage:[UIImage imageNamed:@"232.232拍照"] forState:UIControlStateNormal];
    //[self.view addSubview:startBtn];
}
- (void)startClick:(UIButton *)sender{
    isStart = NO;
    [self smallStart];
    [self bigHeard];
    _heardView.layer.borderWidth = 5;
    //[self animationForNumber];
    // [_cameraView start];
    
}

- (void)creatTitle{
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, WIDTH, 70)];
    _label.text = @"请保持身份证长边缘平行于双眼\n且需把人脸和身份证移置引导区";
    _label.numberOfLines = 2;
    _label.font = [UIFont systemFontOfSize:18];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
}

//引导图片
- (void)usePicker{
    imageFirst = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(firstTap:)];
    NSString *path1 = [[NSBundle mainBundle]pathForResource:@"masurementPic1" ofType:@"jpg"];
    NSLog(@"%@",path1);
    imageFirst.image = [UIImage imageWithContentsOfFile:path1];
    imageFirst.userInteractionEnabled = YES;
    [imageFirst addGestureRecognizer:tap1];
    
    imageSecond = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(secondTap:)];
    NSString *path2 = [[NSBundle mainBundle]pathForResource:@"masurementPic2" ofType:@"jpg"];
    imageSecond.image = [UIImage imageWithContentsOfFile:path2];
    imageSecond.userInteractionEnabled = YES;
    [imageSecond addGestureRecognizer:tap2];
    
    //第一张在上面
    [self.view addSubview:imageSecond];
    [self.view addSubview:imageFirst];
}
#pragma mark tap Gesture Evens
- (void)firstTap:(UITapGestureRecognizer *)sender{
    [sender.view removeFromSuperview];
}

- (void)secondTap:(UITapGestureRecognizer *)sender{
    [sender.view removeFromSuperview];
     self.title = @"";
    if ([NSThread mainThread]) {
        //  [_cameraView start];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //  [_cameraView start];
            
        });
        
    }
    [self.audioPlayer play];
}

- (void)test:(NSNotification*)aNotification {
    //  [_cameraView stop];
    if (!isStart) {
        isStart = YES;
        [self animationForNumber];
    }
    NSDictionary *msg = [aNotification object];
    
    NSString *str1 = msg[FacePartPupilD];//瞳距
    [FacePartPupilDs addObject:str1];
    NSString *str2 = msg[FacePartFaceD];//脸宽
    [FacePartFaceDs addObject:str2];
    NSString *str3 = msg[FacePartNoseD];//鼻宽
    [FacePartNoseDs addObject:str3];
    NSString *str4 = msg[FacePartInnerEyeD];//内眼角距
    [FacePartInnerEyeDs addObject:str4];
    NSString *str5 = msg[FacePartOuterEyeD];//外眼角距
    [FacePartOuterEyeDs addObject:str5];
    
    imgResult = msg[DetectedPic];//检测好的图片
    
    [FacePartPic addObject:imgResult];
    if (FacePartFaceDs.count > 0) {
        isValid = YES;
    }
    //    self.foreResult.text = result;
    //  self.imgViewForFace.image = imgResult;
    //  [self.view bringSubviewToFront:self.foreResult];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"Disappear%d",shouldStop);
    
    //
    
    [_cameraView stop];
    
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [_cameraView start];
    if (isStart) {
        //_heardView.layer.borderWidth = 0;
    }
    if (FacePartPupilDs.count > 0) {
        [FacePartPupilDs removeAllObjects];
        [FacePartFaceDs removeAllObjects];
        [FacePartNoseDs removeAllObjects];
        [FacePartInnerEyeDs removeAllObjects];
        [FacePartOuterEyeDs removeAllObjects];
        [FacePartPic removeAllObjects];
    }
    isValid = NO;
    isStart = NO;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//引导框

- (void)guidance{
    motionManager = [[CMMotionManager alloc]init];
    UIImageView *heardView = [[UIImageView alloc]initWithFrame:boardView.frame];
    heardView.layer.borderColor = [UIColor redColor].CGColor;
    _heardView = heardView;
    _heardView.layer.borderWidth = 5;
    // _heardView.image = [UIImage imageNamed:@"onboarding-head"];
    [self.view addSubview:_heardView];
    
    heard = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH * 0.6, WIDTH * 0.6 / 390 * 490)];
    heard.image = [UIImage imageNamed:@"onboarding-head"];
    heard.center = heardView.center;
    [self.view addSubview:heard];
    
    UILabel *_label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, WIDTH, 70)];
    _label1.text = @"请保持身份证长边缘平行于双眼\n且需把人脸和身份证移置引导区";
    _label1.numberOfLines = 2;
    _label1.font = [UIFont systemFontOfSize:18];
    _label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label1];
    //
    if (motionManager.gyroAvailable) {
        motionManager.gyroUpdateInterval = 1.0;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            //地平线夹角
            //   NSLog(@"aaaaa%.0f",(M_PI_2-atan2(motionManager.deviceMotion.gravity.x, motionManager.deviceMotion.gravity.z))*180/M_PI);
            //俯仰角
            double tanX = (atan(motion.gravity.z/motion.gravity.y))*180/M_PI;
            //是否报数
            if (isStart) {
                _label1.text = @"请保持当前姿势";
            }else{
                if (tanX < 10 && tanX >-10) {
                    //手机正常放置
                    heardView.layer.borderColor = [UIColor greenColor].CGColor;
                    _label1.text = @"请将人脸置于引导框中，卡片贴于下巴处";
                }else{
                    //手机未垂直放置
                    heardView.layer.borderColor = [UIColor redColor].CGColor;
                    _label1.text = @"请将手机调整为竖直状态";
                }
            }
        }];
    }else{
        // _gyroscopeLabel.text = @"This device has no gyroscope";
    }
    
}

- (void)smallHeard{
    
    CGRect rect = heard.frame;
    rect.size.width = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        heard.frame = rect;
    });
}
- (void)bigHeard{
    
    CGRect rect = heard.frame;
    rect.size.width = WIDTH * 0.6;
    dispatch_async(dispatch_get_main_queue(), ^{
        heard.frame = rect;
    });
}

- (void)smallStart{
    
    CGRect rect = startBtn.frame;
    rect.size.width = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        startBtn.frame = rect;
    });
}
- (void)bigStart{
    
    CGRect rect = startBtn.frame;
    rect.size.width = 60;
    dispatch_async(dispatch_get_main_queue(), ^{
        startBtn.frame = rect;
    });
}

#pragma mark 报数动画
- (void)animationForNumber{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((WIDTH-80)/2,(boardView.frame.origin.y + boardView.frame.size.height) + 5, 80, 80);
    btn.layer.cornerRadius = 35;
    // btn.layer.borderWidth = 2;
    //btn.layer.borderColor = [UIColor greenColor].CGColor;
    [btn setTitle:@"3" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:45];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:btn];
    });
    
    // 贝塞尔曲线(创建一个圆)
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(80 / 2.f, 80 / 2.f)
                                                        radius:80 / 2.f
                                                    startAngle:0
                                                      endAngle:M_PI * 2
                                                     clockwise:YES];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    
    dispatch_time_t swhen = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(swhen, dispatch_get_main_queue(), ^{
        // 创建一个shapeLayer
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame         = btn.bounds;                // 与showView的frame一致
        layer.strokeColor   = [UIColor greenColor].CGColor;   // 边缘线的颜色
        layer.fillColor     = [UIColor clearColor].CGColor;   // 闭环填充的颜色
        layer.lineCap       = kCALineCapSquare;               // 边缘线的类型
        layer.path          = path.CGPath;                    // 从贝塞尔曲线获取到形状
        layer.lineWidth     = 4.0f;                           // 线条宽度
        layer.strokeStart   = 0.0f;
        layer.strokeEnd     = 1.0f;
        
        
        
        // 将layer添加进图层
        [btn.layer addSublayer:layer];
        
        [layer addAnimation:pathAnimation forKey:nil];
    });
    
    
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [btn setTitle:@"2" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        CAShapeLayer *layer1 = [CAShapeLayer layer];
        CGRect rect = CGRectMake(0, 0, 160, 160);
        layer1.frame         = rect;                // 与showView的frame一致
        layer1.strokeColor   = [UIColor yellowColor].CGColor;   // 边缘线的颜色
        layer1.fillColor     = [UIColor clearColor].CGColor;   // 闭环填充的颜色
        layer1.lineCap       = kCALineCapSquare;               // 边缘线的类型
        layer1.path          = path.CGPath;                    // 从贝塞尔曲线获取到形状
        layer1.lineWidth     = 4.0f;                           // 线条宽度
        layer1.strokeStart   = 0.0f;
        layer1.strokeEnd     = 1.0f;
        [btn.layer addSublayer:layer1];
        [layer1 addAnimation:pathAnimation forKey:nil];
    });
    
    
    dispatch_time_t when1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    dispatch_after(when1, dispatch_get_main_queue(), ^{
        [btn setTitle:@"1" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        CAShapeLayer *layer1 = [CAShapeLayer layer];
        CGRect rect = CGRectMake(0, 0, 200, 200);
        layer1.frame         = rect;                // 与showView的frame一致
        layer1.strokeColor   = [UIColor greenColor].CGColor;   // 边缘线的颜色
        layer1.fillColor     = [UIColor clearColor].CGColor;   // 闭环填充的颜色
        layer1.lineCap       = kCALineCapSquare;               // 边缘线的类型
        layer1.path          = path.CGPath;                    // 从贝塞尔曲线获取到形状
        layer1.lineWidth     = 4.0f;                           // 线条宽度
        layer1.strokeStart   = 0.0f;
        layer1.strokeEnd     = 1.0f;
        [btn.layer addSublayer:layer1];
        [layer1 addAnimation:pathAnimation forKey:nil];
    });
    
    dispatch_time_t when2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_after(when2, dispatch_get_main_queue(), ^{
        NSLog(@"1");
        
        [btn removeFromSuperview];
        // [self bigStart];
        //[_cameraView stop];
        
        NSString *result = [NSString stringWithFormat:@"瞳        距  :  %.0f\n\n脸        宽  :  %.0f\n\n鼻        宽  :  %.0f\n\n内眼角距  :  %.0f\n\n外眼角距  :  %.0f\n",[self AVGForArray:FacePartPupilDs],[self AVGForArray:FacePartFaceDs],[self AVGForArray:FacePartNoseDs],[self AVGForArray:FacePartInnerEyeDs],[self AVGForArray:FacePartOuterEyeDs]];
        // NSString *result = [NSString stringWithFormat:@"瞳        距  :  %@\n\n脸        宽  :  %.0f\n\n鼻        宽  :  %.0f\n\n内眼角距  :  %.0f\n\n外眼角距  :  %.0f\n",@"68",[self AVGForArray:FacePartFaceDs],[self AVGForArray:FacePartNoseDs],[self AVGForArray:FacePartInnerEyeDs],[self AVGForArray:FacePartOuterEyeDs]];
        
        measureValueViewController *meaValue = [[measureValueViewController alloc]init];
        meaValue.showImage = imgResult;
        meaValue.showValue = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            //        [self presentViewController:meaValue animated:YES completion:^{
            //
            //        }];
            //       [self.navigationController pushViewController:meaValue animated:YES];
            [self presentViewController:meaValue animated:YES completion:^{
                
            }];
        });
        
    });
    
}


- (float)AVGForArray:(NSMutableArray *)numbers{
    NSLog(@"count=%d",numbers.count);
    int maxIndex = 0;
    int minIndex = 0;
    float totle = 0;
    for (int i = 0; i < numbers.count; i++) {
        totle += [numbers[i] floatValue];
        if ([numbers[maxIndex] floatValue] < [numbers[i] floatValue]) {
            maxIndex = i;
        }
        if ([numbers[minIndex] floatValue] > [numbers[i] floatValue]) {
            minIndex = i;
        }
    }
    if (numbers.count >2) {
        totle -= [numbers[maxIndex] floatValue];
        totle -= [numbers[minIndex] floatValue];
        return totle / (numbers.count - 2);
    }else if(numbers.count > 1){
        
        totle -= [numbers[0] floatValue];
        return totle;
    }else{
        return totle;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [motionManager stopDeviceMotionUpdates];
    
}
@end
