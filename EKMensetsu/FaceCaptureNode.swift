//
//  FaceCaptureNode.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/27.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import AVFoundation



class FaceCaptureNode : SKSpriteNode, AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    public var session: AVCaptureSession!
    
    init() {
        super.init(texture: nil, color: UIColor.clear, size: CGSize.init(width: 250.0, height: 150.0))
        self.zRotation = -1.0 * CGFloat.pi / 2.0
        getBackCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getBackCamera()
    {
        guard let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                                         mediaType: AVMediaTypeVideo,
                                                         position: AVCaptureDevicePosition.front)
//        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

            else {
                print("camera device not found!")
                return
        }
        

        
        self.session = AVCaptureSession.init()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPreset352x288
        
        // configure input device.
        do {
            let _input = try AVCaptureDeviceInput.init(device: device)
            if session.canAddInput(_input) {
                session.addInput(_input)
            } else {
                print("can't add input")
            }
            
        } catch let e {
            print(e)
            return
        }
        
        // configure output device.
        do {
            let _output = AVCaptureVideoDataOutput.init()

            _output.alwaysDiscardsLateVideoFrames = true
            _output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCVPixelFormatType_32BGRA, 
                                      ]
            _output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            
            if session.canAddOutput(_output) {
                session.addOutput(_output)
            } else {
                print("can't add output")
            }
        }
        
        
        session.commitConfiguration()
        
//        session.startRunning()
//        print("done")
        
    }
    
    
    private var _t = CACurrentMediaTime()
    
    private let color_space = CGColorSpaceCreateDeviceRGB()
    private let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    public var cgImage: CGImage? = nil

    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        /**
        if (CACurrentMediaTime() - _t > 0.5)
        {
            _t = CACurrentMediaTime()
        } else {
            return
        }
        */
    
        
//        DispatchQueue.main.sync {
        
            let buf = CMSampleBufferGetImageBuffer(sampleBuffer)!
            CVPixelBufferLockBaseAddress(buf, .readOnly)
        
            let data = CVPixelBufferGetBaseAddressOfPlane(buf, 0)


            let width = CVPixelBufferGetWidth(buf)
            let height = CVPixelBufferGetHeight(buf)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(buf)


            let ctx = CGContext.init(data: data, width: width, height: height,
                                 bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: color_space, bitmapInfo: info)!
        
        
//            self.texture = nil
//            self.texture = SKTexture.init(cgImage: ctx.makeImage()!)
            self.cgImage = ctx.makeImage()
        
            CVPixelBufferUnlockBaseAddress(buf, .readOnly)
//            self.session.stopRunning()
//        }


    }
    
    
}
