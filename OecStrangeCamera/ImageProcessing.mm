
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OecStrangeCamera-Bridging-Header.h"

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
    cv::Canny(gray, edge, 80, 10);
    
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
+ (UIImage *)laplacian:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    cv::Mat tmp_img;
    cv::Mat laplacian_img;
    cv::Laplacian(gray, tmp_img, CV_32F, 3);
    cv::convertScaleAbs(tmp_img, laplacian_img, 1, 0);
    return [OpenCVHelper UIImageFromCVMat:laplacian_img];
}
+ (UIImage *)hough:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat dst_img, work_img;
    dst_img = mat.clone();
    cv::cvtColor(mat, work_img, CV_BGR2GRAY);
    cv::Canny(work_img, work_img, 50, 200, 3);
    
    // 確率的Hough変換
    std::vector<cv::Vec4i> lines;
    // 入力画像，出力，距離分解能，角度分解能，閾値，線分の最小長さ，
    // 2点が同一線分上にあると見なす場合に許容される最大距離
    cv::HoughLinesP(work_img, lines, 1, CV_PI/180, 50, 50, 10);
    
    std::vector<cv::Vec4i>::iterator it = lines.begin();
    for(; it!=lines.end(); ++it) {
        cv::Vec4i l = *it;
        cv::line(dst_img, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,0,255), 2, CV_AA);
    }

    return [OpenCVHelper UIImageFromCVMat:dst_img];
}
+ (UIImage *)face:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    double scale = 2.0;
    cv::Mat gray, smallImg(cv::saturate_cast<int>(mat.rows/scale), cv::saturate_cast<int>(mat.cols/scale), CV_8UC1);
    // グレースケール画像に変換
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    // 処理時間短縮のために画像を縮小
    cv::resize(gray, smallImg, smallImg.size(), 0, 0, cv::INTER_LINEAR);
    cv::equalizeHist( smallImg, smallImg);
    
    // 分類器の読み込み
    NSString *cascadeName = @"haarcascade_frontalface_alt.xml";
    NSString *path = [[NSBundle mainBundle] pathForResource:cascadeName
                                                     ofType:nil];
    std::string cascade_path = (char *)[path UTF8String];
    cv::CascadeClassifier cascade;
    if (!cascade.load(cascade_path)) {
        NSLog(@"Couldn't load haar cascade file.");
        return nil;
    }
    std::vector<cv::Rect> faces;
    /// マルチスケール（顔）探索
    // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
    cascade.detectMultiScale(smallImg, faces,
                             1.1, 2,
                             CV_HAAR_SCALE_IMAGE,
                             cv::Size(30, 30) );
    
//    NSString *nested_cascadeName = @"haarcascade_eye.xml";
//    NSString *nested_cascadeName_path_resource = [[NSBundle mainBundle] pathForResource:nested_cascadeName
//                                                     ofType:nil];
//    std::string nested_cascadeName_path = (char *)[nested_cascadeName_path_resource UTF8String];
//    cv::CascadeClassifier nested_cascade;
//    if (!nested_cascade.load(nested_cascadeName_path)) {
//        
//        NSLog(@"Couldn't load haar nested cascade file.");
//        return nil;
//    }
    std::vector<cv::Rect>::const_iterator r = faces.begin();
    for(; r != faces.end(); ++r) {
        
        // 検出結果（顔）の描画
        cv::Point face_center;
        int face_radius;
        face_center.x = cv::saturate_cast<int>((r->x + r->width*0.5)*scale);
        face_center.y = cv::saturate_cast<int>((r->y + r->height*0.5)*scale);
        face_radius = cv::saturate_cast<int>((r->width + r->height)*0.25*scale);
        cv::circle( mat, face_center, face_radius, cv::Scalar(80,80,255), 3, 8, 0 );
        
        
//        cv:: Mat smallImgROI = smallImg(*r);
//        std::vector<cv::Rect> nestedObjects;
//        /// マルチスケール（目）探索
//        // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
//        nested_cascade.detectMultiScale(smallImgROI, nestedObjects,
//                                        1.1, 3,
//                                        CV_HAAR_SCALE_IMAGE,
//                                        cv::Size(10,10));
//        
//        
//        // 検出結果（目）の描画
//        std::vector<cv::Rect>::const_iterator nr = nestedObjects.begin();
//        for(; nr != nestedObjects.end(); ++nr) {
//            cv::Point center;
//            int radius;
//            center.x = cv::saturate_cast<int>((r->x + nr->x + nr->width*0.5)*scale);
//            center.y = cv::saturate_cast<int>((r->y + nr->y + nr->height*0.5)*scale);
//            radius = cv::saturate_cast<int>((nr->width + nr->height)*0.25*scale);
//            cv::circle( mat, center, radius, cv::Scalar(80,255,80), 3, 8, 0 );
//        }
    }
    
    return [OpenCVHelper UIImageFromCVMat:mat];
}
+ (UIImage *)maskBlue:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat dst;
    
    // グレイスケール変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // Set threshold and maxValue
    double thresh = 105;
    double maxValue = 255;
    
    // Binary Threshold
    threshold(mat,dst, thresh, maxValue, cv::THRESH_BINARY);
    return [OpenCVHelper UIImageFromCVMat:dst];
}
+ (UIImage *)detect:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat dst;
    
    // グレイスケール変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // Set threshold and maxValue
    double thresh = 105;
    double maxValue = 255;
    
    // Binary Threshold
    threshold(mat,dst, thresh, maxValue, cv::THRESH_BINARY);
    return [OpenCVHelper UIImageFromCVMat:dst];
}
+ (UIImage *)various:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat dst;
    
    // グレイスケール変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    // Set threshold and maxValue
    double thresh = 105;
    double maxValue = 255;
    
    // Binary Threshold
    threshold(mat,dst, thresh, maxValue, cv::THRESH_BINARY);
    return [OpenCVHelper UIImageFromCVMat:dst];
}
@end
