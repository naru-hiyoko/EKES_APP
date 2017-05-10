//
//  SceneEvents.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/28.
//  Copyright © 2017 naru. All rights reserved.
//


import Foundation
import SpriteKit
import SceneKit
import CoreGraphics
import UIKit


let updateStateEventName: Notification.Name = Notification.Name.init("updateState")

protocol SceneEvent {
    var progress: Float { get }
    
    func eventStart()
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?) 
    func update(_ currentTime: TimeInterval)    
    
}

class InitEvent: SceneEvent
{
    var progress: Float = 0.0
    private var _to: Float = 0.0
    
    init(to: Float) {
        self._to = to
    }
    
    func eventStart() {
        AI.speech.clear()
        GameManager.facePreview.cgImage = nil
        NotificationCenter.default.post(name: updateStateEventName, object: nil, userInfo: ["to": self._to])
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
    
    func update(_ currentTime: TimeInterval) {
        //
    }
    
}


class WaitTapEvent: SceneEvent
{
    let notification = Notification.Name.init("updateState")    
    
    private var _progress: Float
    private var _to : Float
    private var _f : ((Void) -> (Void))?
    private var _text: String = ""
    
    var progress: Float {
        return _progress
    }
    
    init(_ prog: Float, _ to: Float, f: (() ->())? = nil, msg: String = "") {
        self._progress = prog
        self._to = to
        self._f = f
        self._text = msg
    }
    
    func update(_ currentTime: TimeInterval) {
        //
        
    }
    
    
    func eventStart() {
        if _f != nil {
            _f!()
        }
        GameManager.tapHereIcon?.isHidden = false
        GameManager.tapHereInconInfo?.isHidden = false
        GameManager.tapHereInconInfo?.text = self._text
    }
    
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        GameManager.tapHereIcon?.isHidden = true
        GameManager.tapHereInconInfo?.isHidden = true
        NotificationCenter.default.post(name: notification, object: nil, userInfo: ["to": self._to])
    }
    
    
}

class ConversationEvent : SceneEvent
{
    let notification = Notification.Name.init("updateState")    
    
    private var _progress: Float
    private var _to : Float
    private var _msg: String = ""
    private var _f: ((Void) -> (Void))?
    
    var progress: Float {
        return _progress
    }
    
    init(_ msg: String, _ prog: Float, _ to: Float, f: (() ->())? = nil) {
        self._progress = prog
        self._to = to
        self._msg = msg
        self._f = f
    }
    
    
    func eventStart() {
        GameManager.messageBox.setPhrases(self._msg)
        GameManager.messageBox.startPhrases(complete: msgEnded)
        
        if _f != nil {
            _f!()
        }
        
    }
    
    func msgEnded()
    {
        
        NotificationCenter.default.post(name: notification, object: nil, userInfo: ["to" : self._to])
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?) 
    {
        
    }
    
    func update(_ currentTime: TimeInterval) {
        
    }
    
    
}

class SpeechEvent: SceneEvent
{
    private var _prog: Float
    private var _to: Float
    
    private var _start_t = 0.0
    private var _current_t = 0.0

    private var _timeout = 2.0
    private var _gained_at_t = 0.0
    
    private var _should_exit = false
    
    var progress: Float { 
        return _prog
    }
    
    init(_ prog: Float, _ to: Float) {
        self._prog = prog
        self._to = to
    }
    
    func eventStart() {
        AI.speech.startRecording()
        GameManager.CircleIcon?.isHidden = false
        GameManager.VoiceRecogIcon?.isHidden = false
        
        self._should_exit = false
        _current_t = CACurrentMediaTime()
        _start_t = CACurrentMediaTime()
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        say()
    }
    
    func say()
    {
        if self._should_exit {
            return
        } else {
            self._should_exit = true
            print("exit")
        }
        
        if AI.speech.isActive {
            let _ = AI.speech.stopRecording()
            
        }
        
        GameManager.CircleIcon?.isHidden = true
        GameManager.VoiceRecogIcon?.isHidden = true
        
        var m_text = "\n"
        for (i, c) in AI.speech.speechText.characters.enumerated() {
            if i % 6 == 0 {
                m_text += "\n"
            } 
            m_text += String(c)
        }
        m_text += "\n\n"
        
        
        GameManager.messageBox.faceIconNode.texture = SKTexture.init(imageNamed: "YourFaceIcon")
        GameManager.messageBox.setPhrases(m_text)
        GameManager.messageBox.startPhrases(complete: self.msgEnd)
        
    }
    
