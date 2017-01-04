

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface OpenCVHelper : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
@end
