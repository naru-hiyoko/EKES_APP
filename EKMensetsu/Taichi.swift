//
//  Taichi.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/24.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import CoreGraphics
import AVFoundation

internal enum FaceType: String {
    case normal = "m01_face_00_m.png"
    case high = "m01_face_010_m.png"
    case low = "m01_face_020_m.png"
    case shame = "m01_face_030_m.png"
}


protocol CharactorProtocol {
 
    var visible: Bool { get set }
    
    func findMaterial(named: String) -> SCNMaterial?
    func runAnimation(AnimationFile file: String, events: [SCNAnimationEvent]?, repeatCount: Float?)
    func removeAllAnimation()
    func faceChange(type: FaceType)

}

fileprivate class Animator
{
    public var charactor: CharactorProtocol?
    
    private var matrix: Dictionary<String, CGPoint> = [:]
    private var animationFiles: Dictionary<String, String> = [:]
    private var callBackFuncs: Dictionary<String, ((Void) -> [SCNAnimationEvent])> = [:]
    private var repeatCount: Dictionary<String, Float> = [:]
    

    public var xy: CGPoint = CGPoint.init(x: 0.0, y: 0.0) {
        didSet {
            state = _state
        }
    }
    
    public var z: Float = 0.0 {
        didSet {
            if z != oldValue {
                switch z {
                case let _z where _z <= -1.0:
                    self.charactor?.faceChange(type: .low)
                case let _z where _z >= 1.0:
                    self.charactor?.faceChange(type: .high) 
                case let _z where _z >= 2.0:
                    self.charactor?.faceChange(type: .shame)
                default:
                    self.charactor?.faceChange(type: .normal)
                }
            }
        }
    }
    
    init() {
        addState(tag: "idle", Position: CGPoint.init(x: 0.0, y: 0.0), animationFile: "m01@idle_00.dae", events: nil)
        
        addState(tag: "greet01", Position: CGPoint.init(x: 1.0, y: 0.0), animationFile: "m01@greet_00.dae", repeatCount: 1.0, events: wait1)
        addState(tag: "greet02", Position: CGPoint.init(x: 2.0, y: 0.0), animationFile: "m01@greet_02.dae", repeatCount: 1.0, events: wait1)
        addState(tag: "offering", Position: CGPoint.init(x: 3.0, y: 0.0), animationFile: "m01@offerhug_00.dae", repeatCount: 1.0, events: wait1)        
        addState(tag: "reachout", Position: CGPoint.init(x: 4.0, y: 0.0), animationFile: "m01@reachout_00.dae", repeatCount: 1.0, events: wait1)                
        
        addState(tag: "lookdown", Position: CGPoint.init(x: -1.0, y: -1.0), animationFile: "m01@lookdown_00.dae", repeatCount: 1.0, events: nil)
        
        addState(tag: "nod", Position: CGPoint.init(x: 0.0, y: -1.0), animationFile: "m01@nod_00.dae",  repeatCount: 1.0, events: wait1)
//        addState(tag: "wink", Position: CGPoint.init(x: 0.3, y: 0.0), animationFile: "m01@wink_00.dae", events: wait1)                

        addState(tag: "pathead", Position: CGPoint.init(x: 10.0, y: 10.0), animationFile: "m01@pathead_00.dae",  repeatCount: 1.0, events: wait1)        
        

        addState(tag: "salute", Position: CGPoint.init(x: 5.0, y: 5.0), animationFile: "m01@salute_00.dae",  repeatCount: 1.0, events: wait1)                        
        
        addState(tag: "refuse01", Position: CGPoint.init(x: -1.0, y: 0.0), animationFile: "m01@refuse_00.dae",  repeatCount: 1.0, events: wait1)                
        addState(tag: "refuse02", Position: CGPoint.init(x: -2.0, y: 0.0), animationFile: "m01@refuse_01.dae",  repeatCount: 1.0, events: wait1)                        
        
    }
    

    private var _state: String {
        var eval: Dictionary<String, Float> = [:]
        for key in self.matrix.keys {
            let p: CGPoint = self.matrix[key]!
            let _d: CGFloat = sqrt(pow(p.x - xy.x, 2.0) + pow(p.y - xy.y, 2.0))
            eval[key] = Float(_d)
        }
        
        let (tag, _) = eval.min(by: { (val1, val2) in
            let (_, d1) = val1
            let (_, d2) = val2
            return d1 < d2 ? true : false
        })!
        
        return tag
    }
    
    private var state: String = "" {
        didSet {
            if state != oldValue {
                print(state)
                guard let f = self.callBackFuncs[state] else {
                        self.charactor?.runAnimation(AnimationFile: animationFiles[state]!, events: nil, repeatCount: nil)
                    
                    return
                }
                if self.repeatCount[state] != nil {
                    self.charactor?.runAnimation(AnimationFile: animationFiles[state]!, events: f(), repeatCount: self.repeatCount[state]!)
                } else {
                    self.charactor?.runAnimation(AnimationFile: animationFiles[state]!, events: f(), repeatCount: nil)
                }
            }
        }
        
    }

    private func addState(tag: String, Position p: CGPoint, animationFile file: String, repeatCount c: Float? = nil, events f: ((Void) -> [SCNAnimationEvent])?) {
        matrix[tag] = p
        self.animationFiles[tag] = file
        self.callBackFuncs[tag] = f
        self.repeatCount[tag] = c
    }
 
}

