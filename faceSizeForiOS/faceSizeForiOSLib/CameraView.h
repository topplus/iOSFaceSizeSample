//
//  CameraView.h
//  faceSizeForiOS
//
//  Created by Jeavil on 15/12/24.
//  Copyright © 2015年 topplusvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraView : UIView

@property (nonatomic, strong) UIImage* indicatorImg;

//初始化
- (BOOL) SDKInit;

//开始结束
- (void) start;

//结束视屏显示
- (void) stop;

//设置引导图标
- (void) SetIndicatorImg:(UIImage *)img;

@end
