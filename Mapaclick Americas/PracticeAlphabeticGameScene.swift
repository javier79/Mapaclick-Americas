//
//  PracticeAlphabeticGameScene.swift
//  mapaclick
//
//  Created by javier pizarro on 9/26/23.
//

import Foundation
import SpriteKit
//import UIKit
import AVFoundation

class PracticeAlphabeticGameScene: SKScene{
    let gameSceneObjects = GameSceneObjects()/*backgroundNode needs self properties for the size param, i need to call GameSceneObjects() class where initialization function for backgroundNode lives(this class hold all initialization parameters for all objects on the game scene).
                                              The initialization of backgroundNode occurs on did move, as self and its properties are not available until run time*/
    var backgroundNode: SKSpriteNode!//declared as var in order to be initialized on didMove when self is available(read comment for gameSceneObjects declaration up^
    
    // Tutorial overlay
    var tutorialOverlay: TutorialOverlay?
    var isTutorialActive: Bool = false
    
    let mapRectangleGestureMGMT: SKSpriteNode = GameSceneObjects().mapRectangleGestureMGMTBezierPathToSKSpriteNode(bpRectangle: BezierPathsForMapNodesAndRectangles().createRectangle())//This Node is invisible, it works by parenting containeNode and applying handgestures as SKNode have no anchor point property which is needed to be set at 0.5 for the pinch gesture to be able to zoom and be centered
    let mapRectangleBackground: SKSpriteNode = GameSceneObjects().mapRectangleBackground(bpRectangle: BezierPathsForMapNodesAndRectangles().createRectangle())
    
    let controlPanelSKSpriteNode = GameSceneObjects().initControlPanel()
    let skipButton = GameSceneObjects().skipBlueButton()//used in more than one function
    let exitRedButton = GameSceneObjects().redButton()//used in more than one function
    
    let containerNode = InitSetMapNodes().initSetcontainerNodeAndChildren()//Node container for map nodes and map frames. Used in more than one function
    let labelTimer = GameSceneObjects().labelForTimer()//used in more than one function
    let labelScores = GameSceneObjects().labelForScores()//Scores label(in fluorocent text)
    //let timerBackground = TestClass().timerBackGround()//This background was used when the timer used a background for seconds(0-59) and a wider background for when minutes(1:00) started to render.
    let timerBackgroundTwo = GameSceneObjects().timerBackGroundTwo()/*Background for timer(At one time the timer used two different size backgrounds, but later i opted out of doing that for eficiency and kept
    the bigger background(timerBackgroundTwo) as timer's only background along its life cycle */
    let municipioNameLabel = GameSceneObjects().labelForCountryNames()//Label rendering country name to look up, Used in more than one function
    let municipiosNameBackground = GameSceneObjects().labelCountriesNameBackground()//Background for most(shorter) country names. Used in more than one function
    let municipiosNameBackgroundTwo = GameSceneObjects().labelCountriesNameBackgroundTwo()//Background for longer country names. Used in more than one function
    let municipiosNameBackgroundThree = GameSceneObjects().labelCountriesNameBackgroundThree()
    let municipiosNameBackgroundFour = GameSceneObjects().labelCountriesNameBackgroundFour()
    
    /**following two variables(renderTime and changeTime)  are basic part of the timer mechanism  and should not be bothered, in case dev wants to understand  how they work roll back to a branch previous to timer function makeover and follow the comments, but again dev should not be too concerned with this variables*/
    var renderTime: TimeInterval = 0.0//marks the time being played to be compared with currentTime, only used on update(timer function)
    let changeTime: TimeInterval = 1//adds(update) to renderTime in order to keep renderTime running, only used on update(imer function)
    var seconds: Int = 0//seconds count, only used on update(imer function)
    var minutes: Int = 0//minutes count, only used on update(imer function)
    static var secondsGameOver:Int = 0 //gets number of seconds to render tracked time(renders on gameOverScene), static variables must be declared at the top
    static var minutesGameOver:Int = 0 //gets number of minutes to render tracked time(renders on gameOverScene), static variables must be declared at the top
    let skipButtonPenalty = 15//seconds added to timer when skip buttom is pressed
    let penalty = 3//seconds added to timer when wrong node is pressed
    
    static var completedGame = false/**flow control variable for timer once its value is true allows for timer to stop, and transition to gameOverScene*/
    
    var useLine2:Bool = false//used on splitTextIntoFields functions and touch function.(intrinsic to function mechanism, dev should not be too concerned with it)
    //var twoLineText: String = ""//used on splitTextIntoFields, this is the text passed to splitTextIntoFields functions
    
    /** Array includes Adjuntas although it' is written from the function that sets the label for municipios to look up, this is due  if adjuntas is skipped when the array reach the end to go back to index 0, then it gets Adjuntas.
     This array contain the text elements for the municipios to look up*/
    var municipios_names_array = ["Adjuntas", "Aguada", "Aguadilla", "Aguas Buenas", "Aibonito", "Arecibo", "Arroyo", "Añasco", "Barceloneta", "Barranquitas", "Bayamón", "Cabo Rojo", "Caguas", "Camuy", "Canóvanas", "Carolina", "Cataño", "Cayey", "Ceiba", "Ciales", "Cidra", "Coamo", "Comerío", "Corozal", "Culebra", "Dorado", "Fajardo", "Florida", "Guayama", "Guayanilla", "Guaynabo","Gurabo", "Guánica", "Hatillo", "Hormigueros", "Humacao", "Isabela", "Jayuya", "Juana Díaz", "Juncos", "Lajas", "Lares", "Las Marías", "Las Piedras", "Loíza", "Luquillo", "Manatí", "Maricao", "Maunabo", "Mayagüez", "Moca", "Morovis", "Naguabo", "Naranjito", "Orocovis", "Patillas", "Peñuelas", "Ponce", "Quebradillas", "Rincón", "Rio Grande", "Sabana Grande", "Salinas", "San Germán", "San Juan", "San Lorenzo", "San Sebastián", "Santa Isabel", "Toa Alta", "Toa Baja", "Trujillo Alto", "Utuado", "Vega Alta", "Vega Baja", "Vieques", "Villalba", "Yabucoa", "Yauco"]
    
    var fail: Bool!//flow control var allow when true for penalty to be added at timer funtion. Used on more than one funtion
    var currentIndex: Int = 0 //refers to index currently diplayed on municipio name label declared at the top to be accesed by accesory functions
    var pressSKipButton:Bool = false//Flow control variables when true allows timer to add 15 penalty
    var scoreCount:Int = 0//variable represent the number of municipios identified rendered in the control bar to the right
    let totalScoreCount:String = "/78"
    
    let correctSound = SKAction.playSoundFileNamed("351566__bertrof__game-sound-correct-organic-violin", waitForCompletion: false)
    let incorrectSound = SKAction.playSoundFileNamed("351565__bertrof__game-sound-incorrect-organic-violin", waitForCompletion: false)
    
    //var musicPlayer = AVAudioPlayer()//audio player
    var musicPlayer: AVAudioPlayer?//Claude suggested
    let musicURL:URL? = Bundle.main.url(forResource:"predited", withExtension:"mp3")//reference to PR Himn

    var skipButtonPressed = false//flow control var allows to apply alpha animation to skipbuttom on Touches end
    var isScaled = false
    
    var isAdShowing: Bool = false//Ads Logic
    
    let screenSize = UIScreen.main.nativeBounds
    
    override func didMove(to view: SKView) {

        NotificationCenter.default.addObserver(self, selector: #selector(adWillShow), name: AdManager.adWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adDismissed), name: AdManager.adDismissedNotification, object: nil)
        backgroundNode = gameSceneObjects.createSceneBackground(scene: self)
        //self.backgroundColor = UIColor.init(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0)//blue background that resembles the ocean
        
        /**The following  objects are the parent for all rendering objects, class positioning attributers are applied in order for objects to render the same independent of the screen size, In the case of containerNode it's positioning is set  based on its parent
         timerBackgroundTwo. The reason for not giving containerNode class positioning was due when class attributes were applied to containerNode it would render different in devices with smaller screen size(maybe something im not aware about, or a glitch of some kind).*/
        //mapRectangleGestureMGMT.zPosition = 0
        mapRectangleGestureMGMT.anchorPoint = CGPoint(x:0.5, y:0.5)
        mapRectangleGestureMGMT.name = "mapRectangle"
        //mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.8)
        
        //containerNode.zPosition = -1
        containerNode.position = CGPoint(x:-280, y:-190)//CGPoint(x:self.size.width/2 - 285, y:self.size.height/2 - 175) /*CGPoint(x:-275 , y:-75 /*15*/)*//**Sknode containing(children) map sprites, desecheo cover(node whose only job is to hid desecheo island, rectangular frames)*/
        containerNode.name = "containerNode"
        //timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.zPosition = 1//Set to one in order for the map to zoom and remain behind
        controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:50)
        controlPanelSKSpriteNode.name = "controlPanelSKSpriteNode"
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 16.5/*25*/)
        
        //Set scaling and positioning(for game play objects) attributes are set accordingly with screen size
        debugPrint("Screen size: \(screenSize)")
        switch (screenSize.width, screenSize.height) {
            
            case (2048.0, 2732.0):
                 debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3)")
                 setScaleAndIndepRenderingPositioningForIpadsLargeScreenSizes()
           
