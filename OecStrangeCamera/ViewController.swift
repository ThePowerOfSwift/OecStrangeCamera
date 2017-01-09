// ViewController.swift
import UIKit
import AVFoundation
import AssetsLibrary
class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var _orbButton: UIButton!
    @IBOutlet var _grayButton: UIButton!
    @IBOutlet var _thButton: UIButton!
    @IBOutlet var _startButton: UIButton!
    @IBOutlet var _houghButton: UIButton!
    @IBOutlet var _faceButton: UIButton!
    @IBOutlet var _signalStopButton: UIButton!
    @IBOutlet var _carButton: UIButton!
    
    var session : AVCaptureSession!
    var device : AVCaptureDevice!
    var output : AVCaptureVideoDataOutput!

    var isRecording = false
    var mode = 0
    
    let fileOutput = AVCaptureMovieFileOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //デフォルトは局所特徴量ORB
        _orbButton.backgroundColor = UIColor.blue
        if initCamera() {
            session.startRunning()
        }
    }
    // メモリ解放
    override func viewDidDisappear(_ animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        device = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func start(_ startButton: UIButton) {
        startButton.backgroundColor = UIColor.gray
        if var _:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
            // アルバムに追加
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
        }
        startButton.backgroundColor = UIColor.red
    }

    @IBAction func gray(_ grayButton: UIButton) {
        resetButtonColor()
        grayButton.backgroundColor = UIColor.blue
        self.mode=1;
    }
    @IBAction func orb(_ orbButton: UIButton) {
        resetButtonColor()
        orbButton.backgroundColor = UIColor.blue
        self.mode=0;
    }
    @IBAction func th(_ thButton: UIButton) {
        resetButtonColor()
        thButton.backgroundColor = UIColor.blue
        self.mode=2;
    }
    @IBAction func hough(_ houghButton: UIButton) {
        resetButtonColor()
        houghButton.backgroundColor = UIColor.blue
        self.mode=3;
    }
    @IBAction func face(_ faceButton: UIButton) {
        resetButtonColor()
        faceButton.backgroundColor = UIColor.blue
        self.mode=4;
    }
    @IBAction func signalStop(_ signalStopButton: UIButton) {
        resetButtonColor()
        signalStopButton.backgroundColor = UIColor.blue
        self.mode=5;
    }
    
    @IBAction func car(_ carButton: UIButton) {
        resetButtonColor()
        carButton.backgroundColor = UIColor.blue
        self.mode=6;
    }
    
    func resetButtonColor(){
        _signalStopButton.backgroundColor = UIColor.lightGray
        _houghButton.backgroundColor = UIColor.lightGray
        _thButton.backgroundColor = UIColor.lightGray
        _orbButton.backgroundColor = UIColor.lightGray
        _grayButton.backgroundColor = UIColor.lightGray
        _carButton.backgroundColor = UIColor.lightGray
    }
    
    func initCamera() -> Bool {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
 
        if device == nil {
            return false
        }
        
        do {
            let myInput: AVCaptureDeviceInput?
            try myInput = AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(myInput) {
                session.addInput(myInput)
            } else {
                return false
            }
            
            output = AVCaptureVideoDataOutput()
            output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA) ]
            
            try device?.lockForConfiguration()
            device?.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            device?.unlockForConfiguration()
            
            let queue: DispatchQueue = DispatchQueue(label: "myqueue", attributes: [])
            output.setSampleBufferDelegate(self, queue: queue)
            
            output.alwaysDiscardsLateVideoFrames = true
            
            
        } catch let error as NSError {
            print(error)
            return false
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            return false
        }
        
        for connection in output.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.isVideoOrientationSupported {
                    conn.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        
        return true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        DispatchQueue.main.async(execute: {
            if(self.mode==0){
                let image: UIImage = CameraUtil.imageForOrb(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==1){
                let image: UIImage = CameraUtil.imageForGray(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==2){
                let image: UIImage = CameraUtil.imageForLaplacian(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==3){
                let image: UIImage = CameraUtil.imageForHough(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==4){
                let image: UIImage = CameraUtil.imageForFace(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==5){
                let image: UIImage = CameraUtil.imageForSignalStop(buffer: sampleBuffer)
                self.imageView.image = image;
            }else if(self.mode==6){
                let image: UIImage = CameraUtil.imageForCarDetect(buffer: sampleBuffer)
                self.imageView.image = image;
            }
            
        })
    }

}
