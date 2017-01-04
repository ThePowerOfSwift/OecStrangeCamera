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
+(UIImage *)orb:(UIImage *)image;
+(UIImage *)laplacian:(UIImage *)image;
+(UIImage *)maskBlue:(UIImage *)image;
+(UIImage *)detect:(UIImage *)image;
+(UIImage *)various:(UIImage *)image;
+(UIImage *)hough:(UIImage *)image;
+(UIImage *)face:(UIImage *)image;
@end
