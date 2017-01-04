//
//  FaceTrackingTest-Bridging-Header.h
//  FaceTrackingTest
//
//  Created by 尾石元気 on 2017/01/01.
//  Copyright © 2017年 motoki oishi. All rights reserved.
//

#ifndef FaceTrackingTest_Bridging_Header_h
#define FaceTrackingTest_Bridging_Header_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef __cplusplus
#import "opencv2/imgcodecs/ios.h"
#import <opencv2/opencv.hpp>
#endif

@interface ImageProcessing: NSObject
+(UIImage *)gray:(UIImage *)image;
// function do detect feature points
+(UIImage *)orb:(UIImage *)image;
@end
#endif /* FaceTrackingTest_Bridging_Header_h */
