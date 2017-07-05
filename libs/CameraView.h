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

- (void)setLicense:(NSString *)Client_id andSecret:(NSString *)Clicent_secret;

/**
 *  @brief 保存日志，参数为空默认保存至 NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject/topglasses.log
 *
 *  filePath： 保存日志的路径
 */
- (void)saveLogToFile:(NSString *)filePath;
@end
