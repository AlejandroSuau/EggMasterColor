//
//  GameScene.swift
//  EggMasterColor
//
//  Created by Alejandro Suau Ruiz on 17/1/17.
//  Copyright © 2017 Alejandro Suau Ruiz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let playerWidth: CGFloat = 300.0
    let playerHeight: CGFloat = 45.0
    
    let TileWidth: CGFloat = 50.0
    let TileHeight: CGFloat = 54.0
    
    var gameViewController: GameViewController!
    
    let gameLayer = SKNode()
    let enemiesLayer = SKNode()
    let playerLayer = SKNode()
    
    var lastAnimatedCountDownSecond = 3
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
        addChild(gameLayer)
        gameLayer.isHidden = true
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 1.45)
        
        enemiesLayer.position = layerPosition
        gameLayer.addChild(enemiesLayer)

        playerLayer.position = layerPosition
        gameLayer.addChild(playerLayer)
        
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    func placePlayer() {
        playerLayer.removeAllChildren()
        
        let sprite = SKSpriteNode(imageNamed: gameViewController.player.spriteName)
        sprite.size = CGSize(width: playerWidth, height: playerHeight)
        sprite.position = CGPoint(
            x: TileWidth * CGFloat(NumColumns) / 2,
            y: 385)
        
        gameViewController.player.sprite = sprite
        playerLayer.addChild(sprite)
        
        if !gameViewController.isPaused {
            animatePlayer()
        }
    }
    
    func animatePlayer() {
        let frequencyToChangeColor = gameViewController.player.frequencyToChangeColor
        let sprite = gameViewController.player.sprite
        sprite?.run(SKAction.resize(toWidth: 0, duration: frequencyToChangeColor))
    }
    
    override func update(_ currentTime: TimeInterval) {
        gameViewController.updateGameItems(currentTime)
    }
    
    func addSprites(for enemies: Set<Enemy>) {
        for enemy in enemies {
            let sprite = SKSpriteNode(imageNamed: enemy.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: enemy.column, row: enemy.row)
            enemiesLayer.addChild(sprite)
            enemy.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ])
            )
        }
    }
    
    func animateIncorrectColors(for enemies: Set<Enemy>) {
        guard !enemies.isEmpty else { return }
        
        for enemy in enemies {
            enemy.sprite?.run(SKAction.scale(to: 1, duration: 0))
            enemy.sprite?.removeAction(forKey: "animateCorrect")
        }
    }
    
    func animateCorrectColors(for enemies: Set<Enemy>) {
        guard !enemies.isEmpty else { return }
        
        for enemy in enemies {
            enemy.sprite?.run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: 0.85, duration: 0.20),
                    SKAction.scale(to: 1.0, duration: 0.20)
                    ])
            ), withKey: "animateCorrect")
        }
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func animateBeginGame(_ completion: @escaping () -> ()) {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
    }
    
    func removeAllEnemiesSprites() {
        enemiesLayer.removeAllChildren()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: enemiesLayer)
        let (success, column, row) = convertPoint(point: location)
        
        if success {
            if let enemy = gameViewController.level.enemyAt(column: column, row: row) {
                gameViewController.processEnemyTouch(enemy: enemy)
            }
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func animateGameOver(_ completion: @escaping () -> ()) {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
    }
    
    func animateShoot(for enemy: Enemy, completion: @escaping() -> ()) {
        let projectile = Projectile()
        let playerSprite = gameViewController.player.sprite!
        let projectileSprite = SKSpriteNode(imageNamed: enemy.spriteName)
        let centerPosition = CGPoint(
            x: (playerSprite.position.x),
            y: (playerSprite.position.y))
        projectileSprite.size = CGSize(width: projectile.with, height: projectile.height)
        projectileSprite.zPosition = playerSprite.zPosition + 100
        projectileSprite.position = centerPosition
        enemiesLayer.addChild(projectileSprite)
        
        let enemyCGPoint = pointFor(column: enemy.column, row: enemy.row)
        let moveAction = SKAction.move(to: enemyCGPoint, duration: 0.20)
        let moveAndDissappears = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        projectileSprite.run(moveAndDissappears, completion: completion)
    }
    
    func animateDestroy(for enemy: Enemy, score: Int, isCombo: Bool, completion: @escaping() -> ()) {
        animateScore(for: enemy, quantity: score, isCombo: isCombo)
        if let sprite = enemy.sprite {
            if sprite.action(forKey: "removing") == nil {
                let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                scaleAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                           withKey: "removing")
            }
        }

        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateScore(for enemy: Enemy, quantity: Int, isCombo: Bool) {
        let sprite = enemy.sprite!
        let centerPosition = CGPoint(
            x: sprite.position.x,
            y: sprite.position.y)
        
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 20
        scoreLabel.text = "+" + String(format: "%ld", quantity)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        enemiesLayer.addChild(scoreLabel)
        
        if isCombo {
            scoreLabel.text = scoreLabel.text! + " COMBO "
        }
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    func animateCountDown(currentSecond: Int) {
        guard currentSecond >= 0 && currentSecond != lastAnimatedCountDownSecond else { return }

        lastAnimatedCountDownSecond = currentSecond
        
        let centerPosition = CGPoint(
            x: self.position.x + 150,
            y: self.position.y + 320
        )
        let sprite = SKSpriteNode(imageNamed: "Second-\(currentSecond+1)")
        sprite.zPosition = 300
        sprite.position = centerPosition
        enemiesLayer.addChild(sprite)

        sprite.run(SKAction.sequence([
                SKAction.scale(to: 0, duration: 1),
                SKAction.removeFromParent()
            ]))
    }
}
