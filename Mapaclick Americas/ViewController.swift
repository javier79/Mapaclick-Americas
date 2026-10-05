//
//  ViewController.swift
//  Mapaclick Americas
//
//  Created by javier pizarro on 3/11/26.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //let practiceRandomGame = PracticeRandomGameScene(size: view.bounds.size)
        //let gameOverScene = GameOverScene(size: view.bounds.size)
        //let practiceAlphabeticGame = PracticeAlphabeticGameScene(size: view.bounds.size)
        //let randomGame = RandomGameScene(size: view.bounds.size)
        //let startMenu = StartMenuScene(size: view.bounds.size)
        //let instructions = Instructions(size: view.bounds.size)
        //let startScene = StartScene(size: view.bounds.size)/*startScene() call object size to be same as the view and assigned to*/
        let skView = view as! SKView/*it cast(change) default view(UIView) to an SKView. For this line to work we needed before hand to define under
         custom class the class SKView as we already do. Otherwise the app will crash.*/

        //skView.showsFPS = true//frame per seconds indicator
        skView.showsPhysics = true//enables the usage of SKPhysicsBody properties,without this SKPhysicsBody will not work
        //skView.showsNodeCount = true

//        if UIDevice.current.userInterfaceIdiom == .pad {
//            let alphabeticGameScene = AlphabeticGameScene(size: view.bounds.size)
//            skView.presentScene(alphabeticGameScene)
//        } else {
//            let alphabeticGameScene = AlphabeticGameScene(size: CGSize(width: 375, height: 667))
//            alphabeticGameScene.scaleMode = .aspectFill
//            skView.presentScene(alphabeticGameScene)
//        }

        //TEMPORARY for testing the RandomGameScene port.
        if UIDevice.current.userInterfaceIdiom == .pad {
            let randomGameScene = RandomGameScene(size: view.bounds.size)
            skView.presentScene(randomGameScene)
        } else {
            let randomGameScene = RandomGameScene(size: CGSize(width: 375, height: 667))
            randomGameScene.scaleMode = .aspectFill
            skView.presentScene(randomGameScene)
        }

        //TEMPORARY for testing the PracticeAlphabeticGameScene port. Flag must be set before the scene is created so country name labels get added to the map.
//        StartMenuScene.playPracticeAlphabeticGame = true
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            let practiceAlphabeticGameScene = PracticeAlphabeticGameScene(size: view.bounds.size)
//            skView.presentScene(practiceAlphabeticGameScene)
//        } else {
//            let practiceAlphabeticGameScene = PracticeAlphabeticGameScene(size: CGSize(width: 375, height: 667))
//            practiceAlphabeticGameScene.scaleMode = .aspectFill
//            skView.presentScene(practiceAlphabeticGameScene)
//        }
    }


}

