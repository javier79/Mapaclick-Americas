//
//  RandomGameScene.swift
//  mapaclick
//
//  Created by javier pizarro on 9/26/23.
//

import Foundation
import SpriteKit
//import UIKit
import AVFoundation



class RandomGameScene: SKScene{
    
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
    
    let countryNameLabel = GameSceneObjects().labelForCountryNames()//Label rendering country name to look up, Used in more than one function
    // Dynamic country name background - resizes automatically based on text width(same as AlphabeticGameScene)
    let countriesNameBackground: SKSpriteNode = {
        let node = SKSpriteNode()
        node.position = CGPoint(x: 0.5, y: -0.5)
        node.name = "CountriesNameBackground"
        return node
    }()
    /*// Old PR hardcoded backgrounds - kept for reference
    let municipiosNameBackground = GameSceneObjects().labelCountriesNameBackground()//Background for most(shorter) country names. Used in more than one function
    let municipiosNameBackgroundTwo = GameSceneObjects().labelCountriesNameBackgroundTwo()//Background for longer country names. Used in more than one function
    let municipiosNameBackgroundThree = GameSceneObjects().labelCountriesNameBackgroundThree()
    let municipiosNameBackgroundFour = GameSceneObjects().labelCountriesNameBackgroundFour()
    */
    
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
    
    /*static var completedGame = false//se usa en mas de una funcion
    var twoLineText: String = ""//se usa solo en las dos funciones splitTextIntoFields puedo declararla en ambas funciones de manera local
    var useLine2:Bool = false//se usa en mas de una funcion*/

    /** Array contains country names in alphabetical order, matching the node names in InitSetMapNodes.
     Used to display the country name the player must find, picked at random.(same list as AlphabeticGameScene)*/
    var countries_names_array = ["Argentina", "Belize", "Bolivia", "Brazil", "Canada", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", "Ecuador", "El Salvador", "French Guiana", "Greenland", "Guatemala", "Guyana", "Haiti", "Honduras", "Jamaica", "Lesser Antilles", "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru", "Puerto Rico", "Suriname", "The Bahamas", "United States", "Uruguay", "Venezuela"]
    /*// Old PR municipios array - kept for reference
    /** Array includes Adjuntas although it' is written from the function that sets the label for municipios to look up, this is due  if adjuntas is skipped when the array reach the end to go back to index 0, then it gets Adjuntas.
     This array contain the text elements for the municipios to look up*/
    var municipios_names_array = ["Adjuntas", "Aguada", "Aguadilla", "Aguas Buenas", "Aibonito", "Arecibo", "Arroyo", "Añasco", "Barceloneta", "Barranquitas", "Bayamón", "Cabo Rojo", "Caguas", "Camuy", "Canóvanas", "Carolina", "Cataño", "Cayey", "Ceiba", "Ciales", "Cidra", "Coamo", "Comerío", "Corozal", "Culebra", "Dorado", "Fajardo", "Florida", "Guayama", "Guayanilla", "Guaynabo","Gurabo", "Guánica", "Hatillo", "Hormigueros", "Humacao", "Isabela", "Jayuya", "Juana Díaz", "Juncos", "Lajas", "Lares", "Las Marías", "Las Piedras", "Loíza", "Luquillo", "Manatí", "Maricao", "Maunabo", "Mayagüez", "Moca", "Morovis", "Naguabo", "Naranjito", "Orocovis", "Patillas", "Peñuelas", "Ponce", "Quebradillas", "Rincón", "Rio Grande", "Sabana Grande", "Salinas", "San Germán", "San Juan", "San Lorenzo", "San Sebastián", "Santa Isabel", "Toa Alta", "Toa Baja", "Trujillo Alto", "Utuado", "Vega Alta", "Vega Baja", "Vieques", "Villalba", "Yabucoa", "Yauco"]
    */

    //var touchedNode: SKPhysicsBody!//holds touched node, declared at the top to be accesed by accesory functions out of Touch function
    var fail: Bool!//flow control var allow when true for penalty to be added at timer funtion. Used on more than one funtion
    var currentIndex: Int = 0 //refers to index currently diplayed on municipio name label declared at the top to be accesed by accesory functions
    var pressSKipButton:Bool = false//Flow control variables when true allows timer to add 15 penalty
    var scoreCount:Int = 0//variable represent the number of municipios identified rendered in the control bar to the right
    //let totalScoreCount:String = "/78"
    let totalScoreCount:String = "/31"//must match countries_names_array.count
    
    let correctSound = SKAction.playSoundFileNamed("351566__bertrof__game-sound-correct-organic-violin", waitForCompletion: false)
    let incorrectSound = SKAction.playSoundFileNamed("351565__bertrof__game-sound-incorrect-organic-violin", waitForCompletion: false)
    //static var backgroundMusic = SKAudioNode(fileNamed: "predited.mp3")
    //var musicPlayer = AVAudioPlayer()//audio player
    var musicPlayer: AVAudioPlayer?//Claude suggested
    let musicURL:URL? = Bundle.main.url(forResource:"predited", withExtension:"mp3")//reference to PR Himn
    
    var skipButtonPressed = false//flow control var allows to apply alpha animation to skipbuttom on Touches end
    
    var randomIndex: Int = 0

    var isScaled = false

    // Dynamic zoom/pan properties(same as AlphabeticGameScene) — set once during didMove by the setScaleAndIndepRendering... positioning functions,
    // then referenced by handlePinchFrom (zoom clamping, isScaled detection, snap-back) and handlePan (zoom-aware pan boundaries).
    var baseMapScale: CGFloat = 1.0       // The default/minimum scale the map starts at (can't zoom out past this)
    var baseMapPosition: CGPoint = .zero  // The default position the map snaps back to when zoomed out to baseMapScale
    var maxZoomScale: CGFloat = 3.0       // The maximum zoom-in limit, computed as baseMapScale * 5.0 by the positioning functions
    var countriesNameBGScale: CGFloat = 1.10  // Scale for countriesNameBackground — set by device function, applied after resizeCountryNameBackground()
    
    var isAdShowing: Bool = false//Ads Logic
    
    let screenSize = UIScreen.main.nativeBounds
    
    override func didMove(to view: SKView){
        //Ads Logic
        // NotificationCenter.default.addObserver(self, selector: #selector(adWillShow), name: AdManager.adWillShowNotification, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(adDismissed), name: AdManager.adDismissedNotification, object: nil)
        backgroundNode = gameSceneObjects.createSceneBackground(scene: self)

        labelScores.text = "0" + totalScoreCount//overrides labelForScores() default text so initial total matches this scene
        /*Statement below is commented as a background node was implemented for the scene with the same color*/
        //self.backgroundColor = UIColor.init(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0)//blue background that resembles the ocean
        
        //mapRectangleGestureMGMT.zPosition = 0
        mapRectangleGestureMGMT.anchorPoint = CGPoint(x:0.5, y:0.5)
        mapRectangleGestureMGMT.name = "mapRectangle"
        //mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.8)
        
        /**The following  objects are the parent for all rendering objects, class positioning attributers are applied in order for objects to render the same independent of the screen size, In the case of containerNode it's positioning is set  based on its parent
         timerBackgroundTwo. The reason for not giving containerNode class positioning was due when class attributes were applied to containerNode it would render different in devices with smaller screen size(maybe something im not aware about, or a glitch of some kind).*/
        //containerNode.zPosition = -1
        containerNode.setScale(1.10) // Scaled down to give margin from rectangle edges(same as AlphabeticGameScene)
        containerNode.position = CGPoint(x:-237, y:-331) // Americas portrait map position inside the rectangle(same as AlphabeticGameScene)
        //containerNode.position = CGPoint(x:-280, y:-190)//CGPoint(x:self.size.width/2 - 285, y:self.size.height/2 - 175) /*CGPoint(x:-275 , y:-75 /*15*/)*//**Sknode containing(children) map sprites, desecheo cover(node whose only job is to hid desecheo island, rectangular frames)*/
        containerNode.name = "containerNode"
        //timerBackgroundTwo.position = CGPoint(x:self.size.width / 2/*333.5*/, y:self.size.height / 6)/**parent to labelTimer*/
        
        controlPanelSKSpriteNode.zPosition = 1//Set to one in order for the map to zoom and remain behind
        //controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height: 50)
        controlPanelSKSpriteNode.size = CGSize(width:self.size.width - 1, height:55)//same as AlphabeticGameScene, device functions resize it afterwards
        controlPanelSKSpriteNode.name = "controlPanelSKSpriteNode"
        //controlPanelSKSpriteNode.position = CGPoint(x:self.size.width / 2, y:self.size.height / 16.5/*25*/)
        
        //getFirstRandomMunicipioNameToLookUp()//moved below as getFirstRandomCountryNameToLookUp(), it must run after the device function sets countriesNameBGScale
        //getFirstRandomMunicipioNameToLookUp()//Function gets first random municipio name and overwrites text attributes from TestClass().labelForMunicipioNames()(base attributes)
        //randomIndex = Int.random(in:0...77)//gets random index for first municipio name to look up
        //countryNameLabel.text = municipios_names_array[randomIndex]//first municipio name to look up
        //countryNameLabel = labelForMunicipioNamesRandomGame(NameMunicipioLabel: countryNameLabel)
        
        //The following block reads device screen size in points, based on screen size a function will execute to asign scaling and positioning attributes
        debugPrint("Screen size: \(screenSize)")
        //Same device branching as AlphabeticGameScene: one dynamic function for all iPads and one for all iPhones
        if UIDevice.current.userInterfaceIdiom == .pad {
            debugPrint("iPad detected — universal dynamic rendering")
            setScaleAndIndepRenderingPositioningForAllIpads()
        } else {
            debugPrint("All iPhones — universal rendering via fixed scene size (375x667)")
            setScaleAndIndepRenderingPositioningForAllIphones()
        }
        /*// Old PR per-screen-size switch - kept for reference
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
        }*/

        /*// Old PR map background(added to self, sized from the gesture node)
        mapRectangleBackground.size = mapRectangleGestureMGMT.size
        mapRectangleBackground.position = mapRectangleGestureMGMT.position
        mapRectangleBackground.name = "mapRectangleBackground"*/
        // Map background setup(same as AlphabeticGameScene): blue, child of mapRectangleGestureMGMT so it zooms/pans with the map
        // Remove texture so .size controls dimensions directly
        mapRectangleBackground.texture = nil
        mapRectangleBackground.color = UIColor.init(red: 0.2588, green: 0.7608, blue: 1.0, alpha: 1.0)
        mapRectangleBackground.colorBlendFactor = 1.0
        mapRectangleBackground.xScale = 1.0
        mapRectangleBackground.yScale = 1.0
        // Sized so the gesture node's yellow stroke shows as a visible border around the background
        mapRectangleBackground.size = CGSize(width: 385.0, height: 575.0)
        mapRectangleBackground.position = CGPoint.zero
        mapRectangleBackground.name = "mapRectangleBackground"

        self.addChild(backgroundNode)
        //self.addChild(mapRectangleBackground)
        /**Following objects are related to goldBackground SKSPriteNode*/
        //Attention the following two statements were commented due municipioNamesBackground and countryNameLabel are added at getFirstRandomMunicipioNameToLookUp()
        //addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: countryNameLabel)
        //addChildSKSpriteNodeToParentSKSpriteNode(parent: goldBackgroundSKSpriteNode, children: municipiosNameBackground)
        //addChildSKLabelNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: labelScores)//labelScores is now added to self by the device functions(next to the timer)
        getFirstRandomCountryNameToLookUp()//picks first random country, adds countryNameLabel/countriesNameBackground to the control panel and sizes the background
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: skipButton)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: exitRedButton)
        addChildSKSpriteNodeToParentself(children: controlPanelSKSpriteNode)
        addChildSKSpriteNodeToParentSKSpriteNode(parent:mapRectangleGestureMGMT, children:mapRectangleBackground)
        addChildSKNodeToParentSKSpriteNode(parent:mapRectangleGestureMGMT, children:containerNode)
        //containerSKSPriteNode.addChild(containerNode)
        addChildSKSpriteNodeToParentself(children:mapRectangleGestureMGMT)
        //self.addChild(containerSKSPriteNode)
        //addChildSKNodeToParentself(children: containerNode)
        //addChildSKNodeToParentSKSpriteNode(parent: timerBackgroundTwo, children: containerNode)
        addChildSKLabelNodeToParentSKSpriteNode(parent: timerBackgroundTwo, children: labelTimer)
        addChildSKSpriteNodeToParentself(children: timerBackgroundTwo)
        
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
        