extension Animator
{
    func wait1() -> [SCNAnimationEvent]
    {
        return [SCNAnimationEvent.init(keyTime: 1.0, block: { (anim, obj, t) in
            anim.repeatCount = 1
            self.xy = CGPoint.init(x: 0.0, y: 0.0)
        })]
        
    }
    
    
    
}

class Taichi : CharactorProtocol
{
    private var body: SCNNode!
    public var skeleton: SCNNode!
    private var animator: Animator = Animator()
    
    public var visible: Bool = false {
        willSet {
            if newValue {
                if let scene = GameManager.gameView!.scene {
                    scene.rootNode.addChildNode(self.body)
                    scene.rootNode.addChildNode(self.skeleton)
                }
            } else {
                if let _ = GameManager.gameView!.scene {
                    self.body.removeFromParentNode()
                    self.skeleton.removeFromParentNode()
                    self.skeleton.removeAllAnimations()
                }
            }
        }
    }
    
    public var action: CGPoint = CGPoint.init(x: 0.0, y: 0.0) {
        willSet {
            animator.xy = newValue
        }
    }
    
    public var emotion: Float = 0.0 {
        willSet {
            animator.z = newValue
        }
    }

    
    public init() {
        let scene = SCNScene.init(named: "m01_casualwear_00_m.dae")!
        self.body = scene.rootNode.childNode(withName: "m01", recursively: false)!
        self.skeleton = scene.rootNode.childNode(withName: "PelvisRoot", recursively: false)!
        self.loadBoneAnimations()

        animator.charactor = self
        runAnimation(AnimationFile: "m01@idle_00.dae", events: [], repeatCount: nil)
        
    }
    
    
    internal func findMaterial(named: String) -> SCNMaterial?
    {
        var _mat: SCNMaterial?
        
        func recursive(node: SCNNode)
        {
            if let geometry = node.geometry {
                if let mat = geometry.material(named: named) {
                    _mat = mat
                }
            }
            
            for child in node.childNodes
            {
                recursive(node: child)
            }
        }
        
        recursive(node: self.body)
        return _mat
    }
    
    internal func faceChange(type: FaceType)
    {
        let mat = findMaterial(named: "m01_face_00_m")
        mat!.diffuse.contents = UIImage.init(named: type.rawValue)

    }
    
    
    
    internal func removeAllAnimation() {
        self.skeleton.removeAllAnimations()
    }
    
    
    var animationAssets: Dictionary<String, SCNNode> = [:]
    func loadBoneAnimations()
    {
        for name in ["m01@idle_00.dae", "m01@greet_00.dae", "m01@greet_02.dae", "m01@lookdown_00.dae", 
                     "m01@nod_00.dae", "m01@offerhug_00.dae", "m01@pathead_00.dae", 
                     "m01@wink_00.dae", "m01@salute_00.dae", "m01@refuse_01.dae", "m01@refuse_00.dae", "m01@reachout_00.dae"]
        {
            let asset = SCNScene.init(named: name)!
            animationAssets[name] = asset.rootNode.childNode(withName: "PelvisRoot", recursively: false)!
        }
    }
    
    
    internal func runAnimation(AnimationFile file: String, events: [SCNAnimationEvent]?, repeatCount: Float? = nil)
    {
//        let asset = SCNScene.init(named: file)!
//        let _skeleton = asset.rootNode.childNode(withName: "PelvisRoot", recursively: false)!
        let _skeleton = animationAssets[file]!
        
        func recursive(node: SCNNode)
        {
            if let name = node.name {
                if let bone: SCNNode = self.skeleton!.childNode(withName: name, recursively: true) {
                    for key in node.animationKeys {
                        let animation = node.animation(forKey: key)!
                        if events != nil {
                            animation.animationEvents = events
                        }
                        if repeatCount != nil {
                            animation.repeatCount = repeatCount!
                        }

                        bone.addAnimation(animation, forKey: key)
                    }
                }
                
            }

            for child in node.childNodes
            {
                recursive(node: child)
            }
        }
        
        for _s in _skeleton.childNodes
        {
            recursive(node: _s)
        }
            
    }
}
