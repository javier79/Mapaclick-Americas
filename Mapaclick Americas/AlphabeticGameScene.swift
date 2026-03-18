//
//  AlphabeticGameScene.swift
//  mapaclick
//
//  Created by javier pizarro on 9/25/23.
//

import Foundation
import SpriteKit
//import UIKit
import AVFoundation

class AlphabeticGameScene: SKScene{
    
    let gameSceneObjects = GameSceneObjects()/*backgroundNode needs self properties for the size param, i need to call GameSceneObjects() class where initialization function for backgroundNode lives(this class hold all initialization parameters for all objects on the game scene).
                                              The initialization of backgroundNode occurs on did move, as self and its properties are not available until run time*/
    var backgroundNode: SKSpriteNode!//declared as var in order to be initialized on didMove when self is available(read comment for gameSceneObjects declaration up^
    
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
    let countryNameLabel = GameSceneObjects().labelForCountryNames()//Label rendering country name to look up, Used in more than one function
    // Dynamic country name background - resizes automatically based on text width
    let countriesNameBackground: SKSpriteNode = {
        let node = SKSpriteNode()
        node.position = CGPoint(x: 0.5, y: -0.5)
        node.name = "CountriesNameBackground"
        return node
    }()
    /*// Old hardcoded backgrounds - kept for reference
    let countriesNameBackground = GameSceneObjects().labelCountriesNameBackground()//Background for most(shorter) country names
    let countriesNameBackgroundTwo = GameSceneObjects().labelCountriesNameBackgroundTwo()//Background for longer country names
    let countriesNameBackgroundThree = GameSceneObjects().labelCountriesNameBackgroundThree()
    let countriesNameBackgroundFour = GameSceneObjects().labelCountriesNameBackgroundFour()
    */
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
    var twoLineText: String = ""//used on splitTextIntoFields, this is the text passed to splitTextIntoFields functions

    /** Array contains country names in alphabetical order, matching the node names in InitSetMapNodes.
     Used to display the country name the player must find.*/
    var countries_names_array = ["Argentina", "Belize", "Bolivia", "Brazil", "Canada", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", "Ecuador", "El Salvador", "French Guiana", "Greenland", "Guatemala", "Guyana", "Haiti", "Honduras", "Jamaica", "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru", "Puerto Rico", "Suriname", "The Bahamas", "United States", "Uruguay", "Venezuela"]
    
    //var touchedNode: SKPhysicsBody!//holds touched node, declared at the top to be accesed by accesory functions out of Touch function
    var fail: Bool!//flow control var allow when true for penalty to be added at timer funtion. Used on more than one funtion
    var currentIndex: Int = 0 //refers to index currently displayed on country name label declared at the top to be accesed by accesory functions
    var pressSKipButton:Bool = false//Flow control variables when true allows timer to add 15 penalty
    var scoreCount:Int = 0//variable represent the number of countries identified rendered in the control bar to the right
    let totalScoreCount:String = "/30"
    
    let correctSound = SKAction.playSoundFileNamed("351566__bertrof__game-sound-correct-organic-violin", waitForCompletion: false)
    let incorrectSound = SKAction.playSoundFileNamed("351565__bertrof__game-sound-incorrect-organic-violin", waitForCompletion: false)
    //static var backgroundMusic = SKAudioNode(fileNamed: "predited.mp3")
    //var musicPlayer = AVAudioPlayer()//// Creates an empty player that gets thrown away(Claude potential memory leak source)
    var musicPlayer: AVAudioPlayer?//Claude suggested
    let musicURL:URL? = Bundle.main.url(forResource:"predited", withExtension:"mp3")//reference to PR Himn
    
    var skipButtonPressed = false//flow control var allows to apply alpha animation to skipbuttom on Touches end
    //var pinchToZoom = false
    
    var isScaled = false

    // Dynamic zoom/pan properties — these replace the old hardcoded per-device scale values.
    // They are set once during didMove by the setScaleAndIndepRendering... positioning functions,
    // then referenced by handlePinchFrom (zoom clamping, isScaled detection, snap-back)
    // and handlePan (zoom-aware pan boundaries).
    var baseMapScale: CGFloat = 1.0       // The default/minimum scale the map starts at (can't zoom out past this)
    var baseMapPosition: CGPoint = .zero  // The default position the map snaps back to when zoomed out to baseMapScale
    var maxZoomScale: CGFloat = 3.0       // The maximum zoom-in limit, computed as baseMapScale * 3.0
    
    var isAdShowing: Bool = false//Ads Logic
    
    let screenSize = UIScreen.main.nativeBounds
    
    /*let minX = CGFloat(0)
    let maxX = CGFloat(670)
    let minY = CGFloat(50)
    let maxY = CGFloat(350)*/
    
         
    override func didMove(to view: SKView){
        // NotificationCenter.default.addObserver(self, selector: #selector(adWillShow), name: AdManager.adWillShowNotification, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(adDismissed), name: AdManager.adDismissedNotification, object: nil)

        backgroundNode = gameSceneObjects.createSceneBackground(scene: self)
        
        //self.name = "alphabeticgame"
        //self.backgroundColor = UIColor.init(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0) /* #42c2ff */ /* #1cb3c8 */ //UIColor.init(red: 0.5373, green: 0.8431, blue: 0.9294, alpha: 1.0)//blue background that resembles the ocean
        
        /**The following  objects are the parent for all rendering objects, class positioning attributers are applied in order for objects to render the same independent of the screen size, In the case of containerNode it's positioning is set  based on its parent
        timerBackgroundTwo. The reason for not giving containerNode class positioning was due when class attributes were applied to containerNode it would render different in devices with smaller screen size(maybe something im not aware about, or a glitch of some kind).*/
        
        //Invisible Node see comment n its declaration at the top
        //mapRectangleGestureMGMT.zPosition = 0
        mapRectangleGestureMGMT.anchorPoint = CGPoint(x:0.5, y:0.5)
        mapRectangleGestureMGMT.name = "mapRectangle"
        //mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.755/*1.8*/)
        //mapRectangleGestureMGMT.setScale(1.33)//1.38
        
        //containerNode.zPosition = -1
        containerNode.setScale(1.10) // Scaled down to give margin from rectangle edges
        containerNode.position = CGPoint(x:-237, y:-331) // Shifted 3pt more right
        containerNode.name = "containerNode"
        
        //timerBackgroundTwo.setScale(1.20)
        //timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6.4)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.zPosition = 1//Set to one in order for the map to zoom and remain behind
        controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:55)
        controlPanelSKSpriteNode.name = "controlPanelSKSpriteNode"
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 14.8) //14.8)
        
        //skipButton.setScale(1.50)
        //exitRedButton.setScale(1.50)
        
        //countriesNameBackground.setScale(1.20)
        
        //let screenSize = UIScreen.main.nativeBounds
        
       
        
        //The following block reads device screen size in points, based on screen size a function will execute to asign scaling and positioning attributes
        /*iPhone 17 devices run on IOS 26 which currently is available for xcode 26, i included devices 17, 17 PRO and 17 ProMAX according to screen size but have not been tested as this simulator are not available for the current xcode running. iPhone 17 Air is not included here as its screen size is new(1260, 2736) and have no means to test it here*/
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
            
