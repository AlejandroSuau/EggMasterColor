import UIKit
import SpriteKit
import GameplayKit

class GameOverViewController: UIViewController
{
    var skView: SKView!
    
    var scene: GameOverScene!
    
    override func viewDidLoad() {
        print("entro en game over controller")
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameOverScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(scene)
    }
}