        // Show tutorial if needed(commented out during development, tutorial is addressed at the end - same as AlphabeticGameScene)
        // if TutorialManager.shouldShowTutorial() {
        //             showTutorial()
        // }
        
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
    
    /*// OLD PR per-device layout functions(fixed screen sizes, landscape) - replaced by the two dynamic functions below, copied from AlphabeticGameScene
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
    */

    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForAllIpads(){
        debugPrint("iPad Air 11inch(M2 18.6), iPad Air 11inch(M3 18.6), iPad Pro 11inch(1st-4th gen 18.6), iPad 11 inch(M4 18.6), iPad Air(3rd gen 18.6), iPad Air(4th-5th gen 18.6), iPad(7th-9th gen 18.6), Ipad 10th Gen(18.6), iPad A16(11 Gen 18.6), iPad Pro 10.5 enters scaling and positioning function")

        // Dynamic map positioning — same approach as iPhone function
        let mapWidth: CGFloat = 390.0
        let mapHeight: CGFloat = 580.0
        let topMargin: CGFloat = 50.0
        let bottomMargin: CGFloat = 20.0  // clears home indicator zone on modern iPads
        let horizontalMargin: CGFloat = 36.0
        let gap: CGFloat = 4.0  // tiny gap between stacked elements

        // Control panel sizing — lifted above home indicator
        let panelHeight: CGFloat = 70.0
        controlPanelSKSpriteNode.size = CGSize(width: self.size.width - (horizontalMargin * 2), height: panelHeight)
        controlPanelSKSpriteNode.position = CGPoint(x: self.size.width / 2, y: bottomMargin + (panelHeight / 2))  // 20 + 35 = 55
        let controlPanelTopY = controlPanelSKSpriteNode.position.y + (controlPanelSKSpriteNode.size.height / 2)  // = 70

        // Timer sits just above control panel with a gap
        timerBackgroundTwo.setScale(2.00)
        let timerHalfHeight: CGFloat = (17.0 * 2.00) / 2.0  // base height 17 × scale 2.0, halved
        let timerCenterY = controlPanelTopY + gap + timerHalfHeight - 2.5  // sits on top of panel, lowered 2.5pt
        timerBackgroundTwo.position = CGPoint(x: self.size.width / 2, y: timerCenterY)
        let timerTopY = timerCenterY + timerHalfHeight

        // Golden rectangle sits just above timer with a gap
        let mapBottomY = timerTopY + gap
        let availableWidth = self.size.width - (horizontalMargin * 2)
        let availableHeight = self.size.height - mapBottomY - topMargin
        let scaleX = availableWidth / mapWidth
        let scaleY = availableHeight / mapHeight
        let mapScale = min(scaleX, scaleY)
        let centerX = self.size.width / 2
        let centerY = mapBottomY + (mapScale * mapHeight / 2) + 2.0  // position so bottom edge aligns, nudged 2.0pt up
        mapRectangleGestureMGMT.position = CGPoint(x: centerX, y: centerY)
        mapRectangleGestureMGMT.setScale(mapScale)

        baseMapScale = mapScale
        baseMapPosition = CGPoint(x: centerX, y: centerY)
        maxZoomScale = mapScale * 5.0

        let goldenRectWidth = mapRectangleGestureMGMT.size.width
        debugPrint("iPad Medium — goldenRectWidth: \(goldenRectWidth), mapScale: \(mapScale), gestureNode.size: \(mapRectangleGestureMGMT.size)")
        // Resize control panel width to match golden rect
        controlPanelSKSpriteNode.size = CGSize(width: goldenRectWidth, height: 70)

        exitRedButton.setScale(1.90)  // was 1.60 — slightly larger for taller panel
        exitRedButton.position = CGPoint(x: -230, y: 0)

        skipButton.setScale(1.90)  // was 1.60 — matches exit button
        skipButton.position = CGPoint(x: 230, y: 0)

        countriesNameBGScale = 1.50  // restored original
        countriesNameBackground.position = CGPoint(x: 0, y: 0)

        labelScores.fontSize = 24  // scaled up for iPad
        // Place above Saltar button (skipButton is at x: +230 relative to controlPanel center)
        let skipButtonX = controlPanelSKSpriteNode.position.x + 230
        labelScores.position = CGPoint(x: skipButtonX, y: timerCenterY - 11)
        labelScores.zPosition = 1
        if labelScores.parent == nil {
            self.addChild(labelScores)
        }

        // Cover Hawaii islands with a blue rectangle matching the scene background
        // Added as child of mapRectangleGestureMGMT so it zooms/pans with the map
        let goldenRectLeftEdge = centerX - (goldenRectWidth / 2)
        let coverWidth = goldenRectLeftEdge  // fills from screen left to golden rect edge
        // Convert scene-space size to map-node-space by dividing by mapScale (the parent's scale)
        let hawaiiCover = SKSpriteNode(color: UIColor(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0), size: CGSize(width: coverWidth / mapScale, height: 55))
        hawaiiCover.anchorPoint = CGPoint(x: 0, y: 0.5)  // anchor at left edge
        // Convert scene position to map node's local coordinates
        let scenePos = CGPoint(x: 0, y: centerY + (30 * mapScale))
        let localPos = mapRectangleGestureMGMT.convert(scenePos, from: self)
        hawaiiCover.position = localPos
        hawaiiCover.zPosition = 2  // above the map
        hawaiiCover.name = "hawaiiCover"
        if mapRectangleGestureMGMT.childNode(withName: "hawaiiCover") == nil {
            mapRectangleGestureMGMT.addChild(hawaiiCover)
        }
    }
    //Execute attributes for scaling and positioning based on device screen size
    func setScaleAndIndepRenderingPositioningForAllIphones(){
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
        labelScores.fontSize = 17
        labelScores.position = CGPoint(x: self.size.width - 60, y: timerCenterY - 7)
        labelScores.zPosition = 1
        self.addChild(labelScores)

        // Cover Hawaii islands — only visible on smallest iPhones (750x1334)
        // Added as child of mapRectangleGestureMGMT so it zooms/pans with the map
        let goldenRectLeftEdge = centerX - (mapRectangleGestureMGMT.size.width / 2)
        let coverWidth = goldenRectLeftEdge
        // Convert scene-space size to map-node-space by dividing by mapScale (the parent's scale)
        let hawaiiCover = SKSpriteNode(color: UIColor(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0), size: CGSize(width: coverWidth / mapScale, height: 55))
        hawaiiCover.anchorPoint = CGPoint(x: 0, y: 0.5)
        // Convert scene position to map node's local coordinates
        let scenePos = CGPoint(x: 0, y: centerY + (30 * mapScale))
        let localPos = mapRectangleGestureMGMT.convert(scenePos, from: self)
        hawaiiCover.position = localPos
        hawaiiCover.zPosition = 2
        hawaiiCover.name = "hawaiiCover"
        if mapRectangleGestureMGMT.childNode(withName: "hawaiiCover") == nil {
            mapRectangleGestureMGMT.addChild(hawaiiCover)
        }
    }