            case (1536.0, 2048.0),(1488.0, 2266.0) :
                 debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6)")
                 setScaleAndIndepRenderingPositioningForIpadsSmallScreenSizes()
            
        case (1668.0, 2224.0), (1668.0, 2388.0), (1620.0, 2160.0),(1640.0, 2360.0), (1668.0, 2420.0):
                debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad Pro 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5")
                setScaleAndIndepRenderingPositioningForIpadsMediumScreenSizes()
            
            case (750.0, 1334), (1080, 2340),(1125.0, 2436.0) ://PROPORTIONS LOOKS OK
                debugPrint("iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5)")
                setScaleAndIndepRenderingPositioningForSmallScreenSizes()
            
            case (1242.0, 2208.0), (828.0, 1792.0),(1242.0, 2688.0) ://PROPORTIONS COULD BE BETTER(PROPORTION FIXED AS SEPT 10 2025)
                debugPrint("iPhone 8plus, iPhone XR(18.5), iPhone 11(18.5), iPhoneXS Max(18.5), iPhone 11 ProMax(18.5)")
                //setScaleAndIndepRenderingPositioningForMediumLargeScreenSizes()
                setScaleAndIndepRenderingPositioningForMediumLargeScreenSizesTwo()
            
           case (1170.0, 2532.0), (1179.0, 2556.0)://Possible template to edit for iPhone 16 Pro PROPORTIONS COULD BE BETTER(PROPORTION FIXED AS SEPT 12 2025)
                debugPrint("iPhone 12(18.5), iPhone 12Pro(18.5), iPhone 13(18.5), iPhone 13 Pro(18.5), iPhone 14(18.5), iPhone 14 Pro(18.5), iPhone 15(18.6), iPhone 15 Pro(18.6), iPhone 16(18.6), iPhone 16e(18.6)")
                //setScaleAndIndepRenderingPositioningForLargeScreenSizes()
                setScaleAndIndepRenderingPositioningForLargeScreenSizesTwo()
            
           case (1284.0, 2778.0), (1290.0, 2796.0)://Possible template to edit for iPhone 16 Pro Max(PROPORTION FIXED AS SEPT 13 2025)
                debugPrint("iPhone 12ProMax(18.5), iPhone 13 Pro Max(18.5), iPhone 14 plus(18.5), iPhone 14 ProMax(18.5), iPhone 15 plus(18.6), iPhone 15 ProMax(18.6), iPhone 16 Plus(18.6)")
                setScaleAndIndepRenderingPositioningForXtraLargeScreenSizes()
            
           case (1206.0, 2622.0)/*, (1320.0, 2868.0)*/:
            debugPrint("iPhone 16 Pro(18.6), iPhone 17, iPhone 17 Pro")
            setScaleAndIndepRenderingPositioningForiPhone16Pro()
            
            case  (1320.0, 2868.0):
            debugPrint("iPhone 16 ProMAX(18.6), iPhone 17 ProMax")
            setScaleAndIndepRenderingPositioningForiPhone16ProMax()
        
            default:
               setScaleAndIndepRenderingPositioningForSmallScreenSizes()//This line will catch any device which screen measure is none of the above
                break
        }
        
        mapRectangleBackground.size = mapRectangleGestureMGMT.size
        mapRectangleBackground.position = mapRectangleGestureMGMT.position
        mapRectangleBackground.name = "mapRectangleBackground"
        
        /**Following objects are related to goldBackground SKSPriteNode*/
        //addChildSKSpriteNodeToParentself(children:containerSKSPriteNode)
        self.addChild(backgroundNode)
        self.addChild(mapRectangleBackground)
        addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: municipioNameLabel)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
        addChildSKLabelNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: labelScores)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: skipButton)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: exitRedButton)
        addChildSKSpriteNodeToParentself(children: controlPanelSKSpriteNode)
        addChildSKNodeToParentSKSpriteNode(parent:mapRectangleGestureMGMT, children:containerNode)
        //containerSKSPriteNode.addChild(containerNode)
        addChildSKSpriteNodeToParentself(children:mapRectangleGestureMGMT)
        //self.addChild(containerSKSPriteNode)
        //addChildSKNodeToParentself(children: containerNode)
        //addChildSKNodeToParentSKSpriteNode(parent: timerBackgroundTwo, children: containerNode)
        addChildSKLabelNodeToParentSKSpriteNode(parent: timerBackgroundTwo, children: labelTimer)
        addChildSKSpriteNodeToParentself(children: timerBackgroundTwo)
        //addChildSKNodeToParentself(children: containerNode)
        
        //set an call hand gesture recognizers
        let pinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action: #selector(self.handlePinchFrom(_:)))
        self.view!.addGestureRecognizer(pinchRecognizer)
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        // Add the gesture recognizer to the scene's view
        self.view!.addGestureRecognizer(panGestureRecognizer)
        
        
            
        if StartMenuScene.backgroundMusicOn == true{
            //self.addChild(StartScene.backgroundMusic)
            initMusic()
        }
        
        // FOR TESTING ONLY - REMOVE BEFORE RELEASE
                //TutorialManager.resetTutorialCount()
                //debugPrint("Tutorial count reset for testing")
        
        // Show tutorial if needed
        if TutorialManager.shouldShowTutorial() {
            showTutorial()
        }
        //Ads Logic
        if !TutorialManager.shouldShowTutorial() {
            showAdIfNeeded()
        }
        
    }
    //Ads Logic
    @objc func adWillShow() {
        isAdShowing = true
        print("adWillShow called - isAdShowing is now: \(isAdShowing)")
        musicPlayer?.pause()
    }
    //Ads Logic
    @objc func adDismissed() {
        isAdShowing = false
        print("adDismissed called - isAdShowing is now: \(isAdShowing)")
        musicPlayer?.play()
    }

    //Ads Logic
    /*func showAdIfNeeded() {
        let waitAction = SKAction.wait(forDuration: 0.1)
        let showAction = SKAction.run {
            AdManager.shared.showInterstitialForGameStart()
        }
        self.run(SKAction.sequence([waitAction, showAction]))
    }*/
    
    func showAdIfNeeded() {
        let waitAction = SKAction.wait(forDuration: 0.1)
        let showAction = SKAction.run { [weak self] in
            AdManager.shared.showInterstitialForGameStart()
            // If no interstitial was shown, show a banner at top instead
            if !AdManager.shared.lastGameStartShowedAd {
                if let viewController = self?.view?.window?.rootViewController {
                    AdManager.shared.showBannerAtTop(in: viewController)
                }
            }
        }
        self.run(SKAction.sequence([waitAction, showAction]))
    }
    
    
    //Execute attributes for scaling and positioning based on device screen size
    /*func setScaleAndIndepRenderingPositioningForIpadsLargeScreenSizes(){
        //debugPrint("Set StartScene gamePlay objts scaling and positioning for: iPads Pro12.9(3gen), Pro12.9(4gen), Pro12.9(5gen), Pro12.9(6gen) IpadsLargeScreenSizes scaling and positioning func")
        //debugPrint("Ipads Large Screen Sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)
        //mapRectangleGestureMGMT.setScale(1.90)//1.38
        mapRectangleGestureMGMT.setScale(2.4)//1.38
        
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 12.0)/**parent to labelTimer*/
        
        labelScores.position = CGPoint(x:440/*300*/, y:-7)
        labelScores.fontSize = 25.5
        
        controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:70)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 20.5) //14.8)
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 28.5)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 4.5) //14.8)
        //controlPanelSKSpriteNode.setScale(1.5)
        
        skipButton.setScale(2.1)
        skipButton.position = CGPoint(x:320, y:-0.5)
        exitRedButton.setScale(2.1)
        exitRedButton.position = CGPoint(x:-370, y:-0.5)
        
        timerBackgroundTwo.setScale(1.9)
        
        municipiosNameBackground.setScale(1.9)
    }*/
    
    func setScaleAndIndepRenderingPositioningForIpadsLargeScreenSizes(){
        debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3) enters scaling and positioning function")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*2.00*/)
        //mapRectangleGestureMGMT.setScale(1.90)//1.38
        mapRectangleGestureMGMT.setScale(2.4)//1.38
        
        timerBackgroundTwo.setScale(2.4)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 9.6)/**parent to labelTimer*/
        
        //labelScores.position = CGPoint(x:440/*300*/, y:-7)
        //labelScores.fontSize = 25.5
        
        //controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:70)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 20.5) //14.8)
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 24.5)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 4.5) //14.8)
        controlPanelSKSpriteNode.setScale(1.8)
        
        skipButton.setScale(1.35)
        //skipButton.position = CGPoint(x:320, y:-0.5)
        exitRedButton.setScale(1.35)
        //exitRedButton.position = CGPoint(x:-370, y:-0.5)
        
        //timerBackgroundTwo.setScale(1.9)
        
        municipiosNameBackground.setScale(1.3)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForIpadsSmallScreenSizes(){
        debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6) enters scaling and positioning function")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)
        //mapRectangleGestureMGMT.setScale(1.90)//1.38
        mapRectangleGestureMGMT.setScale(1.85)//1.38
        
        timerBackgroundTwo.setScale(2.0)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 8.7 )/**parent to labelTimer*/
        
        //labelScores.position = CGPoint(x:440/*300*/, y:-7)
        //labelScores.fontSize = 22.5
        
        //controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:64)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 20.5) //14.8)
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 22.5)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 4.5) //14.8)
        controlPanelSKSpriteNode.setScale(1.5)
        
        skipButton.setScale(1.4)
        //skipButton.position = CGPoint(x:320, y:-0.5)
        exitRedButton.setScale(1.4)
        //exitRedButton.position = CGPoint(x:-370, y:-0.5)
        
        //timerBackgroundTwo.setScale(1.85)
        
        municipiosNameBackground.setScale(1.4)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForIpadsMediumScreenSizes(){
        debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5 enters scaling and positioning function")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)
        //mapRectangleGestureMGMT.setScale(1.90)//1.38
        mapRectangleGestureMGMT.setScale(2.1)//1.85
        
        timerBackgroundTwo.setScale(2.1)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 9)/**parent to labelTimer*/
        
        //labelScores.position = CGPoint(x:440/*300*/, y:-7)
        //labelScores.fontSize = 22.5
        
        //controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:70)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 20.5) //14.8)
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 22.5)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 4.5) //14.8)
        controlPanelSKSpriteNode.setScale(1.5)
        
        skipButton.setScale(1.3)
        //skipButton.position = CGPoint(x:320, y:-0.5)
        exitRedButton.setScale(1.3)
        //exitRedButton.position = CGPoint(x:-370, y:-0.5)
        
        //timerBackgroundTwo.setScale(1.85)
        
        municipiosNameBackground.setScale(1.4)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    //Execute attributes for scaling and positioning based on device screen size
    /*func setScaleAndIndepRenderingPositioningForIpadsMediumScreenSizes(){
        //debugPrint("Set StartScene gamePlay objts scaling and positioning for: iPad Pro 10.5, Pro11(1gen), Air(3gen), 7Gen, Pro11(2gen), 8Gen, 9Gen, Air(4gen), PRO11(3gen), Air(5gen), 10Gen, Pro11(4gen) entering iPad Medium size scaling and positioning func")
        //debugPrint("Ipads Medium Screen Sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)
        //mapRectangleGestureMGMT.setScale(1.90)//1.38
        mapRectangleGestureMGMT.setScale(1.85)//1.38
        
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 9.5)/**parent to labelTimer*/
        
        labelScores.position = CGPoint(x:440/*300*/, y:-7)
        labelScores.fontSize = 22.5
        
        controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:70)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 20.5) //14.8)
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 22.5)
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 4.5) //14.8)
        //controlPanelSKSpriteNode.setScale(1.5)
        
        skipButton.setScale(2.00)
        skipButton.position = CGPoint(x:320, y:-0.5)
        exitRedButton.setScale(2.00)
        exitRedButton.position = CGPoint(x:-370, y:-0.5)
        
        timerBackgroundTwo.setScale(1.85)
        
        municipiosNameBackground.setScale(1.75)
    }*/
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForSmallScreenSizes(){
        debugPrint("Default Settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) enter scaling and positioning func")
        
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.33)//1.38
        
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6.4)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.8) //14.8)
        
        skipButton.setScale(1.50)
        exitRedButton.setScale(1.50)
        
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    //Execute attributes for scaling and positioning based on device screen size
    /*func setScaleAndIndepRenderingPositioningForMediumLargeScreenSizes(){
        //debugPrint("Set StartScene gamePlay objts scaling and positioning for: iPhone 8plus, XR, 11, XSMax, 11ProMax enter MediumLargeScreenSizes scaling and positioning func")
        //debugPrint("iPhone medium-large screen sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.906/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.33)//1.38
        
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6.7)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.8) //14.8)
        
        skipButton.setScale(1.50)
        exitRedButton.setScale(1.50)
        
        municipiosNameBackground.setScale(1.20)
    }*/
    
    func setScaleAndIndepRenderingPositioningForMediumLargeScreenSizesTwo(){
        debugPrint("iPhone 8plus, iPhone XR(18.5), iPhone 11(18.5), iPhoneXS Max(18.5), iPhone 11 ProMax(18.5) enters scaling and positioning func")
        //debugPrint("iPhone medium-large screen sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.716/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.45)//1.33
        
        timerBackgroundTwo.setScale(1.40)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 5.8)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.0) //13.5)
        controlPanelSKSpriteNode.setScale(1.25)
        
        skipButton.setScale(1.35)
        exitRedButton.setScale(1.35)
        //ATTENTION OF ALL THE BACKGROUNDS FOR MUNICIPIO NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "municipiosNameBackground", but is set here.
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    //Execute attributes for scaling and positioning based on device screen size
    /*func setScaleAndIndepRenderingPositioningForLargeScreenSizes(){
     
        //debugPrint("Set StartScene gamePlay objts scaling and positioning for: iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro enter LargeScreenSizes scaling and positioning func")
        //debugPrint("iPhone large screen sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.811/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.33)//1.38
        
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6.5)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.8) //14.8)
        
        skipButton.setScale(1.50)
        exitRedButton.setScale(1.50)
        
        municipiosNameBackground.setScale(1.20)
    }*/
    
    func setScaleAndIndepRenderingPositioningForLargeScreenSizesTwo(){
        debugPrint("iPhone 12(18.5), iPhone 12Pro(18.5), iPhone 13(18.5), iPhone 13 Pro(18.5), iPhone 14(18.5), iPhone 14 Pro(18.5), iPhone 15(18.6), iPhone 15 Pro(18.6), iPhone 16(18.6), iPhone 16e enters scaling and positioning func")
        //debugPrint("Set StartScene gamePlay objts scaling and positioning for: iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro enter LargeScreenSizes scaling and positioning func")
        //debugPrint("iPhone large screen sizes")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.67/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.37)//1.38
        
        timerBackgroundTwo.setScale(1.40)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 5.4)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 13.3) //14.8)
        controlPanelSKSpriteNode.setScale(1.25)
        
        skipButton.setScale(1.35)
        exitRedButton.setScale(1.35)
        //ATTENTION OF ALL THE BACKGROUNDS FOR MUNICIPIO NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "municipiosNameBackground", but is set here. The others are set to 1.20
        //(continue)on the functions that change backgrounds according to the municipio name string lenght.
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForXtraLargeScreenSizes(){
        debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus enters scaling and positioning func")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.5)//1.38
        
        timerBackgroundTwo.setScale(1.5)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 5.85)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.5) //14.8)
        controlPanelSKSpriteNode.setScale(1.25)
        
        skipButton.setScale(1.35)
        exitRedButton.setScale(1.35)
        
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    func setScaleAndIndepRenderingPositioningForiPhone16Pro(){
        debugPrint("iPhone 16 PRO(18.6), iPhone 17, iPhone 17 PRO enters scaling and positioning func")
        
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.37)//1.38
        
        timerBackgroundTwo.setScale(1.40)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 5.55)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 13.5) //13.3)
        controlPanelSKSpriteNode.setScale(1.25)
        
        skipButton.setScale(1.35)
        exitRedButton.setScale(1.35)
        //ATTENTION OF ALL THE BACKGROUNDS FOR MUNICIPIO NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "municipiosNameBackground", but is set here. The others are set to 1.20
        //(continue)on the functions that change backgrounds according to the municipio name string lenght.
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    func setScaleAndIndepRenderingPositioningForiPhone16ProMax(){
        debugPrint("iPhone 16 PROMAX, iPhone 17 ProMax  enters scaling and positioning func")
        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.765/*1.8*/)
        mapRectangleGestureMGMT.setScale(1.5)//1.38
        
        timerBackgroundTwo.setScale(1.5)
        timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 5.98)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.7) //14.8)
        controlPanelSKSpriteNode.setScale(1.25)
        
        skipButton.setScale(1.35)
        exitRedButton.setScale(1.35)
        
        municipiosNameBackground.setScale(1.35)
        municipiosNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundTwo.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundThree.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
        municipiosNameBackgroundFour.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        // Don't allow pan during tutorial
        if tutorialOverlay != nil {
            return
        }
        
        //Asses screen
        let screenSize = self.view?.bounds.size
        let screenWidth = screenSize?.width ?? 0
        let screenHeight = screenSize?.height ?? 0
        
        //Apply min and max value to limit panning based on screen size
        let minX = screenWidth * 0.02
        let maxX = screenWidth * 0.99
        let minY = screenHeight * 0.1
        let maxY = screenHeight * 1.0//0.6
        
        //Flag variable allows pan only when zoom in have taken place
        if isScaled == true{
            /*var touchLocation: CGPoint = gesture.location(in: gesture.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            let moveAction = SKAction.move(to: touchLocation, duration: 0.5)
            moveAction.timingMode = .linear//.easeInEaseOut
            containerSKSPriteNode.run(moveAction)*/
            
            //Contraints for limiting panning
            let translation = gesture.translation(in: gesture.view)
            if mapRectangleGestureMGMT.position.x > maxX {
                mapRectangleGestureMGMT.position.x = maxX
            } else if mapRectangleGestureMGMT.position.x < minX {
                mapRectangleGestureMGMT.position.x = minX
            }

            if mapRectangleGestureMGMT.position.y > maxY {
                mapRectangleGestureMGMT.position.y = maxY
            } else if mapRectangleGestureMGMT.position.y < minY {
                mapRectangleGestureMGMT.position.y = minY
            }
            //pan execution
            mapRectangleGestureMGMT.position = CGPoint(x: mapRectangleGestureMGMT.position.x + translation.x, y: mapRectangleGestureMGMT.position.y - translation.y)
            gesture.setTranslation(.zero, in: view)
            
        }
       
    }

       
    @objc func handleTapFrom(_ sender: UITapGestureRecognizer){
            
            
            if sender.state == .recognized {//execute code as soon as gesture is recognized
                
                let touchLocation = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
                let location = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
                
                // Check if tutorial is active
                   if let tutorial = tutorialOverlay {
                       tutorial.handleTouch(at: location)
                       return
                   }
                
                let touchedNode = self.physicsWorld.body(at:location)//Defines that touch will take effect when it gets in contact with an SKphysics body
                
                
                                
                if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
                    if (municipioNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                        let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                        //spritenode.physicsBody = nil LINE WAS COMMENTED DUE PHYSICS ARE NEEDED A LONG THE GAME TO CATCH THE WRONG ANSWERED NODES THAT HAVE BEEN ALREADY IDENTIFIED AS IN ANDROID GAME.
                        playCorrectSound()
                        //setLabelForMunicipioNameAndAddToNode(nodeSprite: spritenode)
                        //playCorrectSound()
                        paintNode(spriteNode: spritenode)//color SKSpriteNode green
                        /**Set labels and add them to map texture(node)*/
                        //setLabelForMunicipioNameAndAddToNode(nodeSprite: spritenode)
                        //playCorrectSound()
                        /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                        removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                        /**set new municipio to look after*/
                        setNewMunicipioNameToLookUp()
                        /**add one to number of municipios located*/
                        addToScoreCountWriteToLabel()
                        debugPrint("Inside Physics Correct")
                        debugPrint(spritenode.name!)
                        return
                        
                    }

                    
                    /*Skip button touch action**/
                    else if (skipButton.name == touchedNode?.node?.name){//Es lo mismo que preguntar si el physics body tocado se llama (name) como skipButton, la condicion quiere saber si tocamos skipButton basicamente
                        addOneTocurrentIndexSetNameToLookUp()
                        return
                    }
                    /**Exit button touch action*/
                    else if (exitRedButton.name == touchedNode?.node?.name){
                        goToStartMenu()
                        return
                    }
                   
                    //else statement will execute whenever a wrong municipio node is touched
                    else{
                        playIncorrectSound()
                        debugPrint("Inside Physics Fail")
                        debugPrint(touchedNode?.node?.name! as Any)
                        return fail = true//variable updates to apply 3 seconds penalty at timer function
                        
                    }
                }
                
                
                
                //Fall back when physics bodies fail to catch a tap for a municipality and catch touchches inside gold rectangle, outside rectangle and control panel
                else if (touchedNode == nil){
                  
                    //debugPrint("inside touchesNode == nil")
                    
                    
                    
                    
                   /* if controlPanelSKSpriteNode.contains(location) {
                            
                                return
                            }*/
           
                    //let touchLocation = sender.location(in: sender.view)
                    //let location = self.convertPoint(fromView: touchLocation)

                    //Get all nodes at the touch location
                    
                    let touchedNodes = self.nodes(at: location)
                    
                    
                    
                    //let touchedNode = self.atPoint(location) // Get the node at the touch location

                    // Check if the touched node is an SKSpriteNode and if it matches the municipio name
                    /*if let spriteNode = touchedNode as? SKSpriteNode, spriteNode.name == municipioNameLabel.text {
                        // Proceed with actions on the spriteNode
                        playCorrectSound()
                        paintNode(spriteNode: spriteNode)
                        setLabelForMunicipioNameAndAddToNode(nodeSprite: spriteNode)
                        removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                        setNewMunicipioNameToLookUp()
                        addToScoreCountWriteToLabel()
                        return
                    }*/
                    //debugPrint(touchedNodes)
                    
                    
                    /*if (touchedNodes.contains(where: { $0.name == controlPanelSKSpriteNode.name }))  {
                        return // Ignore the touch if it's on the control panel or the background
                    }*/
                    
                    /*if touchedNodes.contains(where: { $0.name == municipioNameLabel.text }) {
                        if let spriteNode = touchedNodes.first(where: { $0.name == municipioNameLabel.text }) as? SKSpriteNode {
                            //spriteNode.physicsBody = nil // Remove physics if needed
                            playCorrectSound()
                            paintNode(spriteNode: spriteNode)
                            setLabelForMunicipioNameAndAddToNode(nodeSprite: spriteNode)
                            removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                            setNewMunicipioNameToLookUp()
                            addToScoreCountWriteToLabel()
                            debugPrint("Inside Nodes Correct")
                            debugPrint("Tapped node: \(spriteNode.name ?? "Unnamed")") // Debug info
                            return
                        }
                    }*/
                    

                    if let spriteNode = touchedNodes.first(where: { $0.name == municipioNameLabel.text }) as? SKSpriteNode {
                                //spriteNode.physicsBody = nil // Remove physics if needed
                                playCorrectSound()
                                paintNode(spriteNode: spriteNode)
                                //setLabelForMunicipioNameAndAddToNode(nodeSprite: spriteNode)
                                removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                                setNewMunicipioNameToLookUp()
                                addToScoreCountWriteToLabel()
                                debugPrint("Inside Nodes Correct")
                               debugPrint("Tapped node: \(spriteNode.name ?? "Unnamed")") // Debug info
                                return
                            }
                    
                    if ((touchedNodes.first(where: { $0.name != municipioNameLabel.text }) as? SKSpriteNode) != nil) && (touchedNodes.first(where: { $0.parent == containerNode }) != nil) || ((touchedNodes.first(where: { $0.name == mapRectangleBackground.name })) != nil){
                        //debugPrint("end")
                        // Handle incorrect touch
                        playIncorrectSound()
                        debugPrint("Inside Nodes Fail")
                        debugPrint("Tapped node: \(touchedNodes.first?.name ?? "Unnamed")")
                        fail = true // Apply penalty
                        return
                    }
                    
                    /*if ((touchedNodes.first(where: { $0.name == mapRectangleGestureMGMT.name }) as? SKSpriteNode) != nil) && ((touchedNodes.first(where: { $0.parent != containerNode })  as? SKSpriteNode) != nil) && ((touchedNodes.first(where: { $0.parent != mapRectangleGestureMGMT })  as? SKSpriteNode) != nil){
                        debugPrint("test")
                        // Handle incorrect touch
                        playIncorrectSound()
                        fail = true // Apply penalty
                        return
                    }*/
                    
                   /*if touchedNodes.contains(where: { $0.name == backgroundNode.name })  {
                        debugPrint("BG2")
                       return // Ignore the touch if it's on the control panel or the background
                   }*/
                    /*if ((touchedNodes.first(where: { $0.name == mapRectangleBackground.name })) != nil) {
                        debugPrint("white background")
                        return // Exit the function after handling the tap
                    }*/
                    
                   
                    if ((touchedNodes.first(where: { $0.name == backgroundNode.name })) != nil) {
                        debugPrint("inside firt")
                        return // Exit the function after handling the tap
                    }
                    
                    if (touchedNodes.contains(where: { $0.name == controlPanelSKSpriteNode.name }))  {
                        return // Ignore the touch if it's on the control panel or the background
                    }
                    
                        
                        /*debugPrint("second end")
                        // Handle incorrect touch
                        playIncorrectSound()
                        fail = true // Apply penalty*/
                    
                }

            }
        }
       
     
   
       
       
       /*@objc func handleTapFrom(_ sender: UITapGestureRecognizer){
           
           
           if sender.state == .recognized {//execute code as soon as gesture is recognized
               
               /*var touchLocation: CGPoint = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
               touchLocation = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
               let touchedNode = self.physicsWorld.body(at:touchLocation)//Defines that touch will take effect when it gets in contact with an SKphysics body*/
               
               let touchLocation = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
               let location = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
               let touchedNode = self.physicsWorld.body(at:location)//Defines that touch will take effect when it gets in contact with an SKphysics body
               
               if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
                   if (municipioNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                       let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                       spritenode.physicsBody = nil
                       playCorrectSound()
                       paintNode(spriteNode: spritenode)//color SKSpriteNode green
                       
                       /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                       removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                       /**set new municipio to look after*/
                       setNewMunicipioNameToLookUp()
                       /**add one to number of municipios located*/
                       addToScoreCountWriteToLabel()
                       
                   }
                   
                   /*Skip button touch action**/
                   else if (skipButton.name == touchedNode?.node?.name){//Es lo mismo que preguntar si el physics body tocado se llama (name) como skipButton, la condicion quiere saber si tocamos skipButton basicamente
                       addOneTocurrentIndexSetNameToLookUp()
                   }
                   /**Exit button touch action*/
                   else if (exitRedButton.name == touchedNode?.node?.name){
                       goToStartMenu()
                   }
                  
                   //else statement will execute whenever a wrong municipio node is touched
                   else{
                       playIncorrectSound()
                       
                       return fail = true//variable updates to apply 3 seconds penalty at timer function
                   }
               }
           }
       }*/
       
      
       
      
    
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        
        // Don't allow pinch during tutorial
           if tutorialOverlay != nil {
               return
           }
        
        //The following block limits the scaling(Zoom effect) from 2.4(default size) and no larger than 3.0 for devices Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5)
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            //debugPrint("iPad Pro12.9 entering handlePinch func")
            if mapRectangleGestureMGMT.xScale * sender.scale < 2.4 {
                sender.scale = 2.4 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }
        
            if mapRectangleGestureMGMT.yScale * sender.scale < 2.4 {
                sender.scale = 2.4 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3) scaling is limited")
        }
        //The following block limits the scaling(Zoom effect) from 1.85(default size) and no larger than 3.0 for device iPad Pro 10.5, Pro11(1gen), Air(3gen), 7Gen, Pro11(2gen), 8Gen, 9Gen, Air(4gen), PRO11(3gen), Air(5gen), 10Gen, Pro11(4gen), iPad 6Gen, Mini(5gen), Mini(6gen)
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0  || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 ||  screenSize.width == 1668.0 && screenSize.height == 2420.0{
            //debugPrint("iPad Pro 10.5, Pro11(1gen), Air(3gen), 7Gen, Pro11(2gen), 8Gen, 9Gen, Air(4gen), PRO11(3gen), Air(5gen), 10Gen, Pro11(4gen), iPad 6Gen, Mini(5gen), Mini(6gen) entering handlePinch func")
            if mapRectangleGestureMGMT.xScale * sender.scale < 2.1 {
                sender.scale = 2.1 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 2.1 {
                sender.scale = 2.1 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5 scaling is limited")
        }
        
        else if screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            //debugPrint("iPad Pro 10.5, Pro11(1gen), Air(3gen), 7Gen, Pro11(2gen), 8Gen, 9Gen, Air(4gen), PRO11(3gen), Air(5gen), 10Gen, Pro11(4gen), iPad 6Gen, Mini(5gen), Mini(6gen) entering handlePinch func")
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.85 {
                sender.scale = 1.85 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.85 {
                sender.scale = 1.85 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6) scaling is limited")
        }
        
        else if screenSize.width == 1242.0 && screenSize.height == 2288.0 || screenSize.width == 828.0 && screenSize.height == 1792.0 || screenSize.width == 1242.0 && screenSize.height == 2688.0{
            
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.45 {
                sender.scale = 1.45 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.45 {
               sender.scale = 1.45 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPhone Xr(18.6), 11(18.6), Xs Max(18.6), 11 Pro Max(18.6) scaling is limited")
        }
        
        else if screenSize.width == 1170.0 && screenSize.height == 2532.0 || screenSize.width == 1179.0 && screenSize.height == 2556.0{
            
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.37 {
                sender.scale = 1.37 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.37 {
               sender.scale = 1.37 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPhone 12, iPhone 12Pro, iPhone 13, iPhone 13 Pro, iPhone 14, iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16, iPhone 16e scaling is limited")
        }
        
        else if screenSize.width == 1284.0 && screenSize.height == 2778.0 || screenSize.width == 1290.0 && screenSize.height == 2796.0{
            
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.5 {
                sender.scale = 1.5 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.5 {
               sender.scale = 1.5 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus scaling is limited")
        }
        
        else if screenSize.width == 1206.0 && screenSize.height == 2622.0 /*|| screenSize.width == 1179.0 && screenSize.height == 2556.0*/{
            
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.37 {
                sender.scale = 1.37 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.37 {
               sender.scale = 1.37 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPhone 16 PRO, iPhone 17, iPhone 17 PRO scaling is limited")
        }
        
        else if screenSize.width == 1320.0 && screenSize.height == 2868.0 {
            
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.5 {
                sender.scale = 1.5 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < 1.5 {
               sender.scale = 1.5 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
            sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("iPhone 16 ProMAX, iPhone 17 ProMAX scaling is limited")
        }
        
        //The following block limits the scaling(Zoom effect) from 1.33(default size) and no larger than 3.0 for device
        else{
            //debugPrint("iPhone entering handlePinch func")
            if mapRectangleGestureMGMT.xScale * sender.scale < 1.33 {
                sender.scale = 1.33 / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.xScale
            }
            
            if mapRectangleGestureMGMT.yScale * sender.scale < 1.33 {
                sender.scale = 1.33 / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > 3.0 {
                sender.scale = 3.0 / mapRectangleGestureMGMT.yScale
            }
            debugPrint("Default settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) scaling is limited")
        }
        
        //Set scaling action
        let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
        mapRectangleGestureMGMT.run(pinch)
        sender.scale = 1.00
        
        //Asses if the node is scaled or not(scaled to default size)
        if sender.state == .ended{
                //Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5)
            if screenSize.width == 2048.0 && screenSize.height == 2732.0{
                if mapRectangleGestureMGMT.xScale > 2.4 && mapRectangleGestureMGMT.yScale > 2.4 {
                    isScaled = true
                    debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3)  is scaled")
                }
            }
            
            else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1668.0 && screenSize.height == 2420.0 {
                if mapRectangleGestureMGMT.xScale > 2.1 && mapRectangleGestureMGMT.yScale > 2.1{
                    isScaled = true
                    debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5 is scaled")
                }
            }
            
            else if screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0  {
                if mapRectangleGestureMGMT.xScale > 1.85 && mapRectangleGestureMGMT.yScale > 1.85{
                    isScaled = true
                    debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6) is scaled")
                }
            }
            
            else if screenSize.width == 1242.0 && screenSize.height == 2288.0 || screenSize.width == 828.0 && screenSize.height == 1792.0 || screenSize.width == 1242.0 && screenSize.height == 2688.0{
                if mapRectangleGestureMGMT.xScale > 1.45 && mapRectangleGestureMGMT.yScale > 1.45{
                    isScaled = true
                    debugPrint("iPhone Xr(18.6), 11(18.6), Xs Max(18.6), 11 Pro Max(18.6) is Scaled")
                }
            }
            
            else if screenSize.width == 1170.0 && screenSize.height == 2532.0 || screenSize.width == 1179.0 && screenSize.height == 2556.0 {
                if mapRectangleGestureMGMT.xScale > 1.37 && mapRectangleGestureMGMT.yScale > 1.37{
                    isScaled = true
                    debugPrint("iPhone 12, iPhone 12Pro, iPhone 13, iPhone 13 Pro, iPhone 14, iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16, iPhone 16e is Scaled")
                }
            }
            
            else if screenSize.width == 1284.0 && screenSize.height == 2778.0 || screenSize.width == 1290.0 && screenSize.height == 2796.0 {
                if mapRectangleGestureMGMT.xScale > 1.5 && mapRectangleGestureMGMT.yScale > 1.5{
                    isScaled = true
                    debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus is Scaled")
                }
            }
            
            else if screenSize.width == 1206.0 && screenSize.height == 2622.0 /*|| screenSize.width == 1179.0 && screenSize.height == 2556.0*/ {
                if mapRectangleGestureMGMT.xScale > 1.37 && mapRectangleGestureMGMT.yScale > 1.37{
                    isScaled = true
                    debugPrint("iPhone 16 PRO, iPhone 17, iPhone 17 PRO is Scaled")
                }
            }
            
            else if screenSize.width == 1320.0 && screenSize.height == 2868.0 {
                if mapRectangleGestureMGMT.xScale > 1.5 && mapRectangleGestureMGMT.yScale > 1.5{
                    isScaled = true
                    debugPrint("iPhone 16 ProMax, iPhone 17 ProMax is Scaled")
                }
            }
            
            
            else{
                if mapRectangleGestureMGMT.xScale > 1.33 && mapRectangleGestureMGMT.yScale > 1.33 {
                    isScaled = true
                    debugPrint("Default settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) is scaled")
                }
            }
            
            
            let tolerance: CGFloat = 0.001
            
            //debugPrint("Last Screen size: \(screenSize)")
            switch (screenSize.width, screenSize.height) {
             // checking if the absolute difference between the current scaling factor and the target scaling factor is smaller than the tolerance value. If it is, it means that the scaling factor is very close to the target value, indicating that the node has been scaled back to the normal size
                case (2048.0, 2732.0):
                     //debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5)")
                     if abs(mapRectangleGestureMGMT.xScale - 2.4) < tolerance && abs(mapRectangleGestureMGMT.yScale - 2.4) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                        debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3) is back to original position")
                    }
               
              
            case (1668.0, 2224.0), (1668.0,2388.0), (1620.0, 2160.0), (1640.0, 2360.0), (1668.0, 2420.0):
                    //debugPrint("iPad Pro 10.5, Pro11(1gen), Air(3gen), 7Gen, Pro11(2gen), 8Gen, 9Gen, Air(4gen), PRO11(3gen), Air(5gen), 10Gen, Pro11(4gen), iPad 6Gen, Mini(5gen), Mini(6gen)")
                if abs(mapRectangleGestureMGMT.xScale - 2.1) < tolerance && abs(mapRectangleGestureMGMT.yScale - 2.1) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5 is back to original position")
                    }
                
            case (1536.0, 2048.0), (1488.0, 2266.0):
                if abs(mapRectangleGestureMGMT.xScale - 1.85) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.85) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6) back to original position")
                }
                    
                /*case (750.0, 1334), (1080, 2340 ),(1125, 2436 ) :
                    //debugPrint("iPhoneSE3, SE2, 8, mini12, mini13, iPhone X, XS ,11PRO")
                    if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                        debugPrint("Default Settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) back to original position")
                    }*/
                
            case (1242.0, 2208.0), (828.0, 1792.0 ),(1242.0, 2688.0 ) :
                //debugPrint("iPhone 8plus, XR, 11, XSMax, 11ProMax")
                if abs(mapRectangleGestureMGMT.xScale - 1.45) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.45) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.716/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone Xr, 11, Xs Max, 11 Pro Max is back to original position")
                }
                    
                
                
            case (1170.0, 2532.0), (1179.0, 2556.0):
                 //debugPrint("iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro")
                 if abs(mapRectangleGestureMGMT.xScale - 1.37) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.37) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.67/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 12, iPhone 12Pro, iPhone 13, iPhone 13 Pro, iPhone 14, iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16, iPhone 16e is back to original position")
                }
                    
                
                
            case (1284.0, 2778.0), (1290.0, 2796.0):
                 //debugPrint("iPhone 12ProMax, 13ProMax, 14plus, 13Pro, 14ProMax")
                 if abs(mapRectangleGestureMGMT.xScale - 1.5) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.5) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus is back to original position")
                }
                
            case (1206.0, 2622.0):
                 //debugPrint("iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro")
                 if abs(mapRectangleGestureMGMT.xScale - 1.37) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.37) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 16 PRO, iPhone 17, iPhone 17 PRO is back to original position")
                }
                
            case (1320.0, 2868.0):
                 //debugPrint("iPhone 12ProMax, 13ProMax, 14plus, 13Pro, 14ProMax")
                 if abs(mapRectangleGestureMGMT.xScale - 1.5) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.5) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.765/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 16 ProMax, iPhone 17 ProMax is back to original position")
                }
                    
                    
                default:
                    if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                        debugPrint("Default Settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) back to original position")
                    }
                    break
                
            }
            
            
            /*if screenSize.width == 750 && screenSize.height == 1334 || screenSize.width == 1080 && screenSize.height == 2340 || screenSize.width == 1125 && screenSize.height == 2436{
                if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                isScaled = false
                mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                debugPrint("scaled back to normal")
                }
            }
            
            else if screenSize.width == 1242 && screenSize.height == 2208 || screenSize.width == 828 && screenSize.height == 1792 || screenSize.width == 1242 && screenSize.height == 2688{
                if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.906/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("scaled back to normal")
                }
            }
            else if screenSize.width == 1170 && screenSize.height == 2532 || screenSize.width == 1179 && screenSize.height == 2556{
                if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.811/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("scaled back to normal")
                }
            }
            else if screenSize.width == 1284 && screenSize.height == 2778 || screenSize.width == 1290 && screenSize.height == 2796{
                if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.96/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("scaled back to normal")
                }
            }
            else{
                if abs(mapRectangleGestureMGMT.xScale - 1.33) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.33) < tolerance {
                isScaled = false
                mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                debugPrint("scaled back to normal")
                }
            }*/
        }
    }
    
  
    
    func addChildSKSpriteNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKSpriteNode){
        if children.parent == nil{
        parent.addChild(children)
        }
    }
    
    func addChildSKLabelNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKLabelNode){
        if children.parent == nil{
        parent.addChild(children)
        }
    }
    
    func addChildSKSpriteNodeToParentself(children:SKSpriteNode){
        if children.parent == nil{
        self.addChild(children)
        }
    }
    
    func addChildSKLabelNodeToParentself(children:SKLabelNode){
        if children.parent == nil{
        self.addChild(children)
        }
    }
    
    func addChildSKNodeToParentself(children:SKNode){
        if children.parent == nil{
        self.addChild(children)
        }
    }
    func addChildSKNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKNode){
        if children.parent == nil{
        parent.addChild(children)
        }
    }
    
    /*func initMusic() {
        guard let url = musicURL else { return }
        
        do{
            musicPlayer = try AVAudioPlayer(contentsOf: url)/*exe what is inside url**/
        }catch{
            debugPrint("error")
            }
        
        musicPlayer.numberOfLoops = -1/*negative numbers will make it loop continuously until stopped*/
        musicPlayer.prepareToPlay()//ready to play musicPlayer
        musicPlayer.play()//
    }*/
    //Claude suggested
    func initMusic() {
        guard let url = musicURL else { return }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            debugPrint("Error initializing audio: \(error)")
        }
    }
    
    func showTutorial() {
        isTutorialActive = true
        tutorialOverlay = TutorialOverlay(scene: self, isPracticeMode: true)  // Practice mode = true
        
        tutorialOverlay?.onComplete = { [weak self] in
            debugPrint("Tutorial completed")
            self?.isTutorialActive = false
            self?.tutorialOverlay = nil
        }
        
        tutorialOverlay?.onSkip = { [weak self] in
            debugPrint("Tutorial skipped")
            self?.isTutorialActive = false
            self?.tutorialOverlay = nil
        }
        
        tutorialOverlay?.show()
    }
        
    override public func update(_ currentTime: TimeInterval) {/*Function execute every second, for timer functionality*/
        
        // Don't run timer during tutorial
        /*if isTutorialActive {
            return
        }*/
        //Onboarding Tutorial and Ads Logic
        if isTutorialActive || isAdShowing {
            return
        }
        
       if PracticeAlphabeticGameScene.completedGame == false{//Control variable to keep the timer running, once condition is true the timer is stopped
            /* currentTime refers to the pc running clock and renderTime refers to the passing time while the game is running*/
            if currentTime > renderTime {/**currentTime  value is bigger than renderTime only when a second is added, later on renderTime value updates to a future time measure bigger than currentTime, due currenTime is continuously running when it becomes bigger than renderTime value, the execution enters the next block to sum seconds and minutes*/
            
                /**following block is where seconds and minuteds are added*/
                if renderTime > 0{/**In its first iteration renderTime value  is 0.0, so that the execution will go  to the next Else If statement, after the first iteration its value will always be bigger than 0*/
                    timerManagement()
                }
                /**Next block will execute only when renderTime value is 0 and it just formats and render 00(timer) at the beginning of the game, it will only execute once as renderTime value keep increasing*/
                else if renderTime == 0.0{
                    formatCastZeroToStringAndWriteToLabel()
                   
                    //For dev use ONLY
                     /**ATTENTION DUE THIS BLOCK EXECUTE ONCE(SECOND 00). I  PLACE HERE THE RESET FOR PERSISTENT MEMORY WHERE I STORE THE VALUES TO EVALUATE  TIME RECORDS ON GAMEOVERSCENE
                     IN ORDER TO WIPE(reset) PERSISTEN MEMORY UNCOMMENT THE FOLLOWING STATEMENTS RUN THE GAME A FEW SECONDS STOP THE GAME, AND WHEN YOU LAUNCH THE GAME NEXT TIME  PERSISTENT MEMORY WILL BE
                     CLEAN AS WHEN THE GAME IS PLAYED FOR THE FIRST TIME WHEN DOWNLOADED*/
                    //UserDefaults.standard.removeObject(forKey: "secondsAlphabetic")
                    //UserDefaults.standard.removeObject(forKey: "minutesAlphabetic")
                }
                
                renderTime = currentTime + changeTime//updates renderTime value, when this happens renderTime value is bigger than currentTime
            }
            
        }
        /** This block  will execute when completedGame equals true(meaning all nodes were correctly identified), the function below will get gameOverScene. The reason to place here the game transition to gameOverScene is due Touch function needs "space" in order to perform without much lagging as scene transitioning and
         Touch function both require a lot of resouces that can compromise the flow of the game(so basically thats why the scene transition is not placed on Touch function)*/
        
        if PracticeAlphabeticGameScene.completedGame == true{
            goToGameOverScene()
        }
        
    }
        
    func timerManagement(){
        addSecond()
        //seconds += 1
        if seconds == 60 {
            resetSecondsAddMinutes()

        }
        
        //Este bloque solo se ejecuta cuando se presiona sobre el municipio incorrecto, anadiendo 3 segundos al reloj
        if(fail == true){
            
            addPenaltyToSeconds()
            
            //El if statement abajo substituye(0 resume) los proximos if statements comentados,si los segundos al sumarle el penalty sobrepasan 59, dentro del if se convierte a la cantidad de segundos correspondientes osea 60 a 0, 61 a 1 etc....
            if seconds >= 60{
                resetSecondsAfterPenaltyAddMinutes()
            }
            fail = false
            
        }
        
        if (pressSKipButton == true){
            addSkipButtonPenaltyToSeconds()
            
            
            //El if statement abajo substituye(0 resume) los proximos if statements comentados,si los segundos al sumarle el penalty sobrepasan 59, dentro del if se convierte a la cantidad de segundos correspondientes osea 60 a 0, 61 a 1 etc....
            if seconds >= 60{
                resetSecondsAfterPenaltyAddMinutes()
            }
            pressSKipButton = false
        }
        
        formatCastToStringAndWriteSecondsAndMinutesToLabel()

    }

    func addSecond(){
        seconds += 1
    }

    func resetSecondsAddMinutes(){
        seconds = 0
        minutes += 1
    }

    func addPenaltyToSeconds(){
        //let penalty = 3
        //debugPrint("inside")
        seconds = seconds + penalty
    }

    func resetSecondsAfterPenaltyAddMinutes(){
        seconds = seconds - 60//Subastracting 60 from seconds gets the number of seconds while seconds are reinitiated
        minutes += 1//adding minutes once seconds count reach 59
    }

    func addSkipButtonPenaltyToSeconds(){
        //debugPrint("15 more seconds")
        seconds = seconds + skipButtonPenalty
    }

    func formatCastToStringAndWriteSecondsAndMinutesToLabel(){
        let secondsText = (seconds < 10) ? "0\(seconds)" : "\(seconds)"
        let minutesText = "\(minutes)"
        //"0\(minutes)" : "\(minutes)"//this line of code is to show a 0(01,02,03...minutes) on the minutes counter
        if minutes >= 1 {
              labelTimer.text = "\(minutesText):\(secondsText)"
              
          }
        
          else{
              labelTimer.text = "\(secondsText)"
              
          }
    }
    //Function will only execute during second 00
    func formatCastZeroToStringAndWriteToLabel(){
        let secondsText = (seconds < 10) ?
        "0\(seconds)" : "\(seconds)"
        labelTimer.text = "\(secondsText)"
        //timerBackground.size = labelTimer.frame.size//size para el background del timer para acomodar 00
        //debugPrint("rendertime = 0")//Esta linea es solo para indicar al programador cuando se ejecuta este bloque
    }

    func goToGameOverScene(){
        musicPlayer?.stop()
        AdManager.shared.removeBanner()
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.5)
        self.view?.presentScene(gameOverScene, transition: transition)
    }

    
    //Function gets seconds and minutes to be evaluated at gameOverScene
    func getSecondsAndMinutes(){
        PracticeAlphabeticGameScene.secondsGameOver = seconds
        PracticeAlphabeticGameScene.minutesGameOver = minutes
    }
    
    //function manage touch on screen
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {//Touch function
         
        let touch = touches.first!//store touch
        let touchLocation = touch.location(in: self)//Defines the space where touch is taking effect, in this case StartScene
        let touchedNode = self.physicsWorld.body(at:touchLocation)//Defines that touch will take effect when it gets in contact with an SKphysics body
        
        
        if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
            if (municipioNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                paintNode(spriteNode: spritenode)//color SKSpriteNode green
                playCorrectSound()
                
                /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                /**set new municipio to look after*/
                setNewMunicipioNameToLookUp()
                /**add one to number of municipios located*/
                addToScoreCountWriteToLabel()
                
            }
            
            /*Skip button touch action**/
            else if (skipButton.name == touchedNode?.node?.name){//Es lo mismo que preguntar si el physics body tocado se llama (name) como skipButton, la condicion quiere saber si tocamos skipButton basicamente
                addOneTocurrentIndexSetNameToLookUp()
            }
            /**Exit button touch action*/
            else if (exitRedButton.name == touchedNode?.node?.name){
                goToStartMenu()
            }
           
            //else statement will execute whenever a wrong municipio node is touched
            else{
                playIncorrectSound()
                
                return fail = true//variable updates to apply 3 seconds penalty at timer function
            }
        }
    }*/
    
    func paintNode(spriteNode:SKSpriteNode){
        spriteNode.colorBlendFactor = 0.8
        spriteNode.color = UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)
        
        //spriteNode.physicsBody = nil
    }
    
    func playCorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(correctSound)//correctSound
        }
    }
    
    func removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval(){
        let countOfIndexes = municipios_names_array.count - 1//Gets the number of indexes in array

        /**cuurentIndex and countOfIndexes will be different as long as the end of the array have not been reached. they become equal under two scenarios when the end of array is reached but still some skipped nodes remain to be identified
         or reaching the end of array by  identifying all nodes*/
        if currentIndex != countOfIndexes{
            municipios_names_array.remove(at:currentIndex)//remove element at the index from array
        }
            
        /**This condition equals true when currentIndex and countOfIndexes are equals but both equal or bigger than 1. This scenario will play out when skipButtom is pressed , this moves the index forward from default index position 0. When index have moved foward  and the end of array have been reached(at this point currentIndex and countOfIndexes are equals but both equal or bigger than 1 (Note:actually both value are equals to the number of skipped elements)) , then currentIndex must be moved back to 0 in order to be able to evaluate and look up the remaining skipped elements.  */
        else if currentIndex == countOfIndexes && currentIndex >= 1 && countOfIndexes >= 1{
            municipios_names_array.remove(at:currentIndex)//remove element at the index from array
            currentIndex = 0/*resets currentIndex once end of array been reached to go back to index 0 and go over the remaining skipped municipios*/
        }
            
        /**following statement will execute when currentIndex and countOfIndexes equals 0 meaning that last element have been identified and prepare the game to move to gameOverScene*/
        
        //CLAUDE ELSE STATEMENT TO OPTIMIZE GAME TO GAMEOVERSCENE TRANSITION
        else{
            getSecondsAndMinutes()//gets seconds and minutes to be used for time record function at gameOverScene
            // Use an action to delay setting completedGame, allowing the correct sound to play
            let waitAction = SKAction.wait(forDuration: 0.00001)
            let completeAction = SKAction.run {
                PracticeAlphabeticGameScene.completedGame = true
            }
            self.run(SKAction.sequence([waitAction, completeAction]))
        }
        
        //ORIGINAL ELSE BLOCK
        /*else{
            //musicPlayer.stop()
            //self.removeAllActions()//It catches the last correctSound in order for transition to gameOverScene to flow smoother with less laggin
            getSecondsAndMinutes()//gets seconds and minutes to be used for time record function at gameOverScene
            PracticeAlphabeticGameScene.completedGame = true//variable updates to stop the timer and execute the transition to gameOverScene (gameOverScene TRANSITION EXECUTES AT UPDATE FUNCTION)
        }*/
        /**the following condition is true when var countOfIndexes == 1(meaning there are two elements left 0 and 1) and currentIndex value is 0 or first index of array, where is the second to last element(penultimo elemento), that at this point have been already removed in the block above. But due countOfIndexes updates in the following iteration, to the effect of the present iteration there are two elements left and this allows for this condition to evaluate to true in order to toguether with the removing second to last element(in the previous block) its also removed the skipButton on this block. WHAT IS IMPORTANT TO ACKNOWLEDGE IS THAT THE REMOTION OF SECOND TO LAST(PENULTIMO) ELEMENT AND SKIPBUTTON HAPPENS IN THE SAME ITERATION*/
        if  countOfIndexes == 1 && currentIndex == 0 && municipios_names_array.endIndex-1 == 0 {
         //debugPrint("skip button out")
         skipButton.removeFromParent()
        }
        
    }

    
    
    /**following function pass text attributes for the next municipio name to look up and adjust the background size for the label(municipioNameLabel) */
    func setNewMunicipioNameToLookUp(){
        municipioNameLabel.text = municipios_names_array [currentIndex] //Writes to label the next municipio name to be located by player
       //Switch reveals the name of the next municipio to look out for
        switch(municipioNameLabel.text){
            //This block manage the longest two word names
            case "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande" ://This municipio names will use municipiosNameBackgroundTwo
                //Removes current background to add municipiosNameBackgroundTwo to the scene if its not already present on the scene
                if municipiosNameBackgroundTwo.parent == nil{// Checks if municipiosNameBackgroundTwo is already in the scene, if municipioNameBackgroundTwo is already on the scene the following block is ignored
                    switch(municipioNameLabel.parent?.name){//returns the background currently in use that is not municipiosNameBackgroundTwo and that needs to be removed in order to add municipiosNameBackgroundTwo to fit "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande"
                        
                        case "MunicipiosNameBackground"://Background to be removed in order for municipiosNameBackgroundTwo to be added
                            municipioNameLabel.removeFromParent()//municipioNameLabel is removed in order to be added(as child) to municipiosNameBackgroundTwo
                            municipiosNameBackground.removeFromParent()//If municipiosNameBackground.parent != nil true municipiosNameBackgroundis removed to put in its place municipiosNameBackgroundTwo
                            scaleMunicipioNameBackgroundTwoForScreenSizes()//scaling for municipiosNameBackgroundTwo is set according to screen size
                        
                        case "MunicipiosNameBackgroundThree":
                            municipioNameLabel.removeFromParent()
                            municipiosNameBackgroundThree.removeFromParent()
                            scaleMunicipioNameBackgroundTwoForScreenSizes()
                            
                        case "MunicipiosNameBackgroundFour":
                            municipioNameLabel.removeFromParent()
                            municipiosNameBackgroundFour.removeFromParent()
                            scaleMunicipioNameBackgroundTwoForScreenSizes()
                            
                            
                        default:
                           
                        break
                        
                    }
                    addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: municipioNameLabel)
                    addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
                }
        
            //Block manages short two words municipio names and longer one word names(CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
        case "Barceloneta", "Canóvanas", "Juana Díaz", "Las Marías", "Las Piedras", "Rio Grande", "San Germán", "San Lorenzo", "Santa Isabel", "Barranquitas", "Quebradillas"://This municipio names will use municipiosNameBackgroundFour
            if municipiosNameBackgroundFour.parent == nil{
                switch(municipioNameLabel.parent?.name){
                    case "MunicipiosNameBackground":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackground.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    case "MunicipiosNameBackgroundTwo":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    case "MunicipiosNameBackgroundThree":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundThree.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    default:
                    break
            }
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundFour, children: municipioNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundFour)
        }
            //Block manages long single words and short two words municipio names(CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
        case  "Cabo Rojo", "Bayamón", "Guayanilla", "Guaynabo", "Guayama", "Humacao", "Mayagüez", "Maunabo", "Naguabo", "Peñuelas", "San Juan", "Vega Alta", "Vega Baja", "Naranjito", "Orocovis", "Trujillo Alto"://This municipio names will use municipiosNameBackgroundThree
            if municipiosNameBackgroundThree.parent == nil{
                switch(municipioNameLabel.parent?.name){
                    case "MunicipiosNameBackground":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackground.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    case "MunicipiosNameBackgroundTwo":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    case "MunicipiosNameBackgroundFour":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundFour.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    default:
                        break
                }
                
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundThree, children: municipioNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundThree)
            }
            
            //Following block receive most municipio names(shorter ones)This municipio names will use municipiosNameBackground (CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
          default:
            if municipiosNameBackground.parent == nil{
                switch(municipioNameLabel.parent?.name){
                    case "MunicipiosNameBackgroundTwo":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                    
                    case "MunicipiosNameBackgroundThree":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundThree.removeFromParent()
                    
                    case "MunicipiosNameBackgroundFour":
                        municipioNameLabel.removeFromParent()
                        municipiosNameBackgroundFour.removeFromParent()
                    
                    default:
                   
                    break
                    
                }
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: municipioNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            }
           
            break
        }
        
      
    }
    
    /*func setNewMunicipioNameToLookUp(){
        municipioNameLabel.text = municipios_names_array [currentIndex] //Se desplega el nuevo municipio a ser localizado por el jugador
        if municipioNameLabel.text == "Aguas Buenas" || municipioNameLabel.text == "Barceloneta" || municipioNameLabel.text == "Barranquitas" || municipioNameLabel.text == "Cabo Rojo"
        || municipioNameLabel.text == "Canóvanas" || municipioNameLabel.text == "Guayanilla" || municipioNameLabel.text == "Guaynabo" || municipioNameLabel.text == "Hormigueros"
        || municipioNameLabel.text == "Juana Díaz" || municipioNameLabel.text == "Las Marías" || municipioNameLabel.text == "Las Piedras" || municipioNameLabel.text == "Mayagüez"
        || municipioNameLabel.text == "Quebradillas" || municipioNameLabel.text == "Rio Grande" || municipioNameLabel.text == "Sabana Grande" || municipioNameLabel.text == "San Germán"
        || municipioNameLabel.text == "San Lorenzo" || municipioNameLabel.text == "San Sebastián" || municipioNameLabel.text == "Santa Isabel" || municipioNameLabel.text == "Trujillo Alto"{
            if municipiosNameBackgroundTwo.parent == nil{
                municipioNameLabel.removeFromParent()
                municipiosNameBackground.removeFromParent()
                
                if screenSize.width == 2048.0 && screenSize.height == 2732.0{
                    municipiosNameBackgroundTwo.setScale(1.9)
                }
                
                else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
                    municipiosNameBackgroundTwo.setScale(1.75)
                }
                else{
                    municipiosNameBackgroundTwo.setScale(1.20)
                }
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: municipioNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
            }
            //if else municipiosNameBackgroundTwo.parent
        }
        else {
            if municipiosNameBackground.parent == nil{
            municipioNameLabel.removeFromParent()
            municipiosNameBackgroundTwo.removeFromParent()
            addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: municipioNameLabel)
            addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            }
        }
    }*/
    
    /**following function pass text attributes for the next municipio name to look up and adjust the background size for the label(municipioNameLabel) */
    /*func setNewMunicipioNameToLookUp(){
        municipioNameLabel.text = municipios_names_array [currentIndex] //Se desplega el nuevo municipio a ser localizado por el jugador
        if municipioNameLabel.text == "Aguas Buenas" || municipioNameLabel.text == "Barceloneta" || municipioNameLabel.text == "Barranquitas" || municipioNameLabel.text == "Cabo Rojo"
        || municipioNameLabel.text == "Canóvanas" || municipioNameLabel.text == "Guayanilla" || municipioNameLabel.text == "Guaynabo" || municipioNameLabel.text == "Hormigueros"
        || municipioNameLabel.text == "Juana Díaz" || municipioNameLabel.text == "Las Marías" || municipioNameLabel.text == "Las Piedras" || municipioNameLabel.text == "Mayagüez"
        || municipioNameLabel.text == "Quebradillas" || municipioNameLabel.text == "Rio Grande" || municipioNameLabel.text == "Sabana Grande" || municipioNameLabel.text == "San Germán"
        || municipioNameLabel.text == "San Lorenzo" || municipioNameLabel.text == "San Sebastián" || municipioNameLabel.text == "Santa Isabel" || municipioNameLabel.text == "Trujillo Alto"{
            if municipiosNameBackgroundTwo.parent == nil{
            municipioNameLabel.removeFromParent()
            municipiosNameBackground.removeFromParent()
            addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: municipioNameLabel)
            addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
            }
            //if else municipiosNameBackgroundTwo.parent
        }
        else {
            if municipiosNameBackground.parent == nil{
            municipioNameLabel.removeFromParent()
            municipiosNameBackgroundTwo.removeFromParent()
            addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: municipioNameLabel)
            addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            }
        }
    }*/
    
    func scaleMunicipioNameBackgroundTwoForScreenSizes(){
        
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            municipiosNameBackgroundTwo.setScale(1.3)
        }
        
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            municipiosNameBackgroundTwo.setScale(1.4)
        }
        else{
            municipiosNameBackgroundTwo.setScale(1.35)
        }
    }
    
    func scaleMunicipioNameBackgroundThreeForScreenSizes(){
        
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            municipiosNameBackgroundThree.setScale(1.3)
        }
        
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            municipiosNameBackgroundThree.setScale(1.4)
        }
        else{
            municipiosNameBackgroundThree.setScale(1.35)
        }
    }
    
    func scaleMunicipioNameBackgroundFourForScreenSizes(){
        
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            municipiosNameBackgroundFour.setScale(1.3)
        }
        
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            municipiosNameBackgroundFour.setScale(1.4)
        }
        else{
            municipiosNameBackgroundFour.setScale(1.35)
        }
    }
    
    //function updates the label rendering the number of municipios identified already at the bottom right of screen
    func addToScoreCountWriteToLabel(){
        scoreCount += 1
        labelScores.text = "\(scoreCount)" + totalScoreCount//totalScoreCount es un constant string solo sirve al rendering del score
    }
    
    /*funtion adds 1 to currentIndex(due skipButton been pressed). Also gives alpha effect to the button when pressed, updates variables for penalty(pressSkipButton) at Update(timer) function and updates
    skipButtonPressed to complete alpha effect at touchesEnded function and set the new municipio to look up at municipioNameLabel*/
    func addOneTocurrentIndexSetNameToLookUp(){
        currentIndex += 1
        //skipButton.alpha = 0.88
        pressSKipButton = true
        //skipButtonPressed = true
        
        if currentIndex == municipios_names_array.endIndex-0{//Si el indice llega al ultimo elemento el index se devuelve al 0 para comenzar a iterar los municipios que no fueron identificados en la pasada anterior del juego
            //debugPrint("This")//para programador
            currentIndex = 0//resetea el index al lugar 0 cuando presionando el skip button alcanzamos el ultimo indice
        }
        
        setNewMunicipioNameToLookUp()
        //debugPrint("Skip Button touched")
    }
    
    //transition to StartMenu Scene when exit button is pressed
    func goToStartMenu(){
        musicPlayer?.stop()
        AdManager.shared.removeBanner()
        let startMenuScene = StartMenuScene(size: self.size)
        self.view?.presentScene(startMenuScene)
    }
    
    func playIncorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(incorrectSound)
        }
    }

    /*func labelForMunicipioNames(NameMunicipioLabel: SKLabelNode) -> SKLabelNode {//child of labelMunicipiosNameBackground()
        NameMunicipioLabel.position = CGPoint(x:0.5 /*self.size.width/2*/, y:-6.5 /*self.size.height/2 * 0.14*/)
        NameMunicipioLabel.fontName = "Helvetica"
        NameMunicipioLabel.fontSize = 18
        NameMunicipioLabel.fontColor = UIColor.init(red: 0.898, green: 0.9765, blue: 0, alpha: 1.0)
        NameMunicipioLabel.text = "Adjuntas"
        municipiosNameBackground.size = NameMunicipioLabel.frame.size
        //NameMunicipioLabel.zPosition = 2
        return NameMunicipioLabel
    }*/
    
    /*func labelMunicipiosNameBackground() -> SKSpriteNode{
        let background = SKSpriteNode()
        background.color = UIColor.init(red: 0.8078, green: 0.6039, blue: 0, alpha: 1.0)//#ce9a00
        background.size = CGSize(width:CGFloat(75), height:CGFloat(17))
        background.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:-0.5/*goldenBackground().size.height/2 * 0.18*/)
        background.size = municipioNameLabel.frame.size
        //background.addChild(labelForMunicipioNames(NameMunicipioLabel: municipioNameLabel))
        //background.zPosition = 5
        return background
    }*/
    
    //function detects when the touch on screen have ended in order to complete alpha effect that started at addOneTocurrentIndexSetNameToLookUp()
    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Efecto para el skipButton cuando se suelta el boton
        if skipButtonPressed == true{
            skipButton.alpha = 1.0//Ojo esto se veria mejor dentro de un if sin embargo  si utilizo una condicion como if skipButton.alpha == 1.0 causa un glitch, pero puedo hacer una condicion con una variable boolean
            skipButtonPressed = false
        }
        //Exit button does not have alpha effect as it goes out of view when pressed
    }*/

}
