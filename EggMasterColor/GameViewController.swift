//
//  GameViewController.swift
//  EggMasterColor
//
//  Created by Alejandro Suau Ruiz on 17/1/17.
//  Copyright © 2017 Alejandro Suau Ruiz. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var skView: SKView!
    
    @IBOutlet weak var timeTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    let warningSeconds: Double = 11
    var gameTimeManager: GameTimeManager!
    
    let countDownSeconds: Double = 3.0
    var countDownTimer: GameTimeManager!
    var hasFinishedCountDown = false
    
    var scene: GameScene!
    var level: Level!
    var isLevelCompleted = false
    var isPaused = true

    var player: Player!
    var score: Int = 0
    var comboMultiplier = 0
    
    // TESTING
    var currentLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.gameViewController = self

        // Present the scene.
        skView.presentScene(scene)
        
        beginGame()
    }

    func beginGame() {
        comboMultiplier = 0
        scene.lastAnimatedCountDownSecond = Int(countDownSeconds)
        hasFinishedCountDown = false
        isPaused = true
        scene.isUserInteractionEnabled = false
        if (currentLevel > 6) {
            currentLevel = 0
        }
        
        countDownTimer = GameTimeManager(initTime: self.countDownSeconds)
        level = Level(filename: "Level_\(currentLevel)")
        player = Player(
            frequencyChangeColor: level.frequencyToChangeColor, colorsQuantity: level.colorsQuantity
        )
        
        isLevelCompleted = false
        score = 0
        gameTimeManager = GameTimeManager(initTime: level.startingTime)
        scene.animateBeginGame {}
        scene.placePlayer()
        updateLabels()
        shuffle()
    }
    
    func shuffle() {
        scene.removeAllEnemiesSprites()
        let newEnemies = level.shuffle()
        scene.addSprites(for: newEnemies)
    }
    
    func updateGameItems(_ currentTime: TimeInterval) {
        let parsedDoubleCurrentTime = Double(currentTime)
        guard hasFinishedCountDown(parsedDoubleCurrentTime) && !isPaused else { return }
        
        if gameTimeManager.isTimeOver() {
            showGameOver()
        } else {
            gameTimeManager.update(parsedDoubleCurrentTime)
            player.update(parsedDoubleCurrentTime)
            
            if player.hasChangedColor() {
                self.processPlayerColorChanged()
                animateAliveEnemies()
            }
            
            updateLabels()
        }
    }
    
    private func hasFinishedCountDown(_ currentTime: Double) -> Bool {
        guard !hasFinishedCountDown else { return true }
        
        if countDownTimer.isTimeOver() {
            hasFinishedCountDown = true
            isPaused = false
            scene.isUserInteractionEnabled = true
            scene.animatePlayer()
            animateAliveEnemies()
            return true
        } else {
            countDownTimer.update(currentTime)
            scene.animateCountDown(currentSecond: Int(countDownTimer.timeSinceBeginning))
            return false
        }
    }
    
    func animateAliveEnemies() {
        let (correctEnemies, incorrectEnemies) = level.filteredEnemies(itemColor: player.itemColor)
        scene.animateIncorrectColors(for: incorrectEnemies)
        scene.animateCorrectColors(for: correctEnemies)
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        scoreLabel.text = String(format: "%ld", score)
        
        timeLabel.text = String(format: "%ld", Int(gameTimeManager.timeSinceBeginning))
        if gameTimeManager.timeSinceBeginning < self.warningSeconds {
            timeTextLabel.textColor = UIColor.red
            timeLabel.textColor = UIColor.red
        } else {
            timeTextLabel.textColor = UIColor.white
            timeLabel.textColor = UIColor.white
        }
    }
    
    func processPlayerColorChanged() {
        comboMultiplier = 0
        player.previousItemColor = player.itemColor
        
        if let enemy = level.searchEnemyWithThis(itemColor: player.itemColor) {
            player.calculateMaxErrorColorsAllowed()
        } else {
            if player.hasMaxErrorColorsAllowed() {
                player.itemColor = level.randomEnemyColor()
                player.calculateMaxErrorColorsAllowed()
            } else {
                player.errorColors += 1
            }
        }
        
        scene.placePlayer()
    }
    
    func processEnemyTouch(enemy: Enemy) {
        if player.itemColor == enemy.itemColor {
            enemy.receiveDamage()
            
            let enemyScore: Int
            if !enemy.isAlive() {
                enemyScore = destroyEnemy(enemy: enemy)
            } else {
                enemyScore = 0
            }
            
            let isCombo = comboMultiplier > 1
            scene.animateShoot(for: enemy) {
                if !enemy.isAlive() {
                    self.scene.animateDestroy(for: enemy, score: enemyScore, isCombo: isCombo) {
                        self.hasCompletedLevel()
                    }
                }
            }
        } else {
            processIncorrectTouch()
        }
    }
    
    private func hasCompletedLevel() {
        guard !isLevelCompleted && score >= level.targetScore else { return }
        
        updateLabels()
        isLevelCompleted = true
        showGameOver()
    }
    
    private func destroyEnemy(enemy: Enemy) -> Int {
        level.remove(enemy: enemy)
        level.decreaseAliveEnemiesQuantity()
        comboMultiplier += 1
        let enemyScore = enemy.enemyType.score * comboMultiplier
        incrementScore(quantity: enemyScore)
        
        if level.aliveEnemiesQuantity == 0 && score < level.targetScore {
            shuffle()
        }
        
        return enemyScore
    }
    
    private func incrementScore(quantity: Int) {
        self.score += quantity
    }
    
    func processIncorrectTouch() {
        player.receiveDamage()
        if !player.isAlive() {
            showGameOver()
        }
    }
    
    func showGameOver() {
        print("Game over guys")
        isPaused = true
        gameOverPanel.isHidden = false
        
        if isLevelCompleted {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevel += 1
        } else {
            gameOverPanel.image = UIImage(named: "GameOver")
        }
        
        scene.isUserInteractionEnabled = false
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func hideGameOver() {
        guard tapGestureRecognizer != nil else { return }
        view.removeGestureRecognizer(tapGestureRecognizer!)
        tapGestureRecognizer = nil
        
        gameOverPanel.isHidden = true
        scene.isUserInteractionEnabled = true
        
        beginGame()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
