//
//  MenuScene.swift
//  EggMasterColor
//
//  Created by Alejandro Suau Ruiz on 1/2/17.
//  Copyright © 2017 Alejandro Suau Ruiz. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene
{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    override func update(_ currentTime: TimeInterval) {

    }

}
