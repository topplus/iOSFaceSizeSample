//
//  FaceSiceView.h
//  faceSizeForiOS
//
//  Created by Jeavil on 15/12/19.
//  Copyright © 2015年 topplusvision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

/*  FacePartPupilD,         //瞳距
	FacePartFaceD,          //脸宽
	FacePartNoseD,          //鼻宽
	FacePartInnerEyeD,      //内眼角距
	FacePartOuterEyeD,      //外眼角距
    DetectedPic             //返回的UIImage数据
 */

static const NSString *FacePartPupilD = @"emFacePartPupilD";
static const NSString *FacePartFaceD = @"emFacePartFaceD";
static const NSString *FacePartNoseD = @"emFacePartNoseD";
static const NSString *FacePartInnerEyeD = @"emFacePartInnerEyeD";
static const NSString *FacePartOuterEyeD = @"emFacePartOuterEyeD";
static const NSString *DetectedPic = @"DetectedPic";


@interface FaceSiceView : GLKView

- (BOOL) SDKInit;

- (void) start;

- (void) stop;

- (void) SetIndicatorImg:(UIImage *)img;

@end
