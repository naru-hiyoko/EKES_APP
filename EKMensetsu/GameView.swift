//
//  GameView.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/24.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class GameView: SCNView
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.overlaySKScene?.touchesBegan(touches, with: event)
    }
}
