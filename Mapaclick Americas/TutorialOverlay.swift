//
//  TutorialOverlay.swift
//  mapaclick
//
//  Tutorial overlay system with spotlight effects
//

import Foundation
import SpriteKit

class TutorialOverlay {
    
    // MARK: - Shared SKView for texture generation
        private static let textureGeneratorView: SKView = {
            let view = SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            return view
        }()
    
    // Tutorial steps
    enum TutorialStep {
        case tapRegion
        case skipButton
        case timer
        case gestures
        case complete
    }
    
    // References to scene elements
    private weak var scene: SKScene?
    private var currentStep: TutorialStep = .tapRegion
    
    // Overlay elements
    private var overlayNode: SKNode!
    private var dimLayer: SKShapeNode!
    private var spotlightHole: SKShapeNode!
    private var instructionLabel: SKLabelNode!
    // Screen size detection
    private let isLargeiPad: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return screenSize.width == 2048.0 && screenSize.height == 2732.0
    }()
    
    private let isSmallMediPad: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 1536.0 && screenSize.height == 2048.0) ||
               (screenSize.width == 1488.0 && screenSize.height == 2266.0)
    }()
    
    private let isMediumiPad: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 1640.0 && screenSize.height == 2360.0) ||
               (screenSize.width == 1668.0 && screenSize.height == 2224.0) ||
               (screenSize.width == 1668.0 && screenSize.height == 2388.0) ||
               (screenSize.width == 1620.0 && screenSize.height == 2160.0) ||
               (screenSize.width == 1668.0 && screenSize.height == 2420.0)
    }()
    
    private let isSmallPhone: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 750.0 && screenSize.height == 1334.0) ||
               (screenSize.width == 1080.0 && screenSize.height == 2340.0) ||
               (screenSize.width == 1125.0 && screenSize.height == 2436.0)
    }()
    
    private let isMediumPhone: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 828.0 && screenSize.height == 1792.0) ||
               (screenSize.width == 1242.0 && screenSize.height == 2688.0) ||
               (screenSize.width == 1242.0 && screenSize.height == 2208.0)
    }()
    
    private let isLargePhone: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 1170.0 && screenSize.height == 2532.0) ||
               (screenSize.width == 1179.0 && screenSize.height == 2556.0)
    }()
    private let isXLargePhone: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 1284.0 && screenSize.height == 2778.0) ||
               (screenSize.width == 1290.0 && screenSize.height == 2796.0)
    }()
    private let isProPhone: Bool = {
        let screenSize = UIScreen.main.nativeBounds
        return (screenSize.width == 1206.0 && screenSize.height == 2622.0)
    }()
    
    private var instructionBackground: SKSpriteNode!
    private var nextButton: SKSpriteNode!
    private var nextButtonLabel: SKLabelNode!
    private var skipTutorialButton: SKSpriteNode!
    private var skipTutorialLabel: SKLabelNode!
    private var tempTimerLabel: SKLabelNode?
    
    // References to game elements
    private var mapRectangle: SKNode?
    private var skipButton: SKNode?
    private var timerBackground: SKNode?
    private var controlPanel: SKNode?
    private var municipioNameBackground: SKNode?
    // Callbacks
    var onComplete: (() -> Void)?
    var onSkip: (() -> Void)?
    
    // Practice mode flag (to customize text)
    private var isPracticeMode: Bool = false
    
    init(scene: SKScene, isPracticeMode: Bool = false) {
        self.scene = scene
        self.isPracticeMode = isPracticeMode
    }
    
    /// Show the tutorial overlay
    func show() {
        guard let scene = scene else { return }
        
        // Find game elements
        findGameElements()
        
        // Create overlay container
        overlayNode = SKNode()
        overlayNode.zPosition = 1000 // Very high to be above everything
        overlayNode.name = "tutorialOverlay"
        
        // Create dim layer (semi-transparent background)
        createDimLayer()
        
        // Create instruction panel
        createInstructionPanel()
        
        // Create buttons
        createButtons()
        
        // Add overlay to scene
        scene.addChild(overlayNode)
        
        // Show first step
        showStep(.tapRegion)
    }
    
    /// Find references to game elements in the scene
    private func findGameElements() {
        guard let scene = scene else { return }
        
        mapRectangle = scene.childNode(withName: "mapRectangle")
        skipButton = scene.childNode(withName: "//skipButton")
        controlPanel = scene.childNode(withName: "//controlPanelSKSpriteNode")
        
        // Find timer - it's a direct child of scene
        timerBackground = scene.children.first(where: { node in
            if let sprite = node as? SKSpriteNode {
                // timerBackgroundTwo is an SKSpriteNode with a label child
                return sprite.children.contains(where: { $0 is SKLabelNode })
                    && sprite != controlPanel
                    && sprite.position.y < scene.size.height * 0.3
            }
            return false
        })
        
        // If not found, try by searching all nodes
        if timerBackground == nil {
            scene.enumerateChildNodes(withName: "//*") { node, _ in
                if node.name == "timerBackgroundTwo" ||
                   (node is SKSpriteNode && node.children.contains(where: { ($0 as? SKLabelNode)?.fontName == "Arial" })) {
                    self.timerBackground = node
                }
            }
        }
        
        // Find municipio name background (it's inside control panel)
        municipioNameBackground = controlPanel?.childNode(withName: "//MunicipiosNameBackground") ??
                                  controlPanel?.childNode(withName: "//MunicipiosNameBackgroundTwo") ??
                                  controlPanel?.childNode(withName: "//MunicipiosNameBackgroundThree") ??
                                  controlPanel?.childNode(withName: "//MunicipiosNameBackgroundFour")
        
        // Debug prints - AFTER the searches
        debugPrint("Timer found: \(String(describing: timerBackground))")
        debugPrint("Control panel found: \(String(describing: controlPanel?.name))")
        debugPrint("MunicipioNameBackground found: \(String(describing: municipioNameBackground?.name))")
    }
    
    /// Create semi-transparent dim layer with spotlight hole
    private func createDimLayer() {
        guard let scene = scene else { return }
        
        // Create full-screen dim layer
        let dimPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height))
        
        dimLayer = SKShapeNode(path: dimPath.cgPath)
        dimLayer.fillColor = UIColor.black
        dimLayer.strokeColor = .clear
        dimLayer.alpha = 0.7
        dimLayer.zPosition = 1
        
        overlayNode.addChild(dimLayer)
        
        // Spotlight will be created per step
        spotlightHole = SKShapeNode()
        spotlightHole.zPosition = 2
        overlayNode.addChild(spotlightHole)
    }
    
    /// Create instruction panel with background
    private func createInstructionPanel() {
        guard let scene = scene else { return }
        
        // Background for instruction - narrower
        instructionBackground = createRoundedRectangle(
            width: scene.size.width * (isLargeiPad ? 0.75 : isMediumiPad ? 0.78 : isSmallMediPad ? 0.80 : isSmallPhone ? 0.965 : isLargePhone ? 0.95 : 0.82),
            height: isLargeiPad ? 75 : isMediumiPad ? 60 : isSmallMediPad ? 55 : isSmallPhone ? 38 : isMediumPhone ? 38 : isLargePhone ? 28 : isXLargePhone ? 35 : isProPhone ? 40 : 45,
            cornerRadius: 10
        )
        instructionBackground.position = CGPoint(x: scene.size.width / 2, y: scene.size.height * (isLargeiPad ? 0.95 : isSmallPhone ? 0.935 : isMediumPhone ? 0.945 : isLargePhone ? 0.95 : isXLargePhone ? 0.94 : isProPhone ? 0.94 : 0.928))
        instructionBackground.zPosition = 3
        overlayNode.addChild(instructionBackground)
        
        // Instruction text - bigger font
        instructionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        instructionLabel.fontSize = isLargeiPad ? 24 : isMediumiPad ? 20 : isSmallMediPad ? 18 : isLargePhone ? 12.4 : 14
        instructionLabel.fontColor = .white
        instructionLabel.numberOfLines = 2
        instructionLabel.preferredMaxLayoutWidth = scene.size.width * (isSmallPhone ? 0.58 : isLargePhone ? 0.75 : 0.45)
        instructionLabel.horizontalAlignmentMode = .left
        instructionLabel.verticalAlignmentMode = .center
        instructionLabel.position = CGPoint(x: -scene.size.width * (isSmallPhone ? 0.45 : isLargePhone ? 0.46 : 0.37), y: 0)
        instructionLabel.zPosition = 1
        instructionBackground.addChild(instructionLabel)
        
        // Add light blue border to panel
        let panelBorder = SKShapeNode(rectOf: CGSize(width: scene.size.width * (isLargeiPad ? 0.75 : isMediumiPad ? 0.78 : isSmallMediPad ? 0.80 : isSmallPhone ? 0.965 : isLargePhone ? 0.95 : 0.82), height: isLargeiPad ? 75 : isMediumiPad ? 60 : isSmallMediPad ? 55 : isSmallPhone ? 38 : isMediumPhone ? 38 : isLargePhone ? 28 : isXLargePhone ? 35 : isProPhone ? 40 : 45), cornerRadius: 10)
            panelBorder.strokeColor = UIColor(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)  // Light blue
            panelBorder.lineWidth = 2
            panelBorder.fillColor = .clear
            panelBorder.position = CGPoint(x: 0, y: 0)
            panelBorder.zPosition = 2
            instructionBackground.addChild(panelBorder)
    }
    
    /// Create Next and Skip buttons
    private func createButtons() {
        guard let scene = scene else { return }
        
        // Skip tutorial button - white border, white text (subtle/secondary)
        skipTutorialButton = createStyledButton(
            width: isLargeiPad ? 110 : isMediumiPad ? 95 : isSmallMediPad ? 90 : isLargePhone ? 65 : 75,
            height: isLargeiPad ? 45 : isMediumiPad ? 38 : isSmallMediPad ? 36 : isLargePhone ? 26 : 30,
            fillColor: UIColor(red: 0.2392, green: 0.698, blue: 1, alpha: 0.6),
            strokeColor: UIColor.white,
            lineWidth: 1.5
        )
        skipTutorialButton.position = CGPoint(x: scene.size.width * (isLargeiPad ? 0.20 : isSmallMediPad ? 0.23 : isSmallPhone ? 0.22 : 0.24), y: 0)
        skipTutorialButton.zPosition = 4
        skipTutorialButton.name = "tutorialSkipButton"
        instructionBackground.addChild(skipTutorialButton)
        
        skipTutorialLabel = SKLabelNode(fontNamed: "Helvetica")
        skipTutorialLabel.text = "Saltar"
        skipTutorialLabel.fontSize = isLargeiPad ? 20 : isMediumiPad ? 17 : isSmallMediPad ? 16 : 13
        skipTutorialLabel.fontColor = .white
        skipTutorialLabel.verticalAlignmentMode = .center
        skipTutorialLabel.position = CGPoint(x: 0, y: 0)
        skipTutorialLabel.zPosition = 1
        skipTutorialButton.addChild(skipTutorialLabel)
        
        // Next/Got it button - golden border with glow, golden text (primary)
        nextButton = createStyledButton(
            width: isLargeiPad ? 125 : isMediumiPad ? 105 : isSmallMediPad ? 100 : isLargePhone ? 75 : 85,
            height: isLargeiPad ? 45 : isMediumiPad ? 38 : isSmallMediPad ? 36 : isLargePhone ? 26 : 30,
            fillColor: UIColor(red: 0.2392, green: 0.698, blue: 1, alpha: 1.0),
            strokeColor: UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 1.0),
            lineWidth: 2.0
        )
        nextButton.position = CGPoint(x: scene.size.width * (isLargeiPad ? 0.32 : isSmallPhone ? 0.37 : 0.34), y: 0)
        nextButton.zPosition = 4
        nextButton.name = "tutorialNextButton"
        instructionBackground.addChild(nextButton)
        
        // Add glow effect to next button
        let glowNode = SKShapeNode(rectOf: CGSize(width: isLargeiPad ? 125 : isMediumiPad ? 105 : isSmallMediPad ? 100 : isLargePhone ? 75 : 85, height: isLargeiPad ? 45 : isMediumiPad ? 38 : isSmallMediPad ? 36 : isLargePhone ? 26 : 30), cornerRadius: 8)
        glowNode.strokeColor = UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 0.6)
        glowNode.lineWidth = 4
        glowNode.fillColor = .clear
        glowNode.glowWidth = 3
        glowNode.zPosition = -1
        nextButton.addChild(glowNode)
        
        nextButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        nextButtonLabel.text = "Siguiente"
        nextButtonLabel.fontSize = isLargeiPad ? 20 : isMediumiPad ? 17 : isSmallMediPad ? 16 : 13
        nextButtonLabel.fontColor = UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 1.0)  // Golden text
        nextButtonLabel.verticalAlignmentMode = .center
        nextButtonLabel.position = CGPoint(x: 0, y: 0)
        nextButtonLabel.zPosition = 1
        nextButton.addChild(nextButtonLabel)
    }
    
    /// Create rounded rectangle sprite node
    private func createRoundedRectangle(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> SKSpriteNode {
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.close()
        path = UIBezierPath(roundedRect: path.bounds, cornerRadius: cornerRadius)
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = UIColor(red: 0.2392, green: 0.698, blue: 1, alpha: 1.0)
        shapeNode.strokeColor = UIColor(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)
        shapeNode.lineWidth = 2.5
        
        let texture = TutorialOverlay.textureGeneratorView.texture(from: shapeNode)!
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.position = CGPoint(x: width / 2, y: height / 2)
        
        return spriteNode
    }
    
    /// Create styled button with custom colors
    private func createStyledButton(width: CGFloat, height: CGFloat, fillColor: UIColor, strokeColor: UIColor, lineWidth: CGFloat) -> SKSpriteNode {
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.close()
        path = UIBezierPath(roundedRect: path.bounds, cornerRadius: 8)
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = fillColor
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = lineWidth
        
        let texture = TutorialOverlay.textureGeneratorView.texture(from: shapeNode)!
        let spriteNode = SKSpriteNode(texture: texture)
        
        return spriteNode
    }
    
    /// Show specific tutorial step
    private func showStep(_ step: TutorialStep) {
        guard let scene = scene else { return }
        currentStep = step
        
        // Update spotlight and instruction based on step
        switch step {
        case .tapRegion:
            // Highlight both map and municipio name
            if let mapRect = mapRectangle, let nameHolder = municipioNameBackground {
                createCombinedSpotlight(nodes: [mapRect, nameHolder], padding: 20)
            } else if let mapRect = mapRectangle {
                // Fallback if name holder not found
                createSpotlight(around: mapRect, padding: 20)
            }
            var text = "Toca(Tap) la región del mapa para identificar el municipio mostrado abajo en el recuadro azul."
            if isPracticeMode {
                text = "Toca la región del mapa. En modo práctica, los nombres están visibles para ayudarte."
            }
            instructionLabel.text = text
            nextButtonLabel.text = "Siguiente"
            
        case .skipButton:
            // Remove temp label from previous step if exists
            tempTimerLabel?.removeFromParent()
            
            // Clear previous spotlights
            spotlightHole.removeAllChildren()
            
            // Highlight skip button with tight rectangular glow
            if let skip = skipButton {
                let skipPosition = scene.convert(skip.position, from: skip.parent ?? scene)
                debugPrint("timerBackground: \(String(describing: timerBackground))")
                // Create spotlight hole in dim layer
                let fullRect = CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height)
                let path = UIBezierPath(rect: fullRect)
                
                // Skip button spotlight - cover borders fully
                let horizontalPadding: CGFloat = isLargeiPad ? 24 : isMediumiPad ? 18 : isSmallMediPad ? 16 : isSmallPhone ? 4 : 10
                let verticalPadding: CGFloat = isLargeiPad ? 16 : isMediumiPad ? 12 : isSmallMediPad ? 10 : isSmallPhone ? 2 : 6
                let skipRect = CGRect(
                    x: skipPosition.x - skip.frame.width / 2 - horizontalPadding,
                    y: skipPosition.y - skip.frame.height / 2 - verticalPadding,
                    width: skip.frame.width + horizontalPadding * 2,
                    height: skip.frame.height + verticalPadding * 2
                )
                let skipPath = UIBezierPath(roundedRect: skipRect, cornerRadius: isLargeiPad ? 14 : isMediumiPad ? 12 : isSmallMediPad ? 12 : 10)
                path.append(skipPath)
                
                
                // Timer spotlight - orange glow
                if let timer = timerBackground {
                    let timerPosition = scene.convert(timer.position, from: timer.parent ?? scene)
                    let timerRect = CGRect(
                        x: timerPosition.x - timer.frame.width / 2,
                        y: timerPosition.y - timer.frame.height / 2,
                        width: timer.frame.width,
                        height: timer.frame.height
                    )
                    let timerPath = UIBezierPath(roundedRect: timerRect, cornerRadius: 8)
                    path.append(timerPath)
                    
                    // Orange glow for timer
                    let timerGlow = SKShapeNode(path: timerPath.cgPath)
                    timerGlow.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
                    timerGlow.lineWidth = 3  // THINNER from 4
                    timerGlow.fillColor = .clear
                    timerGlow.glowWidth = 2
                    spotlightHole.addChild(timerGlow)

                    // Pulse animation for timer
                    let timerPulse = SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.6, duration: 0.8),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                    ])
                    timerGlow.run(SKAction.repeatForever(timerPulse))
                    
                    // Add +15 label
                    tempTimerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
                    tempTimerLabel?.text = "+15"
                    tempTimerLabel?.fontSize = isLargeiPad ? 28 : isMediumiPad ? 24 : isSmallMediPad ? 22 : 17
                    tempTimerLabel?.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
                    tempTimerLabel?.verticalAlignmentMode = .center
                    tempTimerLabel?.horizontalAlignmentMode = .center
                    tempTimerLabel?.position = timerPosition
                    tempTimerLabel?.zPosition = 1001
                    scene.addChild(tempTimerLabel!)
                }
                
                path.usesEvenOddFillRule = true
                dimLayer.path = path.cgPath
                
                // Golden glow for skip button
                let skipGlow = SKShapeNode(path: skipPath.cgPath)
                skipGlow.strokeColor = UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 1.0)
                skipGlow.lineWidth = 4
                skipGlow.fillColor = .clear
                skipGlow.glowWidth = 2
                spotlightHole.addChild(skipGlow)
                
                // Pulse animation
                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: 0.8),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                ])
                skipGlow.run(SKAction.repeatForever(pulse))
            }
            
            instructionLabel.text = "Si no sabes dónde está, usa Saltar (Skip). Añade 15 segundos."
            nextButtonLabel.text = "Siguiente"
            
        case .timer:
            // Remove temp label from previous step
            tempTimerLabel?.removeFromParent()
            
            // Clear previous spotlights
            spotlightHole.removeAllChildren()
            
            if let timer = timerBackground {
                let timerPosition = scene.convert(timer.position, from: timer.parent ?? scene)
                
                // Create spotlight hole in dim layer
                let fullRect = CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height)
                let path = UIBezierPath(rect: fullRect)
                
                // Timer spotlight - tight fit
                let timerRect = CGRect(
                    x: timerPosition.x - timer.frame.width / 2,
                    y: timerPosition.y - timer.frame.height / 2,
                    width: timer.frame.width,
                    height: timer.frame.height
                )
                let timerPath = UIBezierPath(roundedRect: timerRect, cornerRadius: 8)
                path.append(timerPath)
                
                path.usesEvenOddFillRule = true
                dimLayer.path = path.cgPath
                
                // Golden glow for timer (main focus now)
                let timerGlow = SKShapeNode(path: timerPath.cgPath)
                timerGlow.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange
                timerGlow.lineWidth = 3
                timerGlow.fillColor = .clear
                timerGlow.glowWidth = 2
                spotlightHole.addChild(timerGlow)
                
                // Pulse animation for timer
                let timerPulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.6, duration: 0.8),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                ])
                timerGlow.run(SKAction.repeatForever(timerPulse))
                
                // Add +3 label
                tempTimerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
                tempTimerLabel?.text = "+3"
                tempTimerLabel?.fontSize = isLargeiPad ? 28 : isMediumiPad ? 24 : isSmallMediPad ? 22 : 17
                tempTimerLabel?.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange
                tempTimerLabel?.verticalAlignmentMode = .center
                tempTimerLabel?.horizontalAlignmentMode = .center
                tempTimerLabel?.position = timerPosition
                tempTimerLabel?.zPosition = 1001
                scene.addChild(tempTimerLabel!)
            }
            
            instructionLabel.text = "El cronómetro rastrea tu tiempo. Tocar incorrecto añade 3 segundos."
            nextButtonLabel.text = "Siguiente"
            
        case .gestures:
            // Remove temp label from previous step
            tempTimerLabel?.removeFromParent()
            
            // Hide skip button on last step (both buttons would do the same thing)
            skipTutorialButton.isHidden = true
            skipTutorialLabel.isHidden = true
            
            // Show general spotlight on map for gestures
            if let mapRect = mapRectangle {
                createSpotlight(around: mapRect, padding: 0)
            }
            instructionLabel.text = "Usa pellizcar (pinch) para acercar(zoom), y arrastra (pan) para mover."
            nextButtonLabel.text = "¡Entendido!"
            
        case .complete:
            // Clean up temp label
            tempTimerLabel?.removeFromParent()
            // Tutorial finished
            completeTutorial()
        }
    }
    
    /// Create spotlight effect around a node
    private func createSpotlight(around node: SKNode, padding: CGFloat) {
        guard let scene = scene else { return }
        
        // Convert node position to scene coordinates
        let nodePosition = scene.convert(node.position, from: node.parent ?? scene)
        
        // Get node's frame in scene coordinates
        var spotlightRect = node.frame
        spotlightRect.origin = CGPoint(
            x: nodePosition.x - spotlightRect.width / 2 - padding,
            y: nodePosition.y - spotlightRect.height / 2 - padding
        )
        spotlightRect.size = CGSize(
            width: spotlightRect.width + padding * 2,
            height: spotlightRect.height + padding * 2
        )
        
        // Create path with hole for spotlight
        let fullRect = CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height)
        let path = UIBezierPath(rect: fullRect)
        
        // Add rounded rectangle hole for spotlight
        let spotlightPath = UIBezierPath(roundedRect: spotlightRect, cornerRadius: 15)
        path.append(spotlightPath)
        path.usesEvenOddFillRule = true
        
        // Update dim layer
        dimLayer.path = path.cgPath
        //dimLayer.fillRule = .evenOdd
        
        // Create glowing border around spotlight
        spotlightHole.removeAllChildren()
        let glowNode = SKShapeNode(path: spotlightPath.cgPath)
        glowNode.strokeColor = UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 1.0)
        glowNode.lineWidth = 3
        glowNode.fillColor = .clear
        glowNode.glowWidth = 5
        spotlightHole.addChild(glowNode)
        
        // Pulse animation for spotlight
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(pulse))
    }
    
    /// Create spotlight effect around multiple nodes
    private func createCombinedSpotlight(nodes: [SKNode], padding: CGFloat) {
        guard let scene = scene else { return }
        
        // Create path with hole for spotlight
        let fullRect = CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height)
        let path = UIBezierPath(rect: fullRect)
        
        // Clear previous spotlight
        spotlightHole.removeAllChildren()
        
        // Add rounded rectangle hole for each node
        for (index, node) in nodes.enumerated() {
            // Convert node position to scene coordinates
            let nodePosition = scene.convert(node.position, from: node.parent ?? scene)
            
            // Get node's frame in scene coordinates
            var spotlightRect = node.frame
            
            // Adjust padding and cornerRadius based on which node this is
            let horizontalPadding: CGFloat
            let verticalPadding: CGFloat
            let cornerRadius: CGFloat
            
            if index == 0 {
                // Map rectangle - negative padding to overlap yellow border
                horizontalPadding = -2
                verticalPadding = -2
                cornerRadius = 15
            } else {
                // Municipio name holder - padding varies by background size
                if isLargeiPad {
                    // Check which background is being used
                    let backgroundName = municipioNameBackground?.name ?? ""
                    switch backgroundName {
                    case "MunicipiosNameBackgroundTwo":
                        horizontalPadding = 65  // Longest names - needs most padding
                    case "MunicipiosNameBackgroundThree":
                        horizontalPadding = 52  // Medium-long names
                    case "MunicipiosNameBackgroundFour":
                        horizontalPadding = 58  // Medium names
                    default:
                        horizontalPadding = 45  // Short names (MunicipiosNameBackground)
                    }
                    verticalPadding = 8
                    cornerRadius = 22
                } else if isMediumiPad {
                    let backgroundName = municipioNameBackground?.name ?? ""
                    switch backgroundName {
                    case "MunicipiosNameBackgroundTwo":
                        horizontalPadding = 48  // Longest names
                    case "MunicipiosNameBackgroundThree":
                        horizontalPadding = 38  // Medium-long names
                    case "MunicipiosNameBackgroundFour":
                        horizontalPadding = 42.5  // Medium names
                    default:
                        horizontalPadding = 32  // Short names
                    }
                    verticalPadding = 7
                    cornerRadius = 22
                } else if isSmallMediPad {
                    let backgroundName = municipioNameBackground?.name ?? ""
                    switch backgroundName {
                    case "MunicipiosNameBackgroundTwo":
                        horizontalPadding = 47.5  // Longest names
                    case "MunicipiosNameBackgroundThree":
                        horizontalPadding = 36  // Medium-long names
                    case "MunicipiosNameBackgroundFour":
                        horizontalPadding = 40  // Medium names
                    default:
                        horizontalPadding = 29  // Short names
                    }
                    verticalPadding = 6
                    cornerRadius = 22
                } else if isSmallPhone {
                    //debugPrint("Inside isSmallPhne")
                    horizontalPadding = 1
                    verticalPadding = 0
                    cornerRadius = 18
                } else {
                    horizontalPadding = 17
                    verticalPadding = 4
                    cornerRadius = 15
                }
            }
            
            spotlightRect.origin = CGPoint(
                x: nodePosition.x - spotlightRect.width / 2 - horizontalPadding,
                y: nodePosition.y - spotlightRect.height / 2 - verticalPadding
            )
            spotlightRect.size = CGSize(
                width: spotlightRect.width + horizontalPadding * 2,
                height: spotlightRect.height + verticalPadding * 2
            )
            
            // Add spotlight hole
            let spotlightPath = UIBezierPath(roundedRect: spotlightRect, cornerRadius: cornerRadius)
            path.append(spotlightPath)
            
            // Create glowing border around this spotlight
            let glowNode = SKShapeNode(path: spotlightPath.cgPath)
            glowNode.strokeColor = UIColor(red: 1, green: 0.8824, blue: 0.5804, alpha: 1.0)
            glowNode.lineWidth = 4
            glowNode.fillColor = .clear
            glowNode.glowWidth = 2
            spotlightHole.addChild(glowNode)
            
            // Pulse animation for spotlight
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ])
            glowNode.run(SKAction.repeatForever(pulse))
        }
        
        path.usesEvenOddFillRule = true
        
        // Update dim layer
        dimLayer.path = path.cgPath
    }
    
    /// Create secondary spotlight with custom color (for highlighting additional elements)
    private func addSecondarySpotlight(around node: SKNode, padding: CGFloat, color: UIColor) {
        guard let scene = scene else { return }
        
        // Convert node position to scene coordinates
        let nodePosition = scene.convert(node.position, from: node.parent ?? scene)
        
        // Get node's frame in scene coordinates
        var spotlightRect = node.frame
        spotlightRect.origin = CGPoint(
            x: nodePosition.x - spotlightRect.width / 2 - padding,
            y: nodePosition.y - spotlightRect.height / 2 - padding
        )
        spotlightRect.size = CGSize(
            width: spotlightRect.width + padding * 2,
            height: spotlightRect.height + padding * 2
        )
        
        // Create glowing border with custom color
        let spotlightPath = UIBezierPath(roundedRect: spotlightRect, cornerRadius: 10)
        let glowNode = SKShapeNode(path: spotlightPath.cgPath)
        glowNode.strokeColor = color
        glowNode.lineWidth = 4
        glowNode.fillColor = .clear
        glowNode.glowWidth = 2
        spotlightHole.addChild(glowNode)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(pulse))
    }
    
    /// Handle touch on tutorial elements
    func handleTouch(at location: CGPoint) {
        guard let scene = scene else { return }
        
        let touchedNodes = scene.nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "tutorialNextButton" || node.parent?.name == "tutorialNextButton" {
                // Next button pressed
                advanceStep()
                return
            }
            
            if node.name == "tutorialSkipButton" || node.parent?.name == "tutorialSkipButton" {
                // Skip tutorial pressed
                skipTutorial()
                return
            }
        }
    }
    
    /// Advance to next tutorial step
    private func advanceStep() {
        switch currentStep {
        case .tapRegion:
            showStep(.skipButton)
        case .skipButton:
            showStep(.timer)
        case .timer:
            showStep(.gestures)
        case .gestures:
            showStep(.complete)
        case .complete:
            break
        }
    }
    
    /// Skip tutorial entirely
    private func skipTutorial() {
        // Still increment count so it doesn't show again immediately
        tempTimerLabel?.removeFromParent()
        tempTimerLabel = nil
        
        TutorialManager.incrementTutorialCount()
        removeTutorial()
        onSkip?()
    }
    
    /// Complete tutorial and clean up
    private func completeTutorial() {
        tempTimerLabel?.removeFromParent()
        tempTimerLabel = nil
        
        TutorialManager.incrementTutorialCount()
        removeTutorial()
        onComplete?()
    }
    
    /// Remove tutorial from scene
    private func removeTutorial() {
        overlayNode?.removeFromParent()
    }
}