            default:
                debugPrint("All iPhones — universal rendering via fixed scene size (375x667)")
                setScaleAndIndepRenderingPositioningForSmallScreenSizes()
        }

        // Override map positioning for the new Americas portrait map
        //positionMapForPortrait()

        // Remove texture so .size controls dimensions directly
        mapRectangleBackground.texture = nil
        mapRectangleBackground.color = UIColor.init(red: 0.2588, green: 0.7608, blue: 1.0, alpha: 1.0)
        mapRectangleBackground.colorBlendFactor = 1.0
        mapRectangleBackground.xScale = 1.0
        mapRectangleBackground.yScale = 1.0
        mapRectangleBackground.size = CGSize(width: mapRectangleGestureMGMT.size.width + 8, height: mapRectangleGestureMGMT.size.height + 14)
        mapRectangleBackground.position = CGPoint.zero
        mapRectangleBackground.name = "mapRectangleBackground"
        
        
        
        /**Following objects are related to goldBackground SKSPriteNode*/
        //addChildSKSpriteNodeToParentself(children:containerSKSPriteNode)
        self.addChild(backgroundNode)
        addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackground, children: countryNameLabel)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackground)
        resizeCountryNameBackground()
        //addChildSKLabelNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: labelScores)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: skipButton)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: exitRedButton)
        addChildSKSpriteNodeToParentself(children: controlPanelSKSpriteNode)
        addChildSKSpriteNodeToParentSKSpriteNode(parent:mapRectangleGestureMGMT, children:mapRectangleBackground)
        addChildSKNodeToParentSKSpriteNode(parent:mapRectangleGestureMGMT, children:containerNode)
        addChildSKSpriteNodeToParentself(children:mapRectangleGestureMGMT)
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
        
        
        
        /**Play background music*/
        if StartMenuScene.backgroundMusicOn == true{
            //self.addChild(StartScene.backgroundMusic)
            initMusic()
        }
        
        // FOR TESTING ONLY - REMOVE BEFORE RELEASE
                //TutorialManager.resetTutorialCount()
                //debugPrint("Tutorial count reset for testing")
        
        // if TutorialManager.shouldShowTutorial() {
        //             showTutorial()
        //         }
        // //Ads Logic
        // if !TutorialManager.shouldShowTutorial() {
        //     showAdIfNeeded()
        // }

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
    
    // func showAdIfNeeded() {
    //     let waitAction = SKAction.wait(forDuration: 0.1)
    //     let showAction = SKAction.run { [weak self] in
    //         AdManager.shared.showInterstitialForGameStart()
    //         // If no interstitial was shown, show a banner at top instead
    //         if !AdManager.shared.lastGameStartShowedAd {
    //             if let viewController = self?.view?.window?.rootViewController {
    //                 AdManager.shared.showBannerAtTop(in: viewController)
    //             }
    //         }
    //     }
    //     self.run(SKAction.sequence([waitAction, showAction]))
    // }
    
    
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
        
        countriesNameBackground.setScale(1.9)
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
        
        countriesNameBackground.setScale(1.3)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.4)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.4)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.75)
    }*/
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForSmallScreenSizes(){
        debugPrint("Default Settings and iPhoneSE(second gen 18.5), iPhoneSE(third gen 18.5), 8, iPhone 12 mini(18.5), iPhone 13 mini(18.5), iPhone X, iPhone XS(18.5) ,iPhone 11 PRO(18.5) enter scaling and positioning func")
        
        // Portrait Americas map positioning for small screens
        let mapWidth: CGFloat = 390.0
        let mapHeight: CGFloat = 580.0
        let controlPanelHeight: CGFloat = 60.0
        let topMargin: CGFloat = 50.0
        let horizontalMargin: CGFloat = 36.0
        let availableWidth = self.size.width - (horizontalMargin * 2)
        let availableHeight = self.size.height - controlPanelHeight - topMargin
        let scaleX = availableWidth / mapWidth
        let scaleY = availableHeight / mapHeight
        let mapScale = min(scaleX, scaleY)
        let centerX = self.size.width / 2
        let centerY = controlPanelHeight + (availableHeight / 2)
        mapRectangleGestureMGMT.position = CGPoint(x: centerX, y: centerY)
        mapRectangleGestureMGMT.setScale(mapScale)

        // Store the computed scale and position so handlePinchFrom and handlePan can reference them.
        // This avoids hardcoding per-device values in multiple places — the positioning function is
        // the single source of truth, and zoom/pan logic reads from these properties.
        baseMapScale = mapScale
        baseMapPosition = CGPoint(x: centerX, y: centerY)
        maxZoomScale = mapScale * 5.0  // User can zoom up to 5x the base size

        controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y: (controlPanelHeight / 2) - 1)

        // Center timer between control panel top and map rectangle bottom
        let mapBottomY = centerY - (mapScale * mapHeight / 2)
        let controlPanelTopY = controlPanelSKSpriteNode.position.y + (controlPanelSKSpriteNode.size.height / 2)
        let timerCenterY = controlPanelTopY + (mapBottomY - controlPanelTopY) / 2.0
        timerBackgroundTwo.setScale(1.20)
        timerBackgroundTwo.position = CGPoint(x: self.size.width / 2, y: timerCenterY)

        // Control panel children positioning for portrait (small screens)
        // Layout: [Exit] [Country Name] [Skip]
        exitRedButton.setScale(1.30)
        exitRedButton.position = CGPoint(x: -110, y: 0.5)

        skipButton.setScale(1.30)
        skipButton.position = CGPoint(x: 110, y: 0.5)

        countriesNameBackground.setScale(1.10)
        countriesNameBackground.position = CGPoint(x: 0, y: 0.5)

        // Move labelScores to far right at same height as timer (reparent from controlPanel to self)
        //labelScores.removeFromParent()
        labelScores.fontSize = 14
        labelScores.position = CGPoint(x: self.size.width - 60, y: timerCenterY - 7)
        labelScores.zPosition = 1
        self.addChild(labelScores)
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
        
        countriesNameBackground.setScale(1.20)
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
        //ATTENTION OF ALL THE BACKGROUNDS FOR COUNTRY NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "countriesNameBackground", but is set here.
        countriesNameBackground.setScale(1.35)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.20)
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
        //ATTENTION OF ALL THE BACKGROUNDS FOR COUNTRY NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "countriesNameBackground", but is set here. The others are set to 1.20
        //(continue)on the functions that change backgrounds according to the country name string length.
        countriesNameBackground.setScale(1.35)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.35)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        //ATTENTION OF ALL THE BACKGROUNDS FOR COUNTRY NAMES THE ONLY ONE THAT DOES NOT HAVE AN SCALING PROPERTY OUT SIDE THIS FUNCTION IS "countriesNameBackground", but is set here. The others are set to 1.20
        //(continue)on the functions that change backgrounds according to the country name string length.
        countriesNameBackground.setScale(1.35)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
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
        
        countriesNameBackground.setScale(1.35)
        countriesNameBackground.position = CGPoint(x:0.5/*goldenBackground().size.width/200*/, y:2.0/*goldenBackground().size.height/2 * 0.18*/)
    }

    /// Dynamically positions and scales the Americas map rectangle to fit within the portrait screen.
    /// Called after device-specific functions to override map positioning for the new 390x580 portrait map.
    func positionMapForPortrait() {
        // Map rectangle dimensions from BezierPathsForMapNodesAndRectangles.createRectangle()
        let mapWidth: CGFloat = 390.0
        let mapHeight: CGFloat = 580.0

        // Reserve space for control panel at bottom and margin at top
        let controlPanelHeight: CGFloat = 60.0
        let topMargin: CGFloat = 20.0
        let horizontalMargin: CGFloat = 2.0

        let availableWidth = self.size.width - (horizontalMargin * 2)
        let availableHeight = self.size.height - controlPanelHeight - topMargin

        // Scale to fit whichever dimension is tighter
        let scaleX = availableWidth / mapWidth
        let scaleY = availableHeight / mapHeight
        let mapScale = min(scaleX, scaleY)

        // Center horizontally, center vertically in space above control panel
        let centerX = self.size.width / 2
        let centerY = controlPanelHeight + (availableHeight / 2)

        mapRectangleGestureMGMT.position = CGPoint(x: centerX, y: centerY)
        mapRectangleGestureMGMT.setScale(mapScale)

        debugPrint("positionMapForPortrait: screen=\(self.size), scale=\(mapScale), center=(\(centerX), \(centerY))")
    }

    /*@objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isScaled == true {
            //let translation = gesture.translation(in: gesture.view)
            
            // Limit the position of the node to within the desired bounds
            if containerSKSPriteNode.position.x > maxX {
                containerSKSPriteNode.position.x = maxX
            } else if containerSKSPriteNode.position.x < minX {
                containerSKSPriteNode.position.x = minX
            }
            if containerSKSPriteNode.position.y > maxY {
                containerSKSPriteNode.position.y = maxY
            } else if containerSKSPriteNode.position.y < minY {
                containerSKSPriteNode.position.y = minY
            }
            
            let velocity = gesture.velocity(in: gesture.view)
            filteredVelocity = CGPoint(x: filteredVelocity.x * 0.9 + velocity.x * 0.01,
                                       y: filteredVelocity.y * 0.9 + velocity.y * 0.01)

            containerSKSPriteNode.position = CGPoint(x: containerSKSPriteNode.position.x + filteredVelocity.x, y: containerSKSPriteNode.position.y - filteredVelocity.y)
            gesture.setTranslation(.zero, in: view)
        }
    }*/

    
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        // Don't allow pan during tutorial
            if tutorialOverlay != nil {
                return
            }
        
        //Asses screen
        let screenSize = self.view?.bounds.size
        let screenWidth = screenSize?.width ?? 0
        let screenHeight = screenSize?.height ?? 0
        
        // Pan boundaries are zoom-aware: they expand proportionally as the user zooms in,
        // allowing more panning range at higher zoom levels. At base zoom (zoomRatio=1.0)
        // boundaries stay tight around center. At max zoom (zoomRatio=3.0) boundaries
        // expand significantly so the user can reach edges like Greenland (top-right).
        // minY and maxY use the same multiplier (0.4) for symmetric up/down panning.
        let zoomRatio = mapRectangleGestureMGMT.xScale / baseMapScale
        let minX = screenWidth * (0.5 - (zoomRatio * 0.48))
        let maxX = screenWidth * (0.5 + (zoomRatio * 0.48))
        let minY = screenHeight * (0.5 - (zoomRatio * 0.4))
        let maxY = screenHeight * (0.5 + (zoomRatio * 0.4))
        
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
    
    
    
    /*@objc func handleTapFrom(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }

        let touchLocation = sender.location(in: sender.view)
        let location = self.convertPoint(fromView: touchLocation)

        // Get the node at the touch location
        let spriteNode = self.atPoint(location) as? SKSpriteNode

        if let node = spriteNode {
            debugPrint("Tapped node: \(node.name ?? "Unnamed")") // Debug info
            if node.name == countryNameLabel.text {
                playCorrectSound()
                paintNode(spriteNode: node)
                setLabelForCountryNameAndAddToNode(nodeSprite: node)
                removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                setNewCountryNameToLookUp()
                addToScoreCountWriteToLabel()
            }
        } else {
            debugPrint("No node detected at: \(location)") // Debug info
        }
    }*/
    
    
    @objc func handleTapFrom(_ sender: UITapGestureRecognizer){
            
            
            if sender.state == .recognized {//execute code as soon as gesture is recognized
                
                let touchLocation = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
                let location = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
                
                if let tutorial = tutorialOverlay {
                            tutorial.handleTouch(at: location)
                            return
                        }
                
                let touchedNode = self.physicsWorld.body(at:location)//Defines that touch will take effect when it gets in contact with an SKphysics body
                
                
                                
                if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
                    if (countryNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                        let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                        //spritenode.physicsBody = nil LINE WAS COMMENTED DUE PHYSICS ARE NEEDED A LONG THE GAME TO CATCH THE WRONG ANSWERED NODES THAT HAVE BEEN ALREADY IDENTIFIED AS IN ANDROID GAME.
                        playCorrectSound()
                        setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                        //playCorrectSound()
                        paintNode(spriteNode: spritenode)//color SKSpriteNode green
                        /**Set labels and add them to map texture(node)*/
                        //setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                        //playCorrectSound()
                        /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                        removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                        /**set new country to look after*/
                        setNewCountryNameToLookUp()
                        /**add one to number of countries located*/
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
                   
                    //else statement will execute whenever a wrong country node is touched
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

                    // Check if the touched node is an SKSpriteNode and if it matches the country name
                    /*if let spriteNode = touchedNode as? SKSpriteNode, spriteNode.name == countryNameLabel.text {
                        // Proceed with actions on the spriteNode
                        playCorrectSound()
                        paintNode(spriteNode: spriteNode)
                        setLabelForCountryNameAndAddToNode(nodeSprite: spriteNode)
                        removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                        setNewCountryNameToLookUp()
                        addToScoreCountWriteToLabel()
                        return
                    }*/
                    //debugPrint(touchedNodes)
                    
                    
                    /*if (touchedNodes.contains(where: { $0.name == controlPanelSKSpriteNode.name }))  {
                        return // Ignore the touch if it's on the control panel or the background
                    }*/
                    
                    /*if touchedNodes.contains(where: { $0.name == countryNameLabel.text }) {
                        if let spriteNode = touchedNodes.first(where: { $0.name == countryNameLabel.text }) as? SKSpriteNode {
                            //spriteNode.physicsBody = nil // Remove physics if needed
                            playCorrectSound()
                            paintNode(spriteNode: spriteNode)
                            setLabelForCountryNameAndAddToNode(nodeSprite: spriteNode)
                            removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                            setNewCountryNameToLookUp()
                            addToScoreCountWriteToLabel()
                            debugPrint("Inside Nodes Correct")
                            debugPrint("Tapped node: \(spriteNode.name ?? "Unnamed")") // Debug info
                            return
                        }
                    }*/
                    

                    if let spriteNode = touchedNodes.first(where: { $0.name == countryNameLabel.text }) as? SKSpriteNode {
                                //spriteNode.physicsBody = nil // Remove physics if needed
                                playCorrectSound()
                                paintNode(spriteNode: spriteNode)
                                setLabelForCountryNameAndAddToNode(nodeSprite: spriteNode)
                                removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                                setNewCountryNameToLookUp()
                                addToScoreCountWriteToLabel()
                                debugPrint("Inside Nodes Correct")
                               debugPrint("Tapped node: \(spriteNode.name ?? "Unnamed")") // Debug info
                                return
                            }
                    
                    if ((touchedNodes.first(where: { $0.name != countryNameLabel.text }) as? SKSpriteNode) != nil) && (touchedNodes.first(where: { $0.parent == containerNode }) != nil) || ((touchedNodes.first(where: { $0.name == mapRectangleBackground.name })) != nil){
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
            
            let touchLocation = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
            let location = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
            let touchedNode = self.physicsWorld.body(at:location)//Defines that touch will take effect when it gets in contact with an SKphysics body
            
            if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
                if (countryNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                    let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                    spritenode.physicsBody = nil
                    playCorrectSound()
                    setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                    //playCorrectSound()
                    paintNode(spriteNode: spritenode)//color SKSpriteNode green
                    /**Set labels and add them to map texture(node)*/
                    //setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                    //playCorrectSound()
                    /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                    removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                    /**set new country to look after*/
                    setNewCountryNameToLookUp()
                    /**add one to number of countries located*/
                    addToScoreCountWriteToLabel()
                    return
                }
                
                /*Skip button touch action**/
                else if (skipButton.name == touchedNode?.node?.name){//Es lo mismo que preguntar si el physics body tocado se llama (name) como skipButton, la condicion quiere saber si tocamos skipButton basicamente
                    addOneTocurrentIndexSetNameToLookUp()
                   
                }
                /**Exit button touch action*/
                else if (exitRedButton.name == touchedNode?.node?.name){
                    goToStartMenu()
                    
                }
               
                //else statement will execute whenever a wrong country node is touched
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
        
        // Commented out — now falls through to dynamic else block using baseMapScale/maxZoomScale
        /*else if screenSize.width == 1242.0 && screenSize.height == 2288.0 || screenSize.width == 828.0 && screenSize.height == 1792.0 || screenSize.width == 1242.0 && screenSize.height == 2688.0{

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
        }*/
        
        // Commented out — now falls through to dynamic else block using baseMapScale/maxZoomScale
        /*else if screenSize.width == 1170.0 && screenSize.height == 2532.0 || screenSize.width == 1179.0 && screenSize.height == 2556.0{

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
        }*/
        
        // Commented out — now falls through to dynamic else block using baseMapScale/maxZoomScale
        /*else if screenSize.width == 1284.0 && screenSize.height == 2778.0 || screenSize.width == 1290.0 && screenSize.height == 2796.0{

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
        }*/
        
        // Commented out — now falls through to dynamic else block using baseMapScale/maxZoomScale
        /*else if screenSize.width == 1206.0 && screenSize.height == 2622.0 /*|| screenSize.width == 1179.0 && screenSize.height == 2556.0*/{

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
        }*/
        
        // Commented out — now falls through to dynamic else block using baseMapScale/maxZoomScale
        /*else if screenSize.width == 1320.0 && screenSize.height == 2868.0 {

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
        }*/
        
        // Dynamic zoom clamping for screens (750,1334), (1080,2340), (1125,2436) and default fallback.
        // Uses baseMapScale (minimum/default zoom) and maxZoomScale (maximum zoom-in) instead of
        // hardcoded values. These are set by the positioning function during didMove, so the pinch
        // handler always stays in sync with however the map was initially scaled and positioned.
        else{
            if mapRectangleGestureMGMT.xScale * sender.scale < baseMapScale {
                sender.scale = baseMapScale / mapRectangleGestureMGMT.xScale
            } else if mapRectangleGestureMGMT.xScale * sender.scale > maxZoomScale {
                sender.scale = maxZoomScale / mapRectangleGestureMGMT.xScale
            }

            if mapRectangleGestureMGMT.yScale * sender.scale < baseMapScale {
                sender.scale = baseMapScale / mapRectangleGestureMGMT.yScale
            } else if mapRectangleGestureMGMT.yScale * sender.scale > maxZoomScale {
                sender.scale = maxZoomScale / mapRectangleGestureMGMT.yScale
            }
            debugPrint("Dynamic scaling: base=\(baseMapScale), max=\(maxZoomScale) — iPhoneSE(2nd/3rd gen), 8, iPhone 12 mini, iPhone 13 mini, iPhone X, iPhone XS, iPhone 11 PRO scaling is limited")
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
            
            // Commented out — now falls through to dynamic else block using baseMapScale
            /*else if screenSize.width == 1242.0 && screenSize.height == 2288.0 || screenSize.width == 828.0 && screenSize.height == 1792.0 || screenSize.width == 1242.0 && screenSize.height == 2688.0{
                if mapRectangleGestureMGMT.xScale > 1.45 && mapRectangleGestureMGMT.yScale > 1.45{
                    isScaled = true
                    debugPrint("iPhone Xr(18.6), 11(18.6), Xs Max(18.6), 11 Pro Max(18.6) is Scaled")
                }
            }*/
            
            // Commented out — now falls through to dynamic else block using baseMapScale
            /*else if screenSize.width == 1170.0 && screenSize.height == 2532.0 || screenSize.width == 1179.0 && screenSize.height == 2556.0 {
                if mapRectangleGestureMGMT.xScale > 1.37 && mapRectangleGestureMGMT.yScale > 1.37{
                    isScaled = true
                    debugPrint("iPhone 12, iPhone 12Pro, iPhone 13, iPhone 13 Pro, iPhone 14, iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16, iPhone 16e is Scaled")
                }
            }*/
            
            // Commented out — now falls through to dynamic else block using baseMapScale
            /*else if screenSize.width == 1284.0 && screenSize.height == 2778.0 || screenSize.width == 1290.0 && screenSize.height == 2796.0 {
                if mapRectangleGestureMGMT.xScale > 1.5 && mapRectangleGestureMGMT.yScale > 1.5{
                    isScaled = true
                    debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus is Scaled")
                }
            }*/
            
            // Commented out — now falls through to dynamic else block using baseMapScale
            /*else if screenSize.width == 1206.0 && screenSize.height == 2622.0 /*|| screenSize.width == 1179.0 && screenSize.height == 2556.0*/ {
                if mapRectangleGestureMGMT.xScale > 1.37 && mapRectangleGestureMGMT.yScale > 1.37{
                    isScaled = true
                    debugPrint("iPhone 16 PRO, iPhone 17, iPhone 17 PRO is Scaled")
                }
            }*/
            
            // Commented out — now falls through to dynamic else block using baseMapScale
            /*else if screenSize.width == 1320.0 && screenSize.height == 2868.0 {
                if mapRectangleGestureMGMT.xScale > 1.5 && mapRectangleGestureMGMT.yScale > 1.5{
                    isScaled = true
                    debugPrint("iPhone 16 ProMax, iPhone 17 ProMax is Scaled")
                }
            }*/
            
            
            // Dynamic isScaled check for screens (750,1334), (1080,2340), (1125,2436) and default fallback.
            // When the current scale exceeds baseMapScale, panning is enabled via isScaled flag.
            // This flag is what handlePan checks before allowing the user to drag the map.
            else{
                if mapRectangleGestureMGMT.xScale > baseMapScale && mapRectangleGestureMGMT.yScale > baseMapScale {
                    isScaled = true
                    debugPrint("Dynamic isScaled check: base=\(baseMapScale) — iPhoneSE(2nd/3rd gen), 8, iPhone 12 mini, iPhone 13 mini, iPhone X, iPhone XS, iPhone 11 PRO is scaled")
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
                    
            // Dynamic snap-back for screens (750,1334), (1080,2340), (1125,2436).
            // When the user pinches back to baseMapScale (within tolerance), the map resets:
            // isScaled is set to false (disabling panning) and position snaps to baseMapPosition
            // (the original centered position computed by the positioning function during didMove).
            case (750.0, 1334.0), (1080.0, 2340.0),(1125.0, 2436.0), (1242.0, 2208.0), (828.0, 1792.0), (1242.0, 2688.0), (1170.0, 2532.0), (1179.0, 2556.0), (1284.0, 2778.0), (1290.0, 2796.0), (1206.0, 2622.0), (1320.0, 2868.0):
                    if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = baseMapPosition
                        debugPrint("Dynamic snap-back: base=\(baseMapScale) — iPhoneSE(2nd/3rd gen), 8, iPhone 12 mini, 13 mini, X, XS, 11 PRO, Xr, 11, Xs Max, 11 Pro Max, 12, 12Pro, 13, 13Pro, 14, 14Pro, 15, 15Pro, 16, 16e, 12ProMax, 13ProMax, 14plus, 14ProMax, 15plus, 15ProMax, 16Plus back to original position")
                    }

            // Commented out — now merged into dynamic snap-back case above
            /*case (1242.0, 2208.0), (828.0, 1792.0 ),(1242.0, 2688.0 ) :
                //debugPrint("iPhone 8plus, XR, 11, XSMax, 11ProMax")
                if abs(mapRectangleGestureMGMT.xScale - 1.45) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.45) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.716/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone Xr, 11, Xs Max, 11 Pro Max is back to original position")
                }*/
                    
                
                
            // Commented out — now merged into dynamic snap-back case above
            /*case (1170.0, 2532.0), (1179.0, 2556.0):
                 //debugPrint("iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro")
                 if abs(mapRectangleGestureMGMT.xScale - 1.37) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.37) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.67/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 12, iPhone 12Pro, iPhone 13, iPhone 13 Pro, iPhone 14, iPhone 14 Pro, iPhone 15, iPhone 15 Pro, iPhone 16, iPhone 16e is back to original position")
                }*/
                    
                
                
            // Commented out — now merged into dynamic snap-back case above
            /*case (1284.0, 2778.0), (1290.0, 2796.0):
                 //debugPrint("iPhone 12ProMax, 13ProMax, 14plus, 13Pro, 14ProMax")
                 if abs(mapRectangleGestureMGMT.xScale - 1.5) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.5) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 12ProMax, iPhone 13 Pro Max, iPhone 14 plus, iPhone 14 ProMax, iPhone 15 plus, iPhone 15 ProMax, iPhone 16 Plus is back to original position")
                }*/
                
            // Commented out — now merged into dynamic snap-back case above
            /*case (1206.0, 2622.0):
                 //debugPrint("iPhone 12, 12Pro, 13, 13Pro, 14, 14Pro")
                 if abs(mapRectangleGestureMGMT.xScale - 1.37) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.37) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.72/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 16 PRO, iPhone 17, iPhone 17 PRO is back to original position")
                }*/
                
            // Commented out — now merged into dynamic snap-back case above
            /*case (1320.0, 2868.0):
                 //debugPrint("iPhone 12ProMax, 13ProMax, 14plus, 13Pro, 14ProMax")
                 if abs(mapRectangleGestureMGMT.xScale - 1.5) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.5) < tolerance {
                    isScaled = false
                     mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.765/*1.8*/)//Whenever node is scaled back to default size the node is repositioned at default position or center
                    debugPrint("iPhone 16 ProMax, iPhone 17 ProMax is back to original position")
                }*/
                    
                    
                // Default fallback uses the same dynamic snap-back logic.
                // Catches any screen size not explicitly listed above.
                default:
                    if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = baseMapPosition
                        debugPrint("Default dynamic snap-back: base=\(baseMapScale) — back to original position")
                    }
                    break
                
            }

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
    
    /*func initMusic() {//As per Claude not using optional chaining potential memory leaks
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
        // Set tutorial as active to pause timer
        isTutorialActive = true
        
        // Create tutorial overlay
        tutorialOverlay = TutorialOverlay(scene: self, isPracticeMode: false)
        
        // Set completion callback
        tutorialOverlay?.onComplete = { [weak self] in
            debugPrint("Tutorial completed")
            self?.isTutorialActive = false  // Resume timer
            self?.tutorialOverlay = nil     // Clear the reference
        }
        
        // Set skip callback
        tutorialOverlay?.onSkip = { [weak self] in
            debugPrint("Tutorial skipped")
            self?.isTutorialActive = false  // Resume timer
            self?.tutorialOverlay = nil     // Clear the reference
        }
        
        // Show the tutorial
        tutorialOverlay?.show()
    }
    
//ORIGINAL WORKING FUNCTION BEFORE CLAUDE CHANGES
    /*override public func update(_ currentTime: TimeInterval) {/*Function execute every second, for timer functionality*/
        
        
       if AlphabeticGameScene.completedGame == false{//Control variable to keep the timer running, once condition is true the timer is stopped
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
        
        if AlphabeticGameScene.completedGame == true{
            goToGameOverScene()
        }
        
    }*/
    //CLAUDE EDITED FUNCTION TO STOP TIMER FOR ONBOARDING TUTORIAL
    override public func update(_ currentTime: TimeInterval) {/*Function execute every second, for timer functionality*/
        
        // Don't run timer during tutorial
        /*if isTutorialActive {
            return
        }*/
        
        if isTutorialActive || isAdShowing {
            return
        }
        
        if AlphabeticGameScene.completedGame == false{//Control variable to keep the timer running, once condition is true the timer is stopped
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
        
        if AlphabeticGameScene.completedGame == true{
            goToGameOverScene()
        }
        
    }
    
    //Function adds seconds and minute, also adds penalties when wrong node or skip button is pressed
    func timerManagement(){
            addSecond()
            //seconds += 1
            if seconds == 60 {
                resetSecondsAddMinutes()

            }
            
            //Este bloque solo se ejecuta cuando se presiona sobre el country incorrecto, anadiendo 3 segundos al reloj
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
        // AdManager.shared.removeBanner()
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.5)
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    //Function gets seconds and minutes to be evaluated at gameOverScene
    func getSecondsAndMinutes(){
        AlphabeticGameScene.secondsGameOver = seconds
        AlphabeticGameScene.minutesGameOver = minutes
    }
    
    //function manage touch on screen
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {//Touch function
         
        let touch = touches.first!//store touch
        let touchLocation = touch.location(in: self)//Defines the space where touch is taking effect, in this case StartScene
        let touchedNode = self.physicsWorld.body(at:touchLocation)//Defines that touch will take effect when it gets in contact with an SKphysics body
        
        
    
        if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
            if (countryNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                paintNode(spriteNode: spritenode)//color SKSpriteNode green
                playCorrectSound()
                /**Set labels and add them to map texture(node)*/
                setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                /**set new country to look after*/
                setNewCountryNameToLookUp()
                /**add one to number of countries located*/
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
           
            //else statement will execute whenever a wrong country node is touched
            else{
                playIncorrectSound()
                
                return fail = true//variable updates to apply 3 seconds penalty at timer function
            }
        }
    }*/
    
    func playCorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(correctSound)//correctSound
        }
    }
    
    //paint nodes green also sets physics body to nil
    func paintNode(spriteNode:SKSpriteNode){
        spriteNode.colorBlendFactor = 0.8
        spriteNode.color = UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)//(red: 0, green: 1, blue: 1, alpha: 1.0)//(red: 0.098, green: 1, blue: 1, alpha: 1.0)//UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)//UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)//(red: 0, green: 1, blue: 0.9137, alpha: 1.0)//UIColor.init(red: 0.0314, green: 1, blue: 0.7843, alpha: 1.0)//UIColor.init(red: 0.5686, green: 1, blue: 0.8745, alpha: 1.0)
        //spriteNode.colorBlendFactor = 0.8
        //spriteNode.physicsBody = nil
    }
    
    //following function sets labels for country names using one or two labels and adds labels to map node(country map node)
    func setLabelForCountryNameAndAddToNode(nodeSprite:SKSpriteNode){

           let locationNameLabel = SKLabelNode()
           let firstLineLabel = SKLabelNode()
           let secondLineLabel = SKLabelNode()
           locationNameLabel.text = countryNameLabel.text

           switch countryNameLabel.text {

           // One-line countries - large landmasses
           // Leader line countries (too small for inline label)
           case "Belize":
               addBelizeLeaderLineLabel(to: nodeSprite)
               return

           case "Brazil":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 7.5
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.position = CGPoint(x: 10.0, y: 10.0)

           case "Canada":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 7.0
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.position = CGPoint(x: -41.0, y: -6.5)

           case "Chile":
               addChileLeaderLineLabel(to: nodeSprite)
               return

           case "Argentina":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 7.0
               locationNameLabel.position = CGPoint(x: -1.0, y: 0.0)

           case "Colombia":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 5.5

           case "Cuba":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 6.0
               locationNameLabel.position = CGPoint(x: 2.0, y: 0.0)

           case "Ecuador":
               addEcuadorLeaderLineLabel(to: nodeSprite)
               return

           case "Greenland":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 6.5
               locationNameLabel.position = CGPoint(x: -5.0, y: 6.0)

           case "Guatemala":
               addGuatemalaLeaderLineLabel(to: nodeSprite)
               return

           case "Guyana":
               addGuyanaLeaderLineLabel(to: nodeSprite)
               return

           case "Suriname":
               addSurinameLeaderLineLabel(to: nodeSprite)
               return

           case "Haiti":
               addHaitiLeaderLineLabel(to: nodeSprite)
               return

           case "Honduras":
               addHondurasLeaderLineLabel(to: nodeSprite)
               return

           case "Jamaica":
               addJamaicaLeaderLineLabel(to: nodeSprite)
               return

           case "Mexico":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 6.8

           case "Nicaragua":
               addNicaraguaLeaderLineLabel(to: nodeSprite)
               return

           case "Panama":
               addPanamaLeaderLineLabel(to: nodeSprite)
               return

           case "Paraguay":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 5.0
               locationNameLabel.zRotation = -0.6

           case "Peru":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 6.0
               locationNameLabel.position = CGPoint(x: -3.0, y: 0.0)
               //locationNameLabel.zRotation = -0.9

           case "Uruguay":
               addUruguayLeaderLineLabel(to: nodeSprite)
               return

           case "Venezuela":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.fontSize = 5.5
               locationNameLabel.position = CGPoint(x: 0.0, y: 3.0)

           case "Bolivia":
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 7.0
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
               locationNameLabel.position = CGPoint(x: -1.5, y: 0.0)

           // Two-line countries
           case "United States":
               setTwoLineCountryNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
               firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
               secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
               firstLineLabel.fontSize = 7.0
               secondLineLabel.fontSize = 7.0
               firstLineLabel.position = CGPoint(x: 40.0, y: -11.0)
               secondLineLabel.position = CGPoint(x: 40.0, y: -18.5)

           case "Costa Rica":
               addCostaRicaLeaderLineLabel(to: nodeSprite)
               return

           case "Dominican Republic":
               addDominicanRepublicLeaderLineLabel(to: nodeSprite)
               return

           case "El Salvador":
               addElSalvadorLeaderLineLabel(to: nodeSprite)
               return

           case "French Guiana":
               addFrenchGuianaLeaderLineLabel(to: nodeSprite)
               return

           case "Puerto Rico":
               addPuertoRicoLeaderLineLabel(to: nodeSprite)
               return

           case "The Bahamas":
               addTheBahamasLeaderLineLabel(to: nodeSprite)
               return

           default:
               setOneLineCountryNameLabel(Oneline:locationNameLabel)
               locationNameLabel.horizontalAlignmentMode = .center
               locationNameLabel.verticalAlignmentMode = .center
           }

           if(useLine2 == true){
             nodeSprite.addChild(firstLineLabel)
             nodeSprite.addChild(secondLineLabel)
             useLine2 = false
           }
           else{
             nodeSprite.addChild(locationNameLabel)
           }
       }
    
    // Belize: leader line pointing 2 o'clock over the Caribbean
    func addBelizeLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Belize"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 5.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 15.0, y: 6.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 7.0, y: 5.5))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Chile: leader line pointing left over the Pacific
    func addChileLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Chile"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 7.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -35.0, y: 0.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -12.0, y: 0.0))
        path.addLine(to: CGPoint(x: -25.0, y: 0.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Costa Rica: two-line leader line pointing left over the Pacific
    func addCostaRicaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "Costa"
        secondLineLabel.text = "Rica"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 5.5
        secondLineLabel.fontSize = 5.5
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: -15.0, y: -16.0)
        secondLineLabel.position = CGPoint(x: -15.0, y: -21.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: -8.0, y: -10.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // Dominican Republic: two-line leader line pointing north-north-east
    func addDominicanRepublicLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "Dominican"
        secondLineLabel.text = "Republic"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 5.0
        secondLineLabel.fontSize = 5.0
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: 10.0, y: 12.0)
        secondLineLabel.position = CGPoint(x: 10.0, y: 7.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 6.0, y: 7.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // Ecuador: leader line pointing west between landmass and Galapagos
    func addEcuadorLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Ecuador"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 5.5
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -6.5, y: 0.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 5.0, y: 0.0))
        path.addLine(to: CGPoint(x: 10.0, y: 0.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Guatemala: leader line pointing southwest toward the Pacific
    func addGuatemalaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Guatemala"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 6.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -18.0, y: -10.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: -10.0, y: -7.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Haiti: leader line pointing straight south
    func addHaitiLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Haiti"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 5.5
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0.0, y: -8.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: -4.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Honduras: short leader line pointing east toward the Caribbean
    func addHondurasLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Honduras"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 4.5
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 9.5, y: 7.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4.0, y: 3.0))
        path.addLine(to: CGPoint(x: 6.0, y: 5.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Jamaica: leader line pointing straight south
    func addJamaicaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Jamaica"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 4.8
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -4.0, y: -9.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: -0.5))
        path.addLine(to: CGPoint(x: 0.0, y: -6.9))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Nicaragua: leader line pointing 3 o'clock into the Caribbean
    func addNicaraguaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Nicaragua"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 5.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 17.0, y: -2.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: -2.0))
        path.addLine(to: CGPoint(x: 6.0, y: -2.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Panama: leader line pointing 6 o'clock into the Pacific
    func addPanamaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Panama"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 5.5
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: -6.0, y: -12.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -3.0, y: -2.0))
        path.addLine(to: CGPoint(x: -3.0, y: -10.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Guyana: leader line pointing straight north into the Atlantic
    func addGuyanaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Guyana"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 6.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 2.5, y: 18.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 5.0))
        path.addLine(to: CGPoint(x: 0.0, y: 14.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // Suriname: leader line pointing between 1-2 o'clock into the Atlantic
    func addSurinameLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Suriname"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 6.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 11.0, y: 14.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 9.0, y: 11.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    // French Guiana: two-line leader line pointing east over the Atlantic
    func addFrenchGuianaLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "French"
        secondLineLabel.text = "Guiana"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 6.0
        secondLineLabel.fontSize = 6.0
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: 25.5, y: 2.0)
        secondLineLabel.position = CGPoint(x: 25.5, y: -3.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 3.0, y: 0.0))
        path.addLine(to: CGPoint(x: 14.0, y: 0.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.zPosition = 1
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // El Salvador: two-line leader line pointing south into the Pacific
    func addElSalvadorLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "El"
        secondLineLabel.text = "Salvador"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 5.0
        secondLineLabel.fontSize = 5.0
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: -4.0, y: -12.5)
        secondLineLabel.position = CGPoint(x: -4.0, y: -17.5)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: -2.5, y: -5.5))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // Puerto Rico: two-line leader line pointing 3 o'clock from east coast
    func addPuertoRicoLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "Puerto"
        secondLineLabel.text = "Rico"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 5.5
        secondLineLabel.fontSize = 5.5
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: 18.0, y: 0.5)
        secondLineLabel.position = CGPoint(x: 18.0, y: -5.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 3.0, y: 0.0))
        path.addLine(to: CGPoint(x: 11.0, y: 0.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // The Bahamas: two-line leader line pointing north-east
    func addTheBahamasLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let firstLineLabel = SKLabelNode()
        let secondLineLabel = SKLabelNode()
        firstLineLabel.text = "The"
        secondLineLabel.text = "Bahamas"
        firstLineLabel.fontName = "ArialMT"
        secondLineLabel.fontName = "ArialMT"
        firstLineLabel.fontColor = UIColor.black
        secondLineLabel.fontColor = UIColor.black
        firstLineLabel.fontSize = 5.0
        secondLineLabel.fontSize = 5.0
        firstLineLabel.horizontalAlignmentMode = .center
        secondLineLabel.horizontalAlignmentMode = .center
        firstLineLabel.position = CGPoint(x: 16.0, y: 14.0)
        secondLineLabel.position = CGPoint(x: 16.0, y: 10.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 2.0, y: 2.0))
        path.addLine(to: CGPoint(x: 10.0, y: 10.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(firstLineLabel)
        nodeSprite.addChild(secondLineLabel)
    }

    // Uruguay: leader line pointing 3 o'clock into the Atlantic
    func addUruguayLeaderLineLabel(to nodeSprite: SKSpriteNode) {
        let label = SKLabelNode()
        label.text = "Uruguay"
        label.fontName = "ArialMT"
        label.fontColor = UIColor.black
        label.fontSize = 6.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 25.0, y: -3.0)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 3.0, y: -3.0))
        path.addLine(to: CGPoint(x: 12.0, y: -3.0))
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.black
        line.lineWidth = 0.15

        nodeSprite.addChild(line)
        nodeSprite.addChild(label)
    }

    //sets attributes for label to use with one word country names
    func setOneLineCountryNameLabel(Oneline:SKLabelNode){
        //Oneline.text = countryNameLabel.text
        Oneline.fontName = "ArialMT"//"Helvetica"
        Oneline.fontColor = UIColor.black
        //Oneline.xScale = -1.0
        //Oneline.zRotation = 9.44
        Oneline.fontSize = 8.0
    }
    //sets attributes for labels to use with two word country names
    func setTwoLineCountryNameLabels(labelLineFirst:SKLabelNode, labelLineSecond:SKLabelNode){

        labelLineFirst.fontName = "ArialMT"//"Helvetica"
        labelLineSecond.fontName = "ArialMT"//"Helvetica"
        labelLineFirst.fontSize = 3.0
        labelLineSecond.fontSize = 3.0
        labelLineFirst.fontColor = UIColor.black
        labelLineSecond.fontColor = UIColor.black
        //labelLineFirst.xScale = -1.0
        //labelLineSecond.xScale = -1.0
        //labelLineFirst.zRotation = 9.44
        //labelLineSecond.zRotation = 9.44
    }
    
    //The next two fucctions are identical with the difference that each return a different part of the text
    func splitTextIntoFields(theText:String)->String{
        
        twoLineText = theText//text to split in two(ex:"Aguas Buenas")

        var line1:String = ""//var declaration for String value to be returned
        var line2:String = ""
            
            
        for letter in twoLineText{//each character is split on each for loop iteration(one character at a time)
            if (String(letter) == " "){
                useLine2 = true
            }
                
            if(useLine2 == false){
                line1 = line1 + String(letter)//casting of letter to String
            }
            else {
                line2 = line2 + String(letter)
            }
                
            //i += 1
        }
        return line1
    }
    
    func splitTextIntoFieldsTwo(theText:String)->String{
        useLine2 = false//This lie resets the variable which is necessary in order not to create repetition of text ex Aguas Aguas Buenas
        //var twoLineText: String = ""
        twoLineText = theText
        //var i: Int = 0
        var line1:String = ""
        var line2:String = ""
            
            
        for letter in twoLineText{
            if (String(letter) == " "){
                useLine2 = true
            }
                
            if(useLine2 == false){
                line1 = line1 + String(letter)
            }
            else {
                line2 = line2 + String(letter)
            }
                
            //i += 1
            }
        return line2
    }
    
    func removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval(){
        let countOfIndexes = countries_names_array.count - 1//Gets the number of indexes in array

        /**cuurentIndex and countOfIndexes will be different as long as the end of the array have not been reached. they become equal under two scenarios when the end of array is reached but still some skipped nodes remain to be identified
         or reaching the end of array by  identifying all nodes*/
        if currentIndex != countOfIndexes{
            countries_names_array.remove(at:currentIndex)//remove element at the index from array
        }
            
        /**This condition equals true when currentIndex and countOfIndexes are equals but both equal or bigger than 1. This scenario will play out when skipButtom is pressed , this moves the index forward from default index position 0. When index have moved foward  and the end of array have been reached(at this point currentIndex and countOfIndexes are equals but both equal or bigger than 1 (Note:actually both value are equals to the number of skipped elements)) , then currentIndex must be moved back to 0 in order to be able to evaluate and look up the remaining skipped elements.  */
        else if currentIndex == countOfIndexes && currentIndex >= 1 && countOfIndexes >= 1{
            countries_names_array.remove(at:currentIndex)//remove element at the index from array
            currentIndex = 0/*resets currentIndex once end of array been reached to go back to index 0 and go over the remaining skipped countries*/
        }
            
        /**following statement will execute when currentIndex and countOfIndexes equals 0 meaning that last element have been identified and prepare the game to move to gameOverScene*/
        
        //CLAUDE ELSE STATEMENT TO OPTIMIZE GAME TO GAMEOVERSCENE TRANSITION
        else{
            getSecondsAndMinutes()//gets seconds and minutes to be used for time record function at gameOverScene
            // Use an action to delay setting completedGame, allowing the correct sound to play
            let waitAction = SKAction.wait(forDuration: 0.00001)
            let completeAction = SKAction.run {
                AlphabeticGameScene.completedGame = true
            }
            self.run(SKAction.sequence([waitAction, completeAction]))
        }
        
        //ORIGINAL ELSE BLOCK
        /*else{
            //musicPlayer.stop()
            //self.removeAllActions()//It catches the last correctSound in order for transition to gameOverScene to flow smoother with less laggin
            getSecondsAndMinutes()//gets seconds and minutes to be used for time record function at gameOverScene
            AlphabeticGameScene.completedGame = true//variable updates to stop the timer and execute the transition to gameOverScene (gameOverScene TRANSITION EXECUTES AT UPDATE FUNCTION)
        }*/
        /**the following condition is true when var countOfIndexes == 1(meaning there are two elements left 0 and 1) and currentIndex value is 0 or first index of array, where is the second to last element(penultimo elemento), that at this point have been already removed in the block above. But due countOfIndexes updates in the following iteration, to the effect of the present iteration there are two elements left and this allows for this condition to evaluate to true in order to toguether with the removing second to last element(in the previous block) its also removed the skipButton on this block. WHAT IS IMPORTANT TO ACKNOWLEDGE IS THAT THE REMOTION OF SECOND TO LAST(PENULTIMO) ELEMENT AND SKIPBUTTON HAPPENS IN THE SAME ITERATION*/
        if  countOfIndexes == 1 && currentIndex == 0 && countries_names_array.endIndex-1 == 0 {
         //debugPrint("skip button out")
         skipButton.removeFromParent()
        }
        
    }
    
    /**following function pass text attributes for the next country name to look up and adjust the background size for the label(countryNameLabel) */
    func setNewCountryNameToLookUp(){
        countryNameLabel.fontSize = 20 // Reset to default before measuring
        countryNameLabel.text = countries_names_array [currentIndex] //Writes to label the next country name to be located by player
        resizeCountryNameBackground()
    }

    /// Dynamically resizes countriesNameBackground to fit the current countryNameLabel text with rounded corners and border.
    /// Auto-shrinks the font if the name is too long to fit between the Salir/Saltar buttons.
    func resizeCountryNameBackground(){
        let horizontalPadding: CGFloat = 36.0
        let bgHeight: CGFloat = 30.0
        let bgScale: CGFloat = 1.10
        // Buttons are at x:±110, each 50pt base * 1.30 scale = 65pt wide, inner edges at ±77.5
        // Max visual width with 8pt gap on each side: 155 - 16 = 139pt
        let maxVisualWidth: CGFloat = 139.0
        let maxUnscaledWidth: CGFloat = maxVisualWidth / bgScale
        let minFontSize: CGFloat = 12.0

        // Shrink font if text + padding exceeds max width
        let defaultFontSize: CGFloat = 20.0
        var textWidth = countryNameLabel.frame.size.width
        while textWidth + horizontalPadding > maxUnscaledWidth && countryNameLabel.fontSize > minFontSize {
            countryNameLabel.fontSize -= 1
            textWidth = countryNameLabel.frame.size.width
        }

        // Adjust label y position — smaller fonts need a slight upward nudge to stay centered
        let fontShrinkAmount = defaultFontSize - countryNameLabel.fontSize
        countryNameLabel.position.y = -7.5 + (fontShrinkAmount * 0.15)

        let newWidth = min(textWidth + horizontalPadding, maxUnscaledWidth)

        let roundedPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: newWidth, height: bgHeight), cornerRadius: bgHeight / 2.0)
        let shapeNode = SKShapeNode(path: roundedPath.cgPath)
        shapeNode.fillColor = UIColor(red: 0.2392, green: 0.698, blue: 1, alpha: 1.0)
        shapeNode.strokeColor = UIColor(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)
        shapeNode.lineWidth = 4.0

        let textureView = SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        if let texture = textureView.texture(from: shapeNode) {
            countriesNameBackground.texture = texture
            countriesNameBackground.size = texture.size()
        }
    }

    /*// Old hardcoded setNewCountryNameToLookUp - kept for reference
    func setNewCountryNameToLookUp_OLD(){
        countryNameLabel.text = countries_names_array [currentIndex]
        switch(countryNameLabel.text){
            case "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande" :
                if countriesNameBackgroundTwo.parent == nil{
                    switch(countryNameLabel.parent?.name){
                        case "CountriesNameBackground":
                            countryNameLabel.removeFromParent()
                            countriesNameBackground.removeFromParent()
                            scaleCountryNameBackgroundTwoForScreenSizes()
                        case "CountriesNameBackgroundThree":
                            countryNameLabel.removeFromParent()
                            countriesNameBackgroundThree.removeFromParent()
                            scaleCountryNameBackgroundTwoForScreenSizes()
                        case "CountriesNameBackgroundFour":
                            countryNameLabel.removeFromParent()
                            countriesNameBackgroundFour.removeFromParent()
                            scaleCountryNameBackgroundTwoForScreenSizes()
                        default:
                        break
                    }
                    addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackgroundTwo, children: countryNameLabel)
                    addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackgroundTwo)
                }
        case "Barceloneta", "Canóvanas", "Juana Díaz", "Las Marías", "Las Piedras", "Rio Grande", "San Germán", "San Lorenzo", "Santa Isabel", "Barranquitas", "Quebradillas":
            if countriesNameBackgroundFour.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "CountriesNameBackground":
                        countryNameLabel.removeFromParent()
                        countriesNameBackground.removeFromParent()
                        scaleCountryNameBackgroundFourForScreenSizes()
                    case "CountriesNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundTwo.removeFromParent()
                        scaleCountryNameBackgroundFourForScreenSizes()
                    case "CountriesNameBackgroundThree":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundThree.removeFromParent()
                        scaleCountryNameBackgroundFourForScreenSizes()
                    default:
                    break
            }
                addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackgroundFour, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackgroundFour)
        }
        case  "Cabo Rojo", "Bayamón", "Guayanilla", "Guaynabo", "Guayama", "Humacao", "Mayagüez", "Maunabo", "Naguabo", "Peñuelas", "San Juan", "Vega Alta", "Vega Baja", "Naranjito", "Orocovis", "Trujillo Alto":
            if countriesNameBackgroundThree.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "CountriesNameBackground":
                        countryNameLabel.removeFromParent()
                        countriesNameBackground.removeFromParent()
                        scaleCountryNameBackgroundThreeForScreenSizes()
                    case "CountriesNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundTwo.removeFromParent()
                        scaleCountryNameBackgroundThreeForScreenSizes()
                    case "CountriesNameBackgroundFour":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundFour.removeFromParent()
                        scaleCountryNameBackgroundThreeForScreenSizes()
                    default:
                        break
                }
                addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackgroundThree, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackgroundThree)
            }
          default:
            if countriesNameBackground.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "CountriesNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundTwo.removeFromParent()
                    case "CountriesNameBackgroundThree":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundThree.removeFromParent()
                    case "CountriesNameBackgroundFour":
                        countryNameLabel.removeFromParent()
                        countriesNameBackgroundFour.removeFromParent()
                    default:
                    break
                }
                addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackground, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackground)
            }
            break
        }
    }*/
    
    /*// Old hardcoded scaling functions for background Two/Three/Four - kept for reference
    func scaleCountryNameBackgroundTwoForScreenSizes(){
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            countriesNameBackgroundTwo.setScale(1.3)
        }
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            countriesNameBackgroundTwo.setScale(1.4)
        }
        else{
            countriesNameBackgroundTwo.setScale(1.35)
        }
    }
    func scaleCountryNameBackgroundThreeForScreenSizes(){
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            countriesNameBackgroundThree.setScale(1.3)
        }
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            countriesNameBackgroundThree.setScale(1.4)
        }
        else{
            countriesNameBackgroundThree.setScale(1.35)
        }
    }
    func scaleCountryNameBackgroundFourForScreenSizes(){
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
            countriesNameBackgroundFour.setScale(1.3)
        }
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 2048.0 && screenSize.height == 2732.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
            countriesNameBackgroundFour.setScale(1.4)
        }
        else{
            countriesNameBackgroundFour.setScale(1.35)
        }
    }
    */
    
    //function updates the label rendering the number of countries identified already at the bottom right of screen
    func addToScoreCountWriteToLabel(){
        scoreCount += 1
        labelScores.text = "\(scoreCount)" + totalScoreCount//totalScoreCount es un constant string solo sirve al rendering del score
    }
    
    /*funtion adds 1 to currentIndex(due skipButton been pressed). Also gives alpha effect to the button when pressed, updates variables for penalty(pressSkipButton) at Update(timer) function and updates
    skipButtonPressed to complete alpha effect at touchesEnded function and set the new country to look up at countryNameLabel*/
    func addOneTocurrentIndexSetNameToLookUp(){
        currentIndex += 1
        //skipButton.alpha = 0.88
        pressSKipButton = true
        //skipButtonPressed = true THIS IS USED WHEN touchesEnd FUNCTION IS USED FOR ALPHA EFFECT ON BUTTON AT THE MOMENT IT IS NOT ON USE DUE TO HANDGESTURE TAP FUNCTION IS USED INSTEAD.
        
        if currentIndex == countries_names_array.endIndex-0{//Si el indice llega al ultimo elemento el index se devuelve al 0 para comenzar a iterar los countries que no fueron identificados en la pasada anterior del juego
            //debugPrint("This")//para programador
            currentIndex = 0//resetea el index al lugar 0 cuando presionando el skip button alcanzamos el ultimo indice
        }
        
        setNewCountryNameToLookUp()
        //debugPrint("Skip Button touched")
    }
    
    //transition to StartMenu Scene when exit button is pressed
    func goToStartMenu(){
        musicPlayer?.stop()
        // AdManager.shared.removeBanner()
        let startMenuScene = StartMenuScene(size: self.size)
        self.view?.presentScene(startMenuScene)
    }
    
    func playIncorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(incorrectSound)
        }
    }

    //function detects when the touch on screen have ended in order to complete alpha effect that started at addOneTocurrentIndexSetNameToLookUp()
    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        //Efecto para el skipButton cuando se suelta el boton
        if skipButtonPressed == true{
            debugPrint("ENtering touchesEnd")
            skipButton.alpha = 2.5//Ojo esto se veria mejor dentro de un if sin embargo  si utilizo una condicion como if skipButton.alpha == 1.0 causa un glitch, pero puedo hacer una condicion con una variable boolean
            skipButtonPressed = false
        }
        //Exit button does not have alpha effect as it goes out of view when pressed
    }*/

}

