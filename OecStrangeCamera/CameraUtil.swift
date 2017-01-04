
import Foundation
import UIKit
import AVFoundation

class CameraUtil {
    class func imageForOrb(buffer: CMSampleBuffer) -> UIImage {
        let resultImage: UIImage = ImageProcessing.orb(initImage(buffer: buffer))
        return resultImage
    }
    
    class func imageForGray(buffer: CMSampleBuffer) -> UIImage {
        let resultImage: UIImage = ImageProcessing.gray(initImage(buffer: buffer))
        return resultImage
    }
    class func imageForLaplacian(buffer: CMSampleBuffer) -> UIImage {
        let resultImage: UIImage = ImageProcessing.laplacian(initImage(buffer: buffer))
        return resultImage
    }
    class func imageForHough(buffer: CMSampleBuffer) -> UIImage {
        let resultImage: UIImage = ImageProcessing.hough(initImage(buffer: buffer))
        return resultImage
    }
    class func imageForFace(buffer: CMSampleBuffer) -> UIImage {
        let resultImage: UIImage = ImageProcessing.face(initImage(buffer: buffer))
        return resultImage
    }
    
    class func initImage(buffer: CMSampleBuffer) -> UIImage {
        let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(buffer)!
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect: CGRect = CGRectMake(0, 0, pixelBufferWidth, pixelBufferHeight)
        let ciContext = CIContext.init()
        let cgimage = ciContext.createCGImage(ciImage, from: imageRect )
        
        
        return UIImage(cgImage: cgimage!)
    }
    
    class func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