    // Commented out — replaced by dynamic handlePan below, copied from AlphabeticGameScene(uses baseMapScale/baseMapPosition/maxZoomScale)
    /*
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
    */

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        // Don't allow pan during tutorial
            if tutorialOverlay != nil {
                return
            }
        
        // Pan boundaries in scene coordinates, expanding with zoom level.
        // Uses (zoomRatio - 1) so at base zoom (no zoom) there's zero pan range,
        // and boundaries grow proportionally as the user zooms in — allowing them
        // to reach map edges (Greenland top, Argentina bottom) without the map
        // ever disappearing off screen.
        // Multipliers are branched by device idiom so iPad and iPhone can be tuned independently.
        let zoomRatio = mapRectangleGestureMGMT.xScale / baseMapScale
        let panFactor = max(0, zoomRatio - 1)
        let halfWidth = self.size.width / 2
        let halfHeight = self.size.height / 2
        let horizontalMultiplier: CGFloat
        let verticalMultiplier: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            horizontalMultiplier = 0.7
            verticalMultiplier = 0.45
        } else {
            horizontalMultiplier = 0.7
            verticalMultiplier = 0.45
        }
        let minX = baseMapPosition.x - panFactor * halfWidth * horizontalMultiplier
        let maxX = baseMapPosition.x + panFactor * halfWidth * horizontalMultiplier
        let minY = baseMapPosition.y - panFactor * halfHeight * verticalMultiplier
        let maxY = baseMapPosition.y + panFactor * halfHeight * verticalMultiplier

        //Flag variable allows pan only when zoom in have taken place
        if isScaled == true {
            let translation = gesture.translation(in: gesture.view)

            // Apply translation first, then clamp to boundaries
            // (old code clamped before translating, so position could escape bounds)
            let newX = max(minX, min(maxX, mapRectangleGestureMGMT.position.x + translation.x))
            let newY = max(minY, min(maxY, mapRectangleGestureMGMT.position.y - translation.y))

            mapRectangleGestureMGMT.position = CGPoint(x: newX, y: newY)
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

                /**Control panel has priority over the map. When the map is zoomed, country nodes can sit underneath the panel and physicsWorld.body(at:) may return the
                 country instead of the button, so taps inside the panel are resolved here and never reach the map nodes below(same as AlphabeticGameScene)*/
                if controlPanelSKSpriteNode.contains(location) {
                    let locationInPanel = controlPanelSKSpriteNode.convert(location, from: self)//buttons are children of the panel, contains() expects parent coordinates
                    if skipButton.parent != nil && skipButton.contains(locationInPanel) {//skipButton is removed from the panel when one country is left
                        addOneTocurrentIndexSetNameToLookUp()
                    }
                    else if exitRedButton.contains(locationInPanel) {
                        goToStartMenu()
                    }
                    return//taps on the rest of the panel are ignored(no penalty)
                }

                /**Timer and score label also render above the zoomed map, taps on them are ignored so they don't reach the country nodes underneath(no penalty).
                 Both are children of self, so location(scene coordinates) can be tested directly*/
                if timerBackgroundTwo.contains(location) || (labelScores.parent != nil && labelScores.frame.contains(location)) {
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
                        /**set new municipio to look after*/
                        setNewCountryNameToLookUp()
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
                
                
                
                
                else if (touchedNode == nil){
                  
                    debugPrint("inside touchesNode == nil")
                    
                    
                    
                    
                   /* if controlPanelSKSpriteNode.contains(location) {
                            
                                return
                            }*/
           
                    //let touchLocation = sender.location(in: sender.view)
                    //let location = self.convertPoint(fromView: touchLocation)

                    //Get all nodes at the touch location
                    
                    let touchedNodes = self.nodes(at: location)
                    
                    
                    
                    //let touchedNode = self.atPoint(location) // Get the node at the touch location

                    // Check if the touched node is an SKSpriteNode and if it matches the municipio name
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
                        debugPrint("end")
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
              
              var touchLocation: CGPoint = sender.location(in: sender.view)//convert UIView coordinates to SpriteKit
              touchLocation = self.convertPoint(fromView: touchLocation)//Defines the space where touch is taking effect, in this case StartScene
              let touchedNode = self.physicsWorld.body(at:touchLocation)//Defines that touch will take effect when it gets in contact with an SKphysics body
              
              if (touchedNode != nil){//This line controls the flow by evaluating if a SKphysics body was touch or not, touchNode will return nil when the screen is touched but no SKphysics body was touched
                  if (countryNameLabel.text == touchedNode?.node?.name){//Evaluates touch by matching the label text attribute with node's name attributes
                      let spritenode = touchedNode?.node as! SKSpriteNode//pass touchedNode node attribute to spritenode, to apply changes
                      spritenode.physicsBody = nil
                      playCorrectSound()
                      setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                      paintNode(spriteNode: spritenode)//color SKSpriteNode green
                      /**Set labels and add them to map texture(node)*/
                      //setLabelForCountryNameAndAddToNode(nodeSprite: spritenode)
                      /**Element identified is removed from names array, Evaluates for game complition and removal of Skip button*/
                      removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval()
                      /**set new municipio to look after*/
                      setNewCountryNameToLookUp()
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
    
    // Commented out — replaced by dynamic handlePinchFrom below, copied from AlphabeticGameScene(uses baseMapScale/baseMapPosition/maxZoomScale)
    /*
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
    */

    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        
        // Don't allow pinch during tutorial
        if tutorialOverlay != nil {
                return
            }
        
        
        // iPad dynamic zoom clamping — uses baseMapScale/maxZoomScale set by setScaleAndIndepRenderingPositioningForAllIpads()
        // Emulates the same dynamic approach used by iPhones, branched by device idiom to keep settings isolated
        if UIDevice.current.userInterfaceIdiom == .pad {
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
            debugPrint("iPad dynamic scaling: base=\(baseMapScale), max=\(maxZoomScale)")
        }

        // Commented out — iPad zoom now uses dynamic baseMapScale/maxZoomScale above
        /*//The following block limits the scaling(Zoom effect) from 2.4(default size) and no larger than 3.0 for devices Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5)
        if screenSize.width == 2048.0 && screenSize.height == 2732.0{
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
        else if screenSize.width == 1668.0 && screenSize.height == 2224.0  || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 ||  screenSize.width == 1668.0 && screenSize.height == 2420.0{
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
            debugPrint("iPad Air 11inch(M2 18.6) etc scaling is limited")
        }
        else if screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0 {
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
        }*/
        
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
            // iPad dynamic isScaled check — uses baseMapScale set by setScaleAndIndepRenderingPositioningForAllIpads()
            if UIDevice.current.userInterfaceIdiom == .pad {
                if mapRectangleGestureMGMT.xScale > baseMapScale && mapRectangleGestureMGMT.yScale > baseMapScale {
                    isScaled = true
                    debugPrint("iPad dynamic isScaled check: base=\(baseMapScale) — iPad is scaled")
                }
            }

            // Commented out — iPad isScaled now uses dynamic baseMapScale above
            /*//Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5)
            if screenSize.width == 2048.0 && screenSize.height == 2732.0{
                if mapRectangleGestureMGMT.xScale > 2.4 && mapRectangleGestureMGMT.yScale > 2.4 {
                    isScaled = true
                    debugPrint("Pro12.9 3gen(18.5), Pro12.9 4gen(18.5), Pro12.9 5gen(18.5), Pro12.9 6gen(18.5), iPad Air 13inch(6th gen M2, M3)  is scaled")
                }
            }
            else if screenSize.width == 1668.0 && screenSize.height == 2224.0 || screenSize.width == 1668.0 && screenSize.height == 2388.0 || screenSize.width == 1620.0 && screenSize.height == 2160.0 || screenSize.width == 1640.0 && screenSize.height == 2360.0 || screenSize.width == 1668.0 && screenSize.height == 2420.0 {
                if mapRectangleGestureMGMT.xScale > 2.1 && mapRectangleGestureMGMT.yScale > 2.1{
                    isScaled = true
                    debugPrint("iPad Air 11inch(M2 18.6) etc is scaled")
                }
            }
            else if screenSize.width == 1536.0 && screenSize.height == 2048.0 || screenSize.width == 1488.0 && screenSize.height == 2266.0  {
                if mapRectangleGestureMGMT.xScale > 1.85 && mapRectangleGestureMGMT.yScale > 1.85{
                    isScaled = true
                    debugPrint("iPad 6Gen, iPad Mini(5gen 18.6), iPad Mini(6gen 18.6), iPad Mini(A17Pro 18.6) is scaled")
                }
            }*/
            
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

            // iPad dynamic snap-back — uses baseMapScale/baseMapPosition set by setScaleAndIndepRenderingPositioningForAllIpads()
            if UIDevice.current.userInterfaceIdiom == .pad {
                if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = baseMapPosition
                    debugPrint("iPad dynamic snap-back: base=\(baseMapScale) — back to original position")
                }
            }
            // iPhone snap-back — dynamic, uses baseMapScale/baseMapPosition set by setScaleAndIndepRenderingPositioningForAllIphones()
            else {
                if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = baseMapPosition
                    debugPrint("iPhone dynamic snap-back: base=\(baseMapScale) — back to original position")
                }
            }

            // Commented out — iPad and iPhone snap-back now both use dynamic baseMapScale/baseMapPosition above
            /*switch (screenSize.width, screenSize.height) {
                case (2048.0, 2732.0):
                     if abs(mapRectangleGestureMGMT.xScale - 2.4) < tolerance && abs(mapRectangleGestureMGMT.yScale - 2.4) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00)
                        debugPrint("Pro12.9 etc is back to original position")
                    }
            case (1668.0, 2224.0), (1668.0,2388.0), (1620.0, 2160.0), (1640.0, 2360.0), (1668.0, 2420.0):
                if abs(mapRectangleGestureMGMT.xScale - 2.1) < tolerance && abs(mapRectangleGestureMGMT.yScale - 2.1) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00)
                    debugPrint("iPad Air 11inch(M2 18.6) etc is back to original position")
                    }
            case (1536.0, 2048.0), (1488.0, 2266.0):
                if abs(mapRectangleGestureMGMT.xScale - 1.85) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.85) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 2.00)
                    debugPrint("iPad 6Gen, iPad Mini etc back to original position")
                }
            case (750.0, 1334.0), (1080.0, 2340.0),(1125.0, 2436.0), (1242.0, 2208.0), (828.0, 1792.0), (1242.0, 2688.0), (1170.0, 2532.0), (1179.0, 2556.0), (1284.0, 2778.0), (1290.0, 2796.0), (1206.0, 2622.0), (1320.0, 2868.0):
                    if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                        isScaled = false
                        mapRectangleGestureMGMT.position = baseMapPosition
                        debugPrint("iPhone dynamic snap-back")
                    }
                default:
                    if abs(mapRectangleGestureMGMT.xScale - baseMapScale) < tolerance && abs(mapRectangleGestureMGMT.yScale - baseMapScale) < tolerance {
                    isScaled = false
                    mapRectangleGestureMGMT.position = baseMapPosition
                        debugPrint("Default dynamic snap-back")
                    }
                    break
            }*/

        }
    }
      
      /*@objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
          
          //Constraints for limiting the scaling  of the node
          if mapRectangleGestureMGMT.xScale * sender.scale < 1.0 {
              sender.scale = 1.0 / mapRectangleGestureMGMT.xScale
          } else if mapRectangleGestureMGMT.xScale * sender.scale > 1.7 {
              sender.scale = 1.7 / mapRectangleGestureMGMT.xScale
          }

          if mapRectangleGestureMGMT.yScale * sender.scale < 1.0 {
              sender.scale = 1.0 / mapRectangleGestureMGMT.yScale
          } else if mapRectangleGestureMGMT.yScale * sender.scale > 1.7 {
              sender.scale = 1.7 / mapRectangleGestureMGMT.yScale
          }
          
          //Set scaling action
          let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
          mapRectangleGestureMGMT.run(pinch)
          sender.scale = 1.0
          
          //Asses if the node is scaled or not(scaled to default size)
          if sender.state == .ended{
          
              if mapRectangleGestureMGMT.xScale > 1.0 && mapRectangleGestureMGMT.yScale > 1.0 {
                  isScaled = true
                  debugPrint("scaled bigger")
              }
              let tolerance: CGFloat = 0.001

              if abs(mapRectangleGestureMGMT.xScale - 1.0) < tolerance && abs(mapRectangleGestureMGMT.yScale - 1.0) < tolerance {
                  isScaled = false
                  mapRectangleGestureMGMT.position = CGPoint(x:self.size.width / 2, y:self.size.height / 1.8)//Whenever node is scaled back to default size the node is repositioned at default position or center
                  debugPrint("scaled back to normal")
              }
          }
      }*/
    
    /*// OLD PR first random municipio(4 fixed backgrounds + per-name switch) - replaced by getFirstRandomCountryNameToLookUp below
    func getFirstRandomMunicipioNameToLookUp(){

        //setNewCountryNameToLookUp()
        // FOR TESTING ONLY - REMOVE AFTER
        //randomIndex = municipios_names_array.firstIndex(of: "Trujillo Alto") ?? 0
         randomIndex = Int.random(in:0...77)
        //randomIndex = Int.random(in:0...77)//gets random index for first municipio name to look up
        countryNameLabel.text = municipios_names_array[randomIndex]//first municipio name to look up
        
        switch(countryNameLabel.text){
            case "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande" :
                scaleMunicipioNameBackgroundTwoForScreenSizes()
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
            
            case "Barceloneta", "Canóvanas", "Juana Díaz", "Las Marías", "Las Piedras", "Rio Grande", "San Germán", "San Lorenzo", "Santa Isabel", "Barranquitas", "Quebradillas":
                scaleMunicipioNameBackgroundFourForScreenSizes()
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundFour, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundFour)
            
            case  "Cabo Rojo", "Bayamón", "Guayanilla", "Guaynabo", "Guayama", "Humacao", "Mayagüez", "Maunabo", "Naguabo", "Peñuelas", "San Juan", "Vega Alta", "Vega Baja", "Naranjito", "Orocovis", "Trujillo Alto":
                scaleMunicipioNameBackgroundThreeForScreenSizes()
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundThree, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundThree)
            
        default:
            
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            break
        }
        
        
    }
    */

    /**Picks the first random country name to look up, adds the label/background to the control panel and sizes the background to fit the name.
     Called from didMove after the device function, so countriesNameBGScale is already set when resizeCountryNameBackground() runs*/
    func getFirstRandomCountryNameToLookUp(){
        // FOR TESTING ONLY - REMOVE AFTER
        //randomIndex = countries_names_array.firstIndex(of: "Dominican Republic") ?? 0
        randomIndex = Int.random(in:0...countries_names_array.count - 1)//gets random index for first country name to look up
        countryNameLabel.fontSize = 20 // Reset to default before measuring
        countryNameLabel.text = countries_names_array[randomIndex]//first country name to look up
        addChildSKLabelNodeToParentSKSpriteNode(parent: countriesNameBackground, children: countryNameLabel)
        addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: countriesNameBackground)
        resizeCountryNameBackground()
    }
    
    func addChildSKNodeToParentself(children:SKNode){
        if children.parent == nil{
        self.addChild(children)
        }
    }
    
    func addChildSKLabelNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKLabelNode){
        if children.parent == nil{
        parent.addChild(children)
        }
    }
    
    func addChildSKSpriteNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKSpriteNode){
        if children.parent == nil{
        parent.addChild(children)
        }
    }

    func addChildSKSpriteNodeToParentself(children:SKSpriteNode){
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
    //Claude suggested for memory leaks mitigation
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
            self?.isTutorialActive = false
            self?.tutorialOverlay = nil
        }
        
        // Set skip callback
        tutorialOverlay?.onSkip = { [weak self] in
            debugPrint("Tutorial skipped")
            self?.isTutorialActive = false
            self?.tutorialOverlay = nil
        }
        
        // Show the tutorial
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
        
       if RandomGameScene.completedGame == false{//Control variable to keep the timer running, once condition is true the timer is stopped
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
                    //UserDefaults.standard.removeObject(forKey: "secondsRandom")
                    //UserDefaults.standard.removeObject(forKey: "minutesRandom")
                }
                
                renderTime = currentTime + changeTime//updates renderTime value, when this happens renderTime value is bigger than currentTime
            }
            
        }
        /** This block  will execute when completedGame equals true(meaning all nodes were correctly identified), the function below will get gameOverScene. The reason to place here the game transition to gameOverScene is due Touch function needs "space" in order to perform without much lagging as scene transitioning and
         Touch function both require a lot of resouces that can compromise the flow of the game(so basically thats why the scene transition is not placed on Touch function)*/
        
        if RandomGameScene.completedGame == true{
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
        // AdManager.shared.removeBanner()
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.5)
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    
    
    func getSecondsAndMinutes(){
        RandomGameScene.secondsGameOver = seconds
        RandomGameScene.minutesGameOver = minutes
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
                /**set new municipio to look after*/
                setNewCountryNameToLookUp()
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
    
    

    /*// OLD PR paintNode - only colored the node itself, not its children
    func paintNode(spriteNode:SKSpriteNode){
        spriteNode.color = UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)
        spriteNode.colorBlendFactor = 1.0
        //spriteNode.physicsBody = nil
    }*/
    //same as AlphabeticGameScene
    func paintNode(spriteNode:SKSpriteNode){
        let greenColor = UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)
        spriteNode.colorBlendFactor = 0.8
        spriteNode.color = greenColor
        //spriteNode.physicsBody = nil
        // If the node has children (e.g. Lesser Antilles Arc), color them all green too
        for child in spriteNode.children {
            if let childSprite = child as? SKSpriteNode {
                childSprite.colorBlendFactor = 0.8
                childSprite.color = greenColor
            }
        }
    }
    
    func playCorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(/*StartScene.*/correctSound)//correctSound
        }
    }
    
    //following function sets labels for country names and adds them to the map node(country map node) once it is identified
    //Labels live in InitSetMapNodes so all game scenes and GameOverScene draw the same labels(same as AlphabeticGameScene)
    func setLabelForCountryNameAndAddToNode(nodeSprite:SKSpriteNode){
        InitSetMapNodes().addCountryNameLabel(to: nodeSprite)
    }

    /*// OLD PR municipio labels(big white labels) - replaced by shared InitSetMapNodes.addCountryNameLabel above, kept for reference
    //following function sets labels for municio names using one or two labels and adds labels to map node(municipio map node)
   func setLabelForMunicipioNameAndAddToNode(nodeSprite:SKSpriteNode){
          
          let locationNameLabel = SKLabelNode()/**Label serves two uses, first it's the display label on map for short named municipios but also is use to pass its text Attributes to function splitTextIntoFields*/
          let firstLineLabel = SKLabelNode()//First label for long named municipio names(ex. Aguas Buenas)
          let secondLineLabel = SKLabelNode()//Second label for long named municipio names(ex Aguas Buenas)
          locationNameLabel.text = countryNameLabel.text//Text atribute is pass to locationNameLabel to be used by one word municipios(except for Las Piedras and Las Marias) same
          
          /**The switch statement allows to set the label(that identifies each municipio in the map) with attributes necessary to acamodate text, set positioning and other attributes  exclusive to a group of nodes or individual nodes  */
          /**The execution will enter the case that corresponds with the String value of countryNameLabel.text*/
          switch countryNameLabel.text {
              
          case "Maricao", "Moca", "Arecibo", "Coamo", "Yabucoa" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
             locationNameLabel.horizontalAlignmentMode = .center
             locationNameLabel.verticalAlignmentMode = .center
              
          case "Lares":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.5
              locationNameLabel.position = CGPoint(x: -1.5, y: -3.0)
              
          case "Yauco":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 7.0
              locationNameLabel.position = CGPoint(x: -0.6, y: 0.5)
              
          case "Aibonito":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 7.0
              locationNameLabel.position = CGPoint(x: -0.5, y: -2.5)
              
          case "Utuado", "Lajas":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
              locationNameLabel.position = CGPoint(x: 0.5, y: 1.5)
              
          case "Salinas":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
              locationNameLabel.position = CGPoint(x: -3.0, y: -2.5)
              
              
          case "Ponce":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
              locationNameLabel.position = CGPoint(x: 0.0, y: -6.5)

              
          case "Orocovis":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
              locationNameLabel.position = CGPoint(x: 3.5, y: -5.5)
              
          case "Jayuya" :
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.position = CGPoint(x: 1.0, y: -10.0)
              
          case "Adjuntas":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.position = CGPoint(x: 0.0, y: -3.5)
              
          case "Villalba":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.position = CGPoint(x: -0.6, y: -4.0)
              
          case "Morovis" :
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.2
              locationNameLabel.position = CGPoint(x: 0.7, y: -3.5)
              
          case "Aguada":
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 6.3//4.7
               locationNameLabel.position = CGPoint(x: 0.3, y: -5.0)
              
          case "Caguas":
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 6.3//4.7
               locationNameLabel.position = CGPoint(x: 1.5, y: -5.0)
              
          case "Maunabo":
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 5.9//4.7
               locationNameLabel.position = CGPoint(x: 4.1, y: -5.5)
              
          case  "Cidra":
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 6.5//4.7
               locationNameLabel.position = CGPoint(x: 3.0, y: -5.5)
              
          case "Culebra" :
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.position = CGPoint(x: 5.0, y: -2.0)
              
          case "Añasco" :
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 6.8
               locationNameLabel.position = CGPoint(x: 3.5, y: -1.0)
             
          case "Camuy":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.0
             locationNameLabel.position = CGPoint(x: -2.5, y: -3.5)
              
          case "Comerío":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.3
             locationNameLabel.position = CGPoint(x: -0.5, y: -3.5)
              
          case "Naguabo":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.0
              locationNameLabel.position = CGPoint(x: 0.0, y: -5.5)
              
          case "Aguadilla":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.6
              locationNameLabel.position = CGPoint(x: -1.0, y: 3.0)
              
         case "Juncos":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.0
             locationNameLabel.position = CGPoint(x: -3.0, y: 1.5)
              
              
         case "Manatí":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.4
              locationNameLabel.position = CGPoint(x: 2.5, y: 0.5)
              
          case "Vieques":
               setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
               locationNameLabel.fontSize = 6.9
               locationNameLabel.position = CGPoint(x: -2.5, y: -1.0)
              
              
         case "Toa Alta":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.5
             locationNameLabel.position = CGPoint(x: 2.0, y: -2.0)
              
              
          case "Las Marías":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.5
              locationNameLabel.position = CGPoint(x: 3.0, y: -4.5)
              

         case "Cayey":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.position = CGPoint(x: -8.5, y: -5.0)

             
         case "Luquillo":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.1
             locationNameLabel.position = CGPoint(x: -0.5, y: 2.0)
             //locationNameLabel.zPosition = 1
              
          case "Guánica":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.3
              locationNameLabel.position = CGPoint(x: 1.5, y: -2.0)
              
          case "Gurabo":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.0
              locationNameLabel.position = CGPoint(x: 2.0, y: 1.5)
         

              
         case "Isabela":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.8
             locationNameLabel.position = CGPoint(x: 1.5, y: -2.5)
              
         case "Corozal":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.7
             locationNameLabel.position = CGPoint(x: -0.5, y: -3.0)

             
         case "Hormigueros":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 4.0
              locationNameLabel.zRotation = -0.55
             locationNameLabel.position = CGPoint(x: -1.5, y: -2.5)
      
          
         case "Patillas" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 7.3
              locationNameLabel.zRotation = -0.85
             locationNameLabel.position = CGPoint(x: -6.0, y: -5.0)
              
         case "Rincón" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.8
              locationNameLabel.zRotation = -1.0
              locationNameLabel.position = CGPoint(x: -5.5, y: -1.0)
              
        case "Arroyo" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.8
             locationNameLabel.zRotation = -1.1
             locationNameLabel.position = CGPoint(x: -3.0, y: -1.0)
              
        case "Canóvanas" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.9
             locationNameLabel.zRotation = -1.43
             locationNameLabel.position = CGPoint(x: -4.5, y: -1.0)

             
         case "Mayagüez":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.7
              locationNameLabel.position = CGPoint(x: 2.5, y: -4.5)

             
         case "Carolina":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.9
              locationNameLabel.zRotation = -1.1
              locationNameLabel.position = CGPoint(x: 3.0, y: 0.5)
              
         case "Quebradillas":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 5.9
             locationNameLabel.zRotation = -1.3
             locationNameLabel.position = CGPoint(x: -0.5, y: 1.5)
              
         case "Peñuelas":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.8
             locationNameLabel.zRotation = -1.0
             locationNameLabel.position = CGPoint(x: -2.8, y: 0.5)
              
         case "Hatillo":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 8.0
             locationNameLabel.zRotation = -1.0
             locationNameLabel.position = CGPoint(x: -1.5, y: -2.5)

             
         case "Guayanilla" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 5.8
             locationNameLabel.position = CGPoint(x: 2.7, y:-12.5)
             locationNameLabel.zRotation = 0.5
         
         case "Guaynabo":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.1
              locationNameLabel.zRotation = 1.3
             locationNameLabel.position = CGPoint(x: 2.0, y: -9.0)

         case  "Barceloneta":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 5.3
             locationNameLabel.zRotation = 1.15
             locationNameLabel.position = CGPoint(x: 0.5, y: 0.5)
             
         case "Dorado":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.6
              locationNameLabel.zRotation = -1.0
             locationNameLabel.position = CGPoint(x: -8.0, y: -2.5)
              
        case  "Bayamón":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.5
             locationNameLabel.zRotation = 1.1
             locationNameLabel.position = CGPoint(x: 1.5, y: 0.5)

             
         case "Florida" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.3
              locationNameLabel.zRotation = 1.1
             locationNameLabel.position = CGPoint(x: 2.0, y: -2.0)

             
         case  "Ciales":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.position = CGPoint(x: 5.5, y: 0.5)
              
         case  "Ceiba" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.5
             locationNameLabel.position = CGPoint(x: 6.0, y: -3.0)

             
             
         case "Naranjito" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 6.6
             locationNameLabel.zRotation = 0.9
             locationNameLabel.position = CGPoint(x: 3.0, y: -3.0)
              
              
          case "Las Piedras":
              setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.8
              locationNameLabel.zRotation = 1.02
              locationNameLabel.position = CGPoint(x: 3.0, y: -3.0)
              
              
         case "Humacao" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 6.6
              locationNameLabel.zRotation = 0.51
              locationNameLabel.position = CGPoint(x: -1.0, y:1.5)
              
        case "Barranquitas" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 5.71
             locationNameLabel.zRotation = 0.65
             locationNameLabel.position = CGPoint(x: -1.5, y: -0.5)
       

             
         case "Cataño":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
              locationNameLabel.fontSize = 5.0//4.0
             locationNameLabel.zRotation = 0.4
             locationNameLabel.position = CGPoint(x: 0.5, y: -3.0)

             
         case "Loíza" :
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 7.5
             //locationNameLabel.zRotation = 6.18
             //locationNameLabel.xScale = 1.0
              locationNameLabel.position = CGPoint(x: 5.0, y: -1.0)

             
         case "Fajardo":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 7.0
             locationNameLabel.position = CGPoint(x: -6.5, y: -11.0)

             
         case "Guayama":
             setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 7.5
             locationNameLabel.position = CGPoint(x: -2.0, y: -10.0)

         
              
          case "Aguas Buenas" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)//Attributes are set for label
              firstLineLabel.fontSize = 6.4
              secondLineLabel.fontSize = 6.4
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)//adds first part of text attribute(ex.Aguas)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)//adds second part of text attribute(ex.Buenas)
              firstLineLabel.position = CGPoint(x:-0.5, y:1.0)
              secondLineLabel.position = CGPoint(x:0.5, y:-5.0)
              
          case "Rio Grande", "San Sebastián" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)//Attributes are set for label
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)//adds first part of text attribute(ex.Aguas)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)//adds second part of text attribute(ex.Buenas)
              secondLineLabel.position = CGPoint(x:-0.5, y:-6.0)
              
          case "San Germán" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)//Attributes are set for label
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)//adds first part of text attribute(ex.Aguas)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)//adds second part of text attribute(ex.Buenas)
              firstLineLabel.position = CGPoint(x:1.5, y:-0.5)
              secondLineLabel.position = CGPoint(x:0.5, y:-7.5)
          
              
          case "Cabo Rojo" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:0.5, y:3.0)
              secondLineLabel.position = CGPoint(x:0.5, y:-4.2)
              
          case "Vega Baja" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:0.5, y:3.0)
              secondLineLabel.position = CGPoint(x:0.6, y:-4.5)
              
              
          case "Santa Isabel" :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:1.5, y:3.0)
              secondLineLabel.position = CGPoint(x:1.5, y:-3.0)
              
              
          case "San Juan"  :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:0.5, y:5.0)
              secondLineLabel.position = CGPoint(x:0.5, y:-1.5)
              
              
          case "Juana Díaz"  :
              setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
              firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
              secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:2.5, y:-6.5)
              secondLineLabel.position = CGPoint(x:2.5, y:-14.0)

             
         case "Sabana Grande" :
             setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
             firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
             secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
             firstLineLabel.fontSize = 6.2
             secondLineLabel.fontSize = 6.2
             firstLineLabel.position = CGPoint(x:-2.0, y:-9.5)//CGPoint(x:-4.0, y:-1.5)
             secondLineLabel.position = CGPoint(x:-1.0, y:-15.0)//CGPoint(x:-4.5, y:-7.0)

             
         case "Vega Alta":
             setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
             firstLineLabel.fontSize = 6.0
             secondLineLabel.fontSize = 6.0
             firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
             secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
             firstLineLabel.position = CGPoint(x:2.7, y:0.5)
             secondLineLabel.position = CGPoint(x:1.2, y:-6.0)

             
         case "Toa Baja":
             setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
             firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
             secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
             firstLineLabel.position = CGPoint(x:-7.5, y:-1.5)
             secondLineLabel.position = CGPoint(x:-7.0, y:-7.5)
             

             
         case "Trujillo Alto" :
             setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
             firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
             secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
             firstLineLabel.fontSize = 6.5
             secondLineLabel.fontSize = 6.5
             firstLineLabel.position = CGPoint(x:-3.5, y:-2.5)
             secondLineLabel.position = CGPoint(x:-4.5, y:-8.5)

             
         case "San Lorenzo"  :
             setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
             firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
             secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
              firstLineLabel.position = CGPoint(x:3.5, y:0.5)
              secondLineLabel.position = CGPoint(x:3.0, y:-5.0)
                  
              /*case "Adjuntas", "Aguada", "Añasco", "Lajas", "Maricao", "Las Marías", "Moca", "Yauco", "Guánica", "Lares", "Arecibo", "Utuado", "Ponce", "Jayuya",
                  "Manatí", "Coamo", "Orocovis", "Villalba", "Comerío", "Toa Alta", "Caguas", "Cidra", "Salinas", "Culebra", "Naguabo", "Yabucoa" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)//Attributes are set for label
                 locationNameLabel.horizontalAlignmentMode = .center
                 locationNameLabel.verticalAlignmentMode = .center
                 
             case "Camuy", "Aguadilla", "Juncos":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.0
                 locationNameLabel.position = CGPoint(x: -2.0, y: 0.0)

             case "Cayey":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.position = CGPoint(x: -6.5, y: 3.0)

                 
             case "Isabela", "Corozal", "Morovis", "Aibonito", "Gurabo", "Luquillo":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.0
                 locationNameLabel.position = CGPoint(x: 0.5, y: 0.5)
                 //locationNameLabel.zPosition = 1

                 
             case "Hormigueros":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
             locationNameLabel.fontSize = 3.9
                 locationNameLabel.zRotation = 10.0
                 locationNameLabel.position = CGPoint(x: -0.5, y: 2.5)
          
              case "Maunabo" :
                  setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                  locationNameLabel.fontSize = 4.5
                  locationNameLabel.zRotation = 10.0
             locationNameLabel.position = CGPoint(x: -1.5/*-0.5*/, y: 2.5)

                 
             case "Rincón", "Canóvanas", "Arroyo", "Patillas" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.0
                 locationNameLabel.zRotation = 10.5
                 locationNameLabel.position = CGPoint(x: -4.5, y: 1.0)

                 
             case "Mayagüez":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.4
                 locationNameLabel.position = CGPoint(x: 42.0, y: 21.5)

                 
             case "Quebradillas", "Hatillo", "Peñuelas", "Carolina":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.5
                 locationNameLabel.zRotation = 10.8
                 locationNameLabel.position = CGPoint(x: 1.5, y: -1.2)

                 
             case "Guayanilla" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.5
                 locationNameLabel.position = CGPoint(x: 2.5, y:12.5)
                 locationNameLabel.zRotation = 9.0
             
             case "Guaynabo":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.0
                 locationNameLabel.zRotation = 1.6
                 locationNameLabel.position = CGPoint(x: 0.5, y: -1.2)

             case  "Barceloneta":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 4.5
                 locationNameLabel.zRotation = 1.9
                 locationNameLabel.position = CGPoint(x: 0.5, y: -2.2)
                 
             case  /*"Barceloneta",*/ "Bayamón", "Dorado"/*, "Guaynabo"*/:
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 5.1
                 locationNameLabel.zRotation = 1.9
                 locationNameLabel.position = CGPoint(x: 0.5, y: -1.2)

                 
             case "Florida" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 4.5
                 locationNameLabel.position = CGPoint(x: 0.5, y: 0.5)

                 
             case  "Ciales", "Ceiba" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.position = CGPoint(x: 5.5, y: 0.5)

                 
                 
             case "Naranjito", "Barranquitas", "Las Piedras", "Humacao" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 4.5
                 locationNameLabel.zRotation = 2.3
                 locationNameLabel.position = CGPoint(x: 3.5, y: 1.0)

                 
             case "Cataño":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 3.6//4.0
                 locationNameLabel.position = CGPoint(x: 0.5, y: 1.5)

                 
             case "Loíza" :
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.fontSize = 7.5
                 locationNameLabel.zRotation = 6.18
                 locationNameLabel.xScale = 1.0
                 locationNameLabel.position = CGPoint(x: 10.0, y: 0.5)

                 
             case "Fajardo":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.position = CGPoint(x: -5.7, y: 8.5)

                 
             case "Guayama":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.position = CGPoint(x: 0.5, y: 6.5)

                 
             case "Vieques":
                 setOneLineMunicipioNameLabel(Oneline:locationNameLabel)
                 locationNameLabel.position = CGPoint(x: -40.5, y: -8.5)

                    
                 
             case "Cabo Rojo", "San Germán", "San Sebastián", "Juana Díaz", "Vega Baja", "San Juan", "Santa Isabel", "Aguas Buenas", "Rio Grande" :
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)//Attributes are set for label
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)//adds first part of text attribute(ex.Aguas)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)//adds second part of text attribute(ex.Buenas)
                 secondLineLabel.verticalAlignmentMode = .top

                 
             case "Sabana Grande" :
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
                 firstLineLabel.fontSize = 5.0
                 secondLineLabel.fontSize = 5.0
                 firstLineLabel.position = CGPoint(x:-4.0, y:5.5)
                 secondLineLabel.position = CGPoint(x:-3.5, y:13.0)

                 
             case "Vega Alta":
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
                 firstLineLabel.position = CGPoint(x:2, y:0.5)
                 secondLineLabel.verticalAlignmentMode = .top

                 
             case "Toa Baja":
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
                 firstLineLabel.horizontalAlignmentMode = .right
                 secondLineLabel.verticalAlignmentMode = .top
                 secondLineLabel.horizontalAlignmentMode = .right

                 
             case "Trujillo Alto" :
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
                 firstLineLabel.fontSize = 5.5
                 secondLineLabel.fontSize = 5.5
                 firstLineLabel.position = CGPoint(x:-4.0, y:0.5)
                 secondLineLabel.position = CGPoint(x:-3.5, y:6.5)

                 
             case "San Lorenzo"  :
                 setTwoLineMunicipioNameLabels(labelLineFirst:firstLineLabel, labelLineSecond:secondLineLabel)
                 firstLineLabel.text = splitTextIntoFields(theText:locationNameLabel.text!)
                 secondLineLabel.text = splitTextIntoFieldsTwo(theText:locationNameLabel.text!)
                 secondLineLabel.position = CGPoint(x:4.5, y:6.0)*/

                  
                      default:
                          break
          }
          if(useLine2 == true){
            nodeSprite.addChild(firstLineLabel)//adds label to map node
            nodeSprite.addChild(secondLineLabel)//adds label to map node
            useLine2 = false
          }
              
          else{
            nodeSprite.addChild(locationNameLabel)//adds label to map node
          }
      }
    */
    
    //sets attributes for label to use with one word municipio names
    func setOneLineMunicipioNameLabel(Oneline:SKLabelNode){
        //Oneline.text = countryNameLabel.text
        Oneline.fontName = "ArialMT"//"Helvetica"
        Oneline.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
        //Oneline.xScale = -1.0
        //Oneline.zRotation = 9.44
        Oneline.fontSize = 6.8//5.4
    }
    //sets attributes for labels to use with two word municipio names
    func setTwoLineMunicipioNameLabels(labelLineFirst:SKLabelNode, labelLineSecond:SKLabelNode){
        
        labelLineFirst.fontName = "ArialMT"//"Helvetica"
        labelLineSecond.fontName = "ArialMT"//"Helvetica"
        labelLineFirst.fontSize = 6.9//5.4
        labelLineSecond.fontSize = 6.9//5.4
        labelLineFirst.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
        labelLineSecond.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
        //labelLineFirst.xScale = -1.0
        //labelLineSecond.xScale = -1.0
        //labelLineFirst.zRotation = 9.44
        //labelLineSecond.zRotation = 9.44
    }
    
    func removeIdentifiedElementEvaluateCompleteGameAndSkipButtonRemoval(){
        let countOfIndexes = countries_names_array.count - 1//Gets the number of indexes in array
        
        //If condition is true means that two elemens are left in array, it removes skipButton due second to last(penultimo elemento) element is about to be removed next
        if countOfIndexes == 1  {
            //debugPrint("skip button out")
            skipButton.removeFromParent()
        }

        //removes element while more than 1 element are left in array
        if countOfIndexes > 0 {
            countries_names_array.remove(at:randomIndex)//removes element identified that is at index(remember taht this variable updates in the following block))
            
        }
        
        //CLAUDE ELSE STATEMENT TO OPTIMIZE GAME TO GAMEOVERSCENE TRANSITION
        else{
            getSecondsAndMinutes()//gets seconds and minutes to be used for time record function at gameOverScene
            // Use an action to delay setting completedGame, allowing the correct sound to play
            let waitAction = SKAction.wait(forDuration: 0.00001)
            let completeAction = SKAction.run {
            RandomGameScene.completedGame = true
            }
            self.run(SKAction.sequence([waitAction, completeAction]))
        }
        //ORIGINAL ELSE STATEMENT
        //Este else statement va a ejecutar solo cuando currentIndex y countIndex == 0
        /*else{
            //self.removeAllActions()//It catches the last correctSound in order for transition to gameOverScene to flow smoother with less laggin
            getSecondsAndMinutes()
            RandomGameScene.completedGame = true//Se actualiza la variable completedGame para detener el reloj
            

        }*/
    }
    
    
    /*// OLD PR random municipio name box(4 fixed backgrounds + per-name switch + per-device scaling) - replaced by dynamic countriesNameBackground below, copied from AlphabeticGameScene
    func setNewMunicipioNameToLookUp(){
        let countOfIndexes = municipios_names_array.count - 1
        //debugPrint(countOfIndexes)
        //loop keeps next skipped municipio name from repeating, meaning any time you press skip it will return a different municipio, and not the same one.
        if pressSKipButton == true{
            //debugPrint("inside while")
            repeat{
                randomIndex = Int.random(in:0...countOfIndexes)
            }
            while countryNameLabel.text == municipios_names_array[randomIndex] && countOfIndexes != 0
        }
        
        else{
            randomIndex = Int.random(in:0...countOfIndexes)
        }
        
        countryNameLabel.text = municipios_names_array [randomIndex] //Writes to label the next municipio name to be located by player
       //Switch reveals the name of the next municipio to look out for
        switch(countryNameLabel.text){
            //This block manage the longest two word names
            case "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande" ://This municipio names will use municipiosNameBackgroundTwo
                //Removes current background to add municipiosNameBackgroundTwo to the scene if its not already present on the scene
                if municipiosNameBackgroundTwo.parent == nil{// Checks if municipiosNameBackgroundTwo is already in the scene, if municipioNameBackgroundTwo is already on the scene the following block is ignored
                    switch(countryNameLabel.parent?.name){//returns the background currently in use that is not municipiosNameBackgroundTwo and that needs to be removed in order to add municipiosNameBackgroundTwo to fit "Aguas Buenas", "Hormigueros", "San Sebastián", "Sabana Grande"
                        
                        case "MunicipiosNameBackground"://Background to be removed in order for municipiosNameBackgroundTwo to be added
                            countryNameLabel.removeFromParent()//countryNameLabel is removed in order to be added(as child) to municipiosNameBackgroundTwo
                            municipiosNameBackground.removeFromParent()//If municipiosNameBackground.parent != nil true municipiosNameBackgroundis removed to put in its place municipiosNameBackgroundTwo
                            scaleMunicipioNameBackgroundTwoForScreenSizes()//scaling for municipiosNameBackgroundTwo is set according to screen size
                        
                        case "MunicipiosNameBackgroundThree":
                            countryNameLabel.removeFromParent()
                            municipiosNameBackgroundThree.removeFromParent()
                            scaleMunicipioNameBackgroundTwoForScreenSizes()
                            
                        case "MunicipiosNameBackgroundFour":
                            countryNameLabel.removeFromParent()
                            municipiosNameBackgroundFour.removeFromParent()
                            scaleMunicipioNameBackgroundTwoForScreenSizes()
                            
                            
                        default:
                           
                        break
                        
                    }
                    addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: countryNameLabel)
                    addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
                }
        
            //Block manages short two words municipio names and longer one word names(CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
        case "Barceloneta", "Canóvanas", "Juana Díaz", "Las Marías", "Las Piedras", "Rio Grande", "San Germán", "San Lorenzo", "Santa Isabel", "Barranquitas", "Quebradillas"://This municipio names will use municipiosNameBackgroundFour
            if municipiosNameBackgroundFour.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "MunicipiosNameBackground":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackground.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    case "MunicipiosNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    case "MunicipiosNameBackgroundThree":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundThree.removeFromParent()
                        scaleMunicipioNameBackgroundFourForScreenSizes()
                    
                    default:
                    break
            }
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundFour, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundFour)
        }
            //Block manages long single words and short two words municipio names(CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
        case  "Cabo Rojo", "Bayamón", "Guayanilla", "Guaynabo", "Guayama", "Humacao", "Mayagüez", "Maunabo", "Naguabo", "Peñuelas", "San Juan", "Vega Alta", "Vega Baja", "Naranjito", "Orocovis", "Trujillo Alto"://This municipio names will use municipiosNameBackgroundThree
            if municipiosNameBackgroundThree.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "MunicipiosNameBackground":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackground.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    case "MunicipiosNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    case "MunicipiosNameBackgroundFour":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundFour.removeFromParent()
                        scaleMunicipioNameBackgroundThreeForScreenSizes()
                        
                    default:
                        break
                }
                
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundThree, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundThree)
            }
            
            //Following block receive most municipio names(shorter ones)This municipio names will use municipiosNameBackground (CHECK COMMENTS ON FIRST BLOCK OF THE SWITCH CASE AS THEY FOLLOW THE SAME LOGIC)
          default:
            if municipiosNameBackground.parent == nil{
                switch(countryNameLabel.parent?.name){
                    case "MunicipiosNameBackgroundTwo":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundTwo.removeFromParent()
                    
                    case "MunicipiosNameBackgroundThree":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundThree.removeFromParent()
                    
                    case "MunicipiosNameBackgroundFour":
                        countryNameLabel.removeFromParent()
                        municipiosNameBackgroundFour.removeFromParent()
                    
                    default:
                   
                    break
                    
                }
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            }
           
            break
        }
        
        /*countryNameLabel.text = municipios_names_array[randomIndex]//Se desplega el nuevo municipio a ser localizado por el jugador
        if countryNameLabel.text == "Aguas Buenas" || countryNameLabel.text == "Barceloneta" || countryNameLabel.text == "Barranquitas" || countryNameLabel.text == "Cabo Rojo"
        || countryNameLabel.text == "Canóvanas" || countryNameLabel.text == "Guayanilla" || countryNameLabel.text == "Guaynabo" || countryNameLabel.text == "Hormigueros"
        || countryNameLabel.text == "Juana Díaz" || countryNameLabel.text == "Las Marías" || countryNameLabel.text == "Las Piedras" || countryNameLabel.text == "Mayagüez"
        || countryNameLabel.text == "Quebradillas" || countryNameLabel.text == "Rio Grande" || countryNameLabel.text == "Sabana Grande" || countryNameLabel.text == "San Germán"
        || countryNameLabel.text == "San Lorenzo" || countryNameLabel.text == "San Sebastián" || countryNameLabel.text == "Santa Isabel" || countryNameLabel.text == "Trujillo Alto"{
            if municipiosNameBackgroundTwo.parent == nil{
                countryNameLabel.removeFromParent()
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
                addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: countryNameLabel)
                addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
            }
            /*if municipiosNameBackgroundTwo.parent == nil{
            countryNameLabel.removeFromParent()
            municipiosNameBackground.removeFromParent()
            addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackgroundTwo, children: countryNameLabel)
            addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackgroundTwo)
            }*/
            //if else municipiosNameBackgroundTwo.parent
        }
        else {
            if municipiosNameBackground.parent == nil{
            countryNameLabel.removeFromParent()
            municipiosNameBackgroundTwo.removeFromParent()
            addChildSKLabelNodeToParentSKSpriteNode(parent: municipiosNameBackground, children: countryNameLabel)
            addChildSKSpriteNodeToParentSKSpriteNode(parent: controlPanelSKSpriteNode, children: municipiosNameBackground)
            }
        }*/
    }
    
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
    */

    /**following function picks the next random country name to look up and adjusts the background size for the label(countryNameLabel) */
    func setNewCountryNameToLookUp(){
        let countOfIndexes = countries_names_array.count - 1
        //loop keeps next skipped country name from repeating, meaning any time you press skip it will return a different country, and not the same one.
        if pressSKipButton == true{
            repeat{
                randomIndex = Int.random(in:0...countOfIndexes)
            }
            while countryNameLabel.text == countries_names_array[randomIndex] && countOfIndexes != 0
        }
        else{
            randomIndex = Int.random(in:0...countOfIndexes)
        }
        countryNameLabel.fontSize = 20 // Reset to default before measuring
        countryNameLabel.text = countries_names_array [randomIndex] //Writes to label the next country name to be located by player
        resizeCountryNameBackground()
    }

    /// Dynamically resizes countriesNameBackground to fit the current countryNameLabel text with rounded corners and border.
    /// Auto-shrinks the font if the name is too long to fit between the Salir/Saltar buttons.
    func resizeCountryNameBackground(){
        // Reset scale before measuring so frame calculations are accurate
        countriesNameBackground.setScale(1.0)
        //let isIPad = countriesNameBGScale > 1.10
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad//device check instead of inferring from countriesNameBGScale(same idiom check used by didMove, handlePan and handlePinchFrom)
        let horizontalPadding: CGFloat = 36.0
        let bgHeight: CGFloat = isIPad ? 20.0 * (countriesNameBGScale / 1.10) : 30.0
        let bgScale: CGFloat = 1.10
        // iPhone buttons at ±110, iPad buttons at ±230 — different max widths
        let maxVisualWidth: CGFloat = isIPad ? 139.0 * (countriesNameBGScale / 1.10) * 1.4 : 139.0
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

        //let textureView = SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        //Reuse the scene's own SKView to render the texture, a throwaway SKView is only created as fallback if the scene has no view yet
        let textureView = self.view ?? SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        if let texture = textureView.texture(from: shapeNode) {
            countriesNameBackground.texture = texture
            countriesNameBackground.size = texture.size()
            countriesNameBackground.setScale(countriesNameBGScale)
        }
    }
    
    //function updates the label rendering the number of municipios identified already at the bottom right of screen
    func addToScoreCountWriteToLabel(){
        scoreCount += 1
        labelScores.text = "\(scoreCount)" + totalScoreCount//totalScoreCount es un constant string solo sirve al rendering del score
    }
    
    func addOneTocurrentIndexSetNameToLookUp(){
        //skipButton.alpha = 0.9//efecto para skipButton al presionarlo, esta linea es solo una prueba y debo al menos sujetarlo a una condicion en el futuro como un if
        //skipButtonPressed = true
        pressSKipButton = true
        setNewCountryNameToLookUp()
        //debugPrint("Skip Button touched")
    }
    
    func goToStartMenu(){
        musicPlayer?.stop()
        // AdManager.shared.removeBanner()
        let startMenuScene = StartMenuScene(size: self.size)
        self.view?.presentScene(startMenuScene)
    }
 
    func playIncorrectSound(){
        if StartMenuScene.gamePlaySoundOn == true{
            run(/*StartScene.*/incorrectSound)
        }
    }
    
 //function detects when the touch on screen have ended in order to complete alpha effect that started at addOneTocurrentIndexSetNameToLookUp()
   /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       //Efecto para el skipButton cuando se suelta el boton
       if skipButtonPressed == true{
           skipButton.alpha = 1.0//Ojo esto se veria mejor dentro de un if sin embargo  si utilizo una condicion como if skipButton.alpha == 1.0 causa un glitch, pero puedo hacer una condicion con una variable boolean
           skipButtonPressed = false
       }
       //Exit button does not have alpha effect as it goes out of view when pressed
   }*/
    
    //Las dos proximas funciones son identicas con la diferencia de que devuelven cada una por su parte una variable diferente
    func splitTextIntoFields(theText:String)->String{
        useLine2 = false//Esta linea resetea la variable que es necesario para no crear redundancia cuando se pasa el texto a label(ej:aguas aguas buenas)
        twoLineText = theText//texto que necesitamos dividir en dos lineas
        //var i: Int = 0
        var line1:String = ""//declaracion de las variables que se van a devolver
        var line2:String = ""
            
            
        for letter in twoLineText{//Cada letra contenida en el String es desglosada por el for loop
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
        useLine2 = false
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
    

}
