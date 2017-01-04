//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


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
