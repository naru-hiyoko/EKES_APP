    //
//  AppMain.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/24.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit



class AppMainScene : SKScene
{
    internal var progress: Float = -1.0 {
        didSet {
            if progress != oldValue {
                self.event?.eventStart()
            }
        }
    }
    
    private var _events: [SceneEvent] = []
    
    public var event: SceneEvent? {
        return self._events.min(by: { (a, b) in
            return abs(a.progress - self.progress) < abs(b.progress - self.progress) ? true : false
        })
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        GameManager.taichi.visible = true
        GameManager.taichi.skeleton.position = GameManager.gameView!.scene!.rootNode.childNode(withName: "Pos", recursively: false)!.position
        GameManager.taichi.skeleton.rotation = GameManager.gameView!.scene!.rootNode.childNode(withName: "Pos", recursively: false)!.rotation        
        
        
        self.addChild(GameManager.messageBox)
        self.addChild(GameManager.facePreview)

        let prevPos = self.scene!.childNode(withName: "prevPos") as! SKSpriteNode
        let textPos = self.scene!.childNode(withName: "textPos") as! SKSpriteNode
        
        GameManager.tapHereIcon = self.scene!.childNode(withName: "TapHere") as? SKSpriteNode
        GameManager.tapHereIcon?.isHidden = true
        GameManager.tapHereInconInfo = self.scene!.childNode(withName: "TapHereInfo") as? SKLabelNode
        GameManager.tapHereInconInfo?.isHidden = true
        
        prevPos.isHidden = true
//        textPos.isHidden = true
        
        GameManager.facePreview.position = prevPos.position
        GameManager.messageBox.position = textPos.position
        GameManager.messageBox.size = textPos.size
        

        GameManager.CircleIcon = self.scene!.childNode(withName: "Circle") as? SKSpriteNode 
        GameManager.CircleIcon?.isHidden = true
        GameManager.VoiceRecogIcon = self.scene!.childNode(withName: "VoiceRecog") as? SKSpriteNode
        GameManager.VoiceRecogIcon?.isHidden = true
        
        let notification = Notification.Name.init("updateState")
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil, using: changeState(notification:))
        
        self.setupEvents()

    }
    
    func changeState(notification: Notification)
    {
        if let info = notification.userInfo {
            self.progress = info["to"] as! Float
        }

    }
    
    internal func AddEvent(_ ev: SceneEvent) {
        self._events.append(ev)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.event?.touchBegan(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        self.event?.update(currentTime)
    }
    
}

extension AppMainScene
{
    func setupEvents()
    {
        AddEvent(WaitTapEvent.init(-1.0, 0.0, f: nil, msg: "話す"))
        
        AddEvent(InitEvent.init(to: 1.0))
        
        AddEvent(ScriptEvent.init(1.0, 2.0, f: {
            GameManager.facePreview.session.startRunning()
        }))
        
        AddEvent(WaitTapEvent.init(2.0, 3.0, f: nil, msg: "話す"))
        
        AddEvent(ScriptEvent.init(3.0, 4.0, f: {
            GameManager.facePreview.session.stopRunning()
        }))
        
        AddEvent(CloudEvent(4.0, 4.5))
       
        AddEvent(GotoEvent.init(4.5, f: {
            if AI.stage == 100 {
                AI.stage = 0
                return 7.0
            } else {
                return 5.0
            }
        }))

        

       
        AddEvent(SpeechEvent.init(5.0, 6.0))        
        
        AddEvent(CloudEvent.init(6.0, 0.0))
        
        AddEvent(ScriptEvent.init(7.0, 0.0, f: {
            let __url = URL.init(string: "\(AI.register_url)?uniq=\(AI.uniq)")!
            UIApplication.shared.open(__url, options: [:], completionHandler: nil)
//            print(AI.uniq)
            AI.uniq = ""
        }))

        
    }
}

