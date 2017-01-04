

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FaceTrackingTest-Bridging-Header.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVHelper.h"

@implementation ImageProcessing: NSObject

+(UIImage *)gray:(UIImage *)image{
    
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // グレイスケール変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // 画像のエッジを検出
    cv::Mat edge;
    cv::Canny(gray, edge, 200, 100);
    
    UIImage *result = MatToUIImage(edge);
    
    return result;
}
+ (UIImage *)orb:(UIImage *)image
{
    cv::Mat srcMat = [OpenCVHelper cvMatFromUIImage:image];
    // detector 生成
    cv::Ptr<cv::FeatureDetector> detector = cv::ORB::create();
    // 特徴点抽出
    std::vector<cv::KeyPoint> keypoints;
    detector->detect(srcMat, keypoints);
    
    // 特徴点を描画
    cv::Mat dstMat;
    
    dstMat = srcMat.clone();
    for(int i = 0; i < keypoints.size(); i++) {
        
        cv::KeyPoint *point = &(keypoints[i]);
        cv::Point center;
        int radius;
        center.x = cvRound(point->pt.x);
        center.y = cvRound(point->pt.y);
        radius = cvRound(point->size*0.25);
        
        cv::circle(dstMat, center, radius, cvScalar(rand()&255, rand()&255, rand()&255));
    }
    return [OpenCVHelper UIImageFromCVMat:dstMat];
}
@end
