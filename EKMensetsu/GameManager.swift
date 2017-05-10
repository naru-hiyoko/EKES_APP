//
//  Scenes.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/24.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class GameManager 
{
    static let taichi : Taichi = Taichi()
    
    static let messageBox = TextFrameNode(size: CGSize.init(width: 600.0,height: 300.0), FrameImageName: "frame")
    static let facePreview = FaceCaptureNode()
    
    static var tapHereIcon: SKSpriteNode? = nil
    static var tapHereInconInfo: SKLabelNode? = nil
    
    static var CircleIcon: SKSpriteNode? = nil
    static var VoiceRecogIcon: SKSpriteNode? = nil
    
    
    static var gameView: GameView? {
        willSet {
            newValue?.isPlaying = true
        }
    }
    
    
    static func AppMainScene() 
    {
        guard let view = GameManager.gameView else {
            return
        }
        
        view.scene = SCNScene.init(named: "AppMain.dae")

        let huf = SKScene.init(fileNamed: "AppMain.sks") as! AppMainScene
        view.overlaySKScene = huf
        view.overlaySKScene?.scaleMode = SKSceneScaleMode.fill
        // call first event!
        huf.progress = 0.0
        

    }
}