    func msgEnd() {
        let n = Notification.Name.init("updateState")             
        NotificationCenter.default.post(name: n, object: nil, userInfo: ["to": self._to])
        
    }
    
    
    private var oldText: String = "" {
        didSet {
            self._gained_at_t = CACurrentMediaTime()
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        self._current_t = CACurrentMediaTime()
        
        if oldText != AI.speech.speechText {
            oldText = AI.speech.speechText
        }
        
        if self._current_t - self._start_t > 5.0 && (CACurrentMediaTime() - self._gained_at_t) > self._timeout
        {
            say()
        }
        
        if self._current_t - self._start_t > 60.0 {
            say()
        }
    }
    
}

class CloudEvent : SceneEvent
{
    let notification = Notification.Name.init("updateState") 
    
    private var _p : Float = 0.0
    private var _t : Float = 0.0
    private var errOccurred: Bool = false
    
    public var progress: Float {
        return self._p
    }

    
    
    
    init(_ p: Float, _ t: Float) {
        self._p = p
        self._t = t
    }
    
    func eventStart() {
        //
        var content: Dictionary<String, Data> = [:]
        content["agent"] = "ios".data(using: .utf8)!
        if GameManager.facePreview.cgImage != nil {
            content["image"] = UIImageJPEGRepresentation(UIImage.init(cgImage: GameManager.facePreview.cgImage!), 0.6)
//            print(GameManager.facePreview.cgImage)
        }
        
        if AI.speech.speechText != "" {
            content["speechText"] = AI.speech.speechText.data(using: .utf8)!
            content["speechTime"] = "\(AI.speech.speechTime)".data(using: .utf8)!
            print("send speech data")
        }
        
        if AI.uniq != "" {
            content["uniq"] = AI.uniq.data(using: .utf8)!
        }
        
        content["shouldTalk"] = "\(AI.stage)".data(using: .utf8)
        
        AI.cloud.sendData(content, callback: { (data, response, err) in 
            GameManager.messageBox.faceIconNode.texture = SKTexture.init(imageNamed: "CharFaceIcon")
            
            if err == nil {
//                print(String.init(data: data!, encoding: .utf8))
//                return
                do {
                
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any>
                    if let str = json["msg"] as? String {
                        AI.cloud.text = str
                    } else {
                        AI.cloud.text = "サーバーエラー"
                    }
                    
                    
                    print(AI.cloud.text)
                    AI.cloud.parseData(data!)
                } catch _ {
                    AI.cloud.text = "サーバーエラー"
                    self.errOccurred = true
                }
                GameManager.messageBox.setPhrases(AI.cloud.text)
                GameManager.messageBox.startPhrases(complete: self.msgEnded)
            } else {
                self.errOccurred = true                
                GameManager.messageBox.setPhrases("通信エラーです")
                GameManager.messageBox.startPhrases(complete: self.msgEnded)
            }


        })



    }
    
    func msgEnded()
    {
        if self.errOccurred {
            NotificationCenter.default.post(name: self.notification, object: nil, userInfo: ["to": Float(-1.0)])
        } else {
            NotificationCenter.default.post(name: self.notification, object: nil, userInfo: ["to": self._t])                    
        }
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
    
    func update(_ currentTime: TimeInterval) {
        //
    }
}

class ScriptEvent: SceneEvent
{
    let notification = Notification.Name.init("updateState")    
    
    private var _progress: Float
    private var _to : Float
    private var _f : ((Void) -> (Void))?
    
    var progress: Float {
        return _progress
    }
    
    init(_ prog: Float, _ to: Float, f: @escaping (() ->())) {
        self._progress = prog
        self._to = to
        self._f = f
    }
    
    func update(_ currentTime: TimeInterval) {
        //
        
    }
    
    
    func eventStart() {
        _f!()
        NotificationCenter.default.post(name: notification, object: "", userInfo: ["to": self._to])
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        

    }
    
    
}

class GotoEvent: SceneEvent
{
    let notification = Notification.Name.init("updateState")    
    
    private var _progress: Float
    private var _to : Float = 0.0
    private var _f : ((Void) -> Float)?
    
    var progress: Float {
        return _progress
    }
    
    init(_ prog: Float, f: @escaping (() -> Float)) {
        self._progress = prog
        self._f = f
    }
    
    func update(_ currentTime: TimeInterval) {
        //
        
    }
    
    
    func eventStart() {
        self._to = _f!()
        NotificationCenter.default.post(name: notification, object: "", userInfo: ["to": self._to])
    }
    
    func touchBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        
    }
    

}


