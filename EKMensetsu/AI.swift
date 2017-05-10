//
//  AI.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/27.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import Speech
import AVFoundation
import Darwin
import NetworkExtension

import SpriteKit




class AISpeech : NSObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate
{
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?    
    private let audioSession = AVAudioSession.sharedInstance()   
    
    private var inputNode: AVAudioInputNode!
    
    private var _start_t : CFTimeInterval = 0.0
    private var _end_t : CFTimeInterval = 0.0
    public var speechTime : CFTimeInterval {
        return self._end_t - self._start_t
    }

    var isActive : Bool {
        if self.recognitionTask == nil { 
            return false
        }
        return self.recognitionTask!.isCancelled ? false : true
    }
    
    var isEnable: Bool = false
    
    public var speechText: String 
    {
        return self.text
    }

    private var text: String = "" {
        didSet {
            print(text)
        }
    }
    
    public var intensity : Float = 0.0

    override init() {
        super.init()

        if let node = self.audioEngine.inputNode {
            self.inputNode = node
            let recordingFormat = self.inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                let p = buffer.floatChannelData!
                let data = p.pointee

                let b = UnsafeMutableBufferPointer<Float>(start: data, count: 128)
                var avg_intensity: Float = 0.0
                for val in b {
                    avg_intensity += val
                }
                avg_intensity = max(avg_intensity , 0.01) * 12
                avg_intensity = max(avg_intensity, 0.0)
                avg_intensity = min(avg_intensity, 2.0)

                self.intensity = avg_intensity
                if GameManager.CircleIcon != nil {
                    GameManager.CircleIcon?.size = CGSize.init(width: 100 * 3, height: 100 * 3)
                    let child = GameManager.CircleIcon?.childNode(withName: "VoiceRecog") as? SKSpriteNode
                    child?.size = CGSize.init(width: 100 * 1.0, height: 100 * 1.0)

                    GameManager.CircleIcon?.xScale = 1.0 + CGFloat(avg_intensity)
                    GameManager.CircleIcon?.yScale = 1.0 + CGFloat(avg_intensity)
                }
                
                self.recognitionRequest?.append(buffer)
            }
            
        }

    }
    
    public func clear() {
        self.text = ""
        self._start_t = 0.0
        self._end_t = 0.0
        
    }
    
    func startRecording()
    {
        self.text = ""
        self._start_t = CACurrentMediaTime()

        SFSpeechRecognizer.requestAuthorization({ (status) in
            switch status {
            case .authorized:
                print("authorized")
            case .denied:
                print("denied")
            case .restricted:
                print("restricted")
            case .notDetermined:
                print("not determined")
                
            }
        })

        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        if self.recognitionRequest != nil {
            self.recognitionRequest = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()        
        recognitionRequest?.shouldReportPartialResults = true
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

        } catch {
            print("audioSession properties weren't set because of an error.")
            return
        }
        

        
        
        
        let speechRecognizer = SFSpeechRecognizer.init(locale: Locale.init(identifier: "ja_JP"))!
        

        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: { ( result, error) in 
            if result != nil {
                self.text = result!.bestTranscription.formattedString
            }
        })
        

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
            return
        }
        
        self.isEnable = true
        
        GameManager.CircleIcon?.isHidden = false
        
        
    }
    
    func stopRecording() -> String {
        GameManager.CircleIcon?.isHidden = true
        
        self._end_t = CACurrentMediaTime()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        audioEngine.stop()
        print("done")
        return self.text
    }
    

}

class AICloud
{
    #if DEBUG
//    let url = URL.init(string: "http://192.168.1.3:8000/cgi-bin/server.py")
    let url = URL.init(string: "http://192.168.1.4:21000/server.py")
    #else
    let url = URL.init(string: "http://.ddns.net:21000/server.py")
    #endif
    private var session : URLSession!
    
//    public var statusCode: Int = 0
    
    // text received from server
    public var text: String = ""
    
    init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func sendData(_ contents: Dictionary<String, Data>, callback: @escaping ((Data?, URLResponse?, Error?) -> Void))
    {
        let obj = Request.init(url: self.url!)
        obj.post(contents)
        let task = self.session.dataTask(with: obj.request, completionHandler: callback)
        
        task.resume()
    }
    
    func receiveData(data: Data?, response: URLResponse?, err: Error?) 
    {

        if err == nil {
//            let statusCode = (response as! HTTPURLResponse).statusCode
            self.text = String.init(data: data!, encoding: .utf8)!

        } else {
            print(err!)
        }
        
    }
    
    public func parseData(_ data: Data)
    {
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>
        var p = CGPoint.init(x: 0.0, y: 0.0)
        
        for key in json.keys 
        {
            switch key {
            case "msg":
                if let str = json[key] as? String {
                    self.text = str
                } else {
                    self.text = "無効な入力"
                }
            case "x":
                p.x = json[key] as! CGFloat
            case "y":
                p.y = json[key] as! CGFloat
            case "z":
                GameManager.taichi.emotion = json[key] as! Float
            case "shouldTalk":
                AI.stage = json[key] as! Int
            case "uniq":
                print("id: \(json[key]!)")
                AI.uniq = json[key] as! String
            default:
                print("pass")
            }
            
        }
        GameManager.taichi.action = p
    }
}

class AI : NSObject
{
    static let speech = AISpeech()
    static let cloud = AICloud()
    static var stage: Int = 0
    static var uniq : String = ""
    
    #if DEBUG
    static let register_url: URL = URL.init(string: "http://192.168.1.4/register.py")!
    #else
    static let register_url: URL = URL.init(string: "http://.ddns.net:21000/register.py")!
    #endif
    
    
    override init() {
        super.init()
    }

    
}
