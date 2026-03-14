//
//  InitSetMapNodes.swift
//  mapaclick
//
//  Generated from America-blank-map-01.svg
//  by scripts/parse_svg_to_swift.py
//

import SpriteKit
import Foundation

class InitSetMapNodes{
    
    private static let textureGeneratorView: SKView = {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        return view
    }()
    
     func initSetcontainerNodeAndChildren()->SKNode{
         let containerSKNode = SKNode()
         let canadaSKSpriteNode: SKSpriteNode = canadaBezierPathToSKSpriteNode(bpCanada: BezierPathsForMapNodesAndRectangles().canadaDrawBezierPath())
         let unitedStatesSKSpriteNode: SKSpriteNode = unitedStatesBezierPathToSKSpriteNode(bpUnitedStates: BezierPathsForMapNodesAndRectangles().unitedStatesDrawBezierPath())
         let mexicoSKSpriteNode: SKSpriteNode = mexicoBezierPathToSKSpriteNode(bpMexico: BezierPathsForMapNodesAndRectangles().mexicoDrawBezierPath())
         let greenlandSKSpriteNode: SKSpriteNode = greenlandBezierPathToSKSpriteNode(bpGreenland: BezierPathsForMapNodesAndRectangles().greenlandDrawBezierPath())
         let guatemalaSKSpriteNode: SKSpriteNode = guatemalaBezierPathToSKSpriteNode(bpGuatemala: BezierPathsForMapNodesAndRectangles().guatemalaDrawBezierPath())
         let belizeSKSpriteNode: SKSpriteNode = belizeBezierPathToSKSpriteNode(bpBelize: BezierPathsForMapNodesAndRectangles().belizeDrawBezierPath())
         let hondurasSKSpriteNode: SKSpriteNode = hondurasBezierPathToSKSpriteNode(bpHonduras: BezierPathsForMapNodesAndRectangles().hondurasDrawBezierPath())
         let elSalvadorSKSpriteNode: SKSpriteNode = elSalvadorBezierPathToSKSpriteNode(bpElSalvador: BezierPathsForMapNodesAndRectangles().elSalvadorDrawBezierPath())
         let nicaraguaSKSpriteNode: SKSpriteNode = nicaraguaBezierPathToSKSpriteNode(bpNicaragua: BezierPathsForMapNodesAndRectangles().nicaraguaDrawBezierPath())
         let costaRicaSKSpriteNode: SKSpriteNode = costaRicaBezierPathToSKSpriteNode(bpCostaRica: BezierPathsForMapNodesAndRectangles().costaRicaDrawBezierPath())
         let panamaSKSpriteNode: SKSpriteNode = panamaBezierPathToSKSpriteNode(bpPanama: BezierPathsForMapNodesAndRectangles().panamaDrawBezierPath())
         let colombiaSKSpriteNode: SKSpriteNode = colombiaBezierPathToSKSpriteNode(bpColombia: BezierPathsForMapNodesAndRectangles().colombiaDrawBezierPath())
         let venezuelaSKSpriteNode: SKSpriteNode = venezuelaBezierPathToSKSpriteNode(bpVenezuela: BezierPathsForMapNodesAndRectangles().venezuelaDrawBezierPath())
         let guyanaSKSpriteNode: SKSpriteNode = guyanaBezierPathToSKSpriteNode(bpGuyana: BezierPathsForMapNodesAndRectangles().guyanaDrawBezierPath())
         let surinameSKSpriteNode: SKSpriteNode = surinameBezierPathToSKSpriteNode(bpSuriname: BezierPathsForMapNodesAndRectangles().surinameDrawBezierPath())
         let frenchGuianaSKSpriteNode: SKSpriteNode = frenchGuianaBezierPathToSKSpriteNode(bpFrenchGuiana: BezierPathsForMapNodesAndRectangles().frenchGuianaDrawBezierPath())
         let brazilSKSpriteNode: SKSpriteNode = brazilBezierPathToSKSpriteNode(bpBrazil: BezierPathsForMapNodesAndRectangles().brazilDrawBezierPath())
         let ecuadorSKSpriteNode: SKSpriteNode = ecuadorBezierPathToSKSpriteNode(bpEcuador: BezierPathsForMapNodesAndRectangles().ecuadorDrawBezierPath())
         let peruSKSpriteNode: SKSpriteNode = peruBezierPathToSKSpriteNode(bpPeru: BezierPathsForMapNodesAndRectangles().peruDrawBezierPath())
         let boliviaSKSpriteNode: SKSpriteNode = boliviaBezierPathToSKSpriteNode(bpBolivia: BezierPathsForMapNodesAndRectangles().boliviaDrawBezierPath())
         let paraguaySKSpriteNode: SKSpriteNode = paraguayBezierPathToSKSpriteNode(bpParaguay: BezierPathsForMapNodesAndRectangles().paraguayDrawBezierPath())
         let chileSKSpriteNode: SKSpriteNode = chileBezierPathToSKSpriteNode(bpChile: BezierPathsForMapNodesAndRectangles().chileDrawBezierPath())
         let argentinaSKSpriteNode: SKSpriteNode = argentinaBezierPathToSKSpriteNode(bpArgentina: BezierPathsForMapNodesAndRectangles().argentinaDrawBezierPath())
         let uruguaySKSpriteNode: SKSpriteNode = uruguayBezierPathToSKSpriteNode(bpUruguay: BezierPathsForMapNodesAndRectangles().uruguayDrawBezierPath())
         let cubaSKSpriteNode: SKSpriteNode = cubaBezierPathToSKSpriteNode(bpCuba: BezierPathsForMapNodesAndRectangles().cubaDrawBezierPath())
         let jamaicaSKSpriteNode: SKSpriteNode = jamaicaBezierPathToSKSpriteNode(bpJamaica: BezierPathsForMapNodesAndRectangles().jamaicaDrawBezierPath())
         let haitiSKSpriteNode: SKSpriteNode = haitiBezierPathToSKSpriteNode(bpHaiti: BezierPathsForMapNodesAndRectangles().haitiDrawBezierPath())
         let dominicanRepublicSKSpriteNode: SKSpriteNode = dominicanRepublicBezierPathToSKSpriteNode(bpDominicanRepublic: BezierPathsForMapNodesAndRectangles().dominicanRepublicDrawBezierPath())
         let puertoRicoSKSpriteNode: SKSpriteNode = puertoRicoBezierPathToSKSpriteNode(bpPuertoRico: BezierPathsForMapNodesAndRectangles().puertoRicoDrawBezierPath())
         let bahamasSKSpriteNode: SKSpriteNode = bahamasBezierPathToSKSpriteNode(bpBahamas: BezierPathsForMapNodesAndRectangles().bahamasDrawBezierPath())
        
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: canadaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: unitedStatesSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: mexicoSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: greenlandSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: guatemalaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: belizeSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: hondurasSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: elSalvadorSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: nicaraguaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: costaRicaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: panamaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: colombiaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: venezuelaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: guyanaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: surinameSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: frenchGuianaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: brazilSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: ecuadorSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: peruSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: boliviaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: paraguaySKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: chileSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: argentinaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: uruguaySKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: cubaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: jamaicaSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: haitiSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: dominicanRepublicSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: puertoRicoSKSpriteNode)
         addChildSKSpriteNodeToParentSKNode(parent: containerSKNode, children: bahamasSKSpriteNode)
         
         //Following block adds country name labels to map nodes for Practice games and GameOverScene
         if StartMenuScene.playPracticeAlphabeticGame == true || StartMenuScene.playPracticeRandomGame == true || AlphabeticGameScene.completedGame == true || RandomGameScene.completedGame == true || PracticeAlphabeticGameScene.completedGame == true || PracticeRandomGameScene.completedGame == true{
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:canadaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:unitedStatesSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:mexicoSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:greenlandSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:guatemalaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:belizeSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:hondurasSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:elSalvadorSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:nicaraguaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:costaRicaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:panamaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:colombiaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:venezuelaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:guyanaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:surinameSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:frenchGuianaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:brazilSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:ecuadorSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:peruSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:boliviaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:paraguaySKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:chileSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:argentinaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:uruguaySKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:cubaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:jamaicaSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:haitiSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:dominicanRepublicSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:puertoRicoSKSpriteNode)
             setLabelForCountryNameAndAddToNodePractice(nodeSprite:bahamasSKSpriteNode)
             if StartMenuScene.playPracticeAlphabeticGame == true{
                 StartMenuScene.playPracticeAlphabeticGame = false
             }
             else if StartMenuScene.playPracticeRandomGame == true{
                 StartMenuScene.playPracticeRandomGame = false
             }
         }
         return containerSKNode
     }
    
     func setLabelForCountryNameAndAddToNodePractice(nodeSprite:SKSpriteNode){
         let locationNameLabel = SKLabelNode()
         let firstLineLabel = SKLabelNode()
         let secondLineLabel = SKLabelNode()
         var useLine2 = false
         
        func splitTextIntoFields(theText:String)->String{
            let twoLineText = theText
            var line1:String = ""
            for letter in twoLineText{
                if (String(letter) == " "){ useLine2 = true }
                if(useLine2 == false){ line1 = line1 + String(letter) }
            }
            return line1
        }
        func splitTextIntoFieldsTwo(theText:String)->String{
            useLine2 = false
            let twoLineText = theText
            var line2:String = ""
            for letter in twoLineText{
                if (String(letter) == " "){ useLine2 = true }
                if(useLine2 == true){ line2 = line2 + String(letter) }
            }
            return line2
        }
        if AlphabeticGameScene.completedGame == true || RandomGameScene.completedGame == true || PracticeAlphabeticGameScene.completedGame == true || PracticeRandomGameScene.completedGame == true{
             nodeSprite.colorBlendFactor = 0.8
             nodeSprite.color = UIColor.init(red: 0, green: 1, blue: 0.949, alpha: 1.0)
             nodeSprite.physicsBody = nil
         }
         locationNameLabel.text = nodeSprite.name
         
         switch locationNameLabel.text {
         case "Canada":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "United States":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "Mexico":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Greenland":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Guatemala":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Belize":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Honduras":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "El Salvador":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "Nicaragua":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Costa Rica":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "Panama":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Colombia":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Venezuela":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Guyana":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Suriname":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "French Guiana":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "Brazil":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Ecuador":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Peru":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Bolivia":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Paraguay":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Chile":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Argentina":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Uruguay":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Cuba":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Jamaica":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Haiti":
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         case "Dominican Republic":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "Puerto Rico":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         case "The Bahamas":
            firstLineLabel.text = splitTextIntoFields(theText: locationNameLabel.text!)
            secondLineLabel.text = splitTextIntoFieldsTwo(theText: locationNameLabel.text!)
            setTwoLineCountryNameLabels(labelLineFirst: firstLineLabel, labelLineSecond: secondLineLabel)
            firstLineLabel.position = CGPoint(x: 0.0, y: 2.0)
            secondLineLabel.position = CGPoint(x: 0.0, y: -6.0)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: firstLineLabel)
            addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: secondLineLabel)
            return
         default:
            setOneLineCountryNameLabel(Oneline:locationNameLabel)
            locationNameLabel.horizontalAlignmentMode = .center
            locationNameLabel.verticalAlignmentMode = .center
         }
         addChildSKLabelNodeToParentSKSpriteNode(parent: nodeSprite, children: locationNameLabel)
     }

    func setOneLineCountryNameLabel(Oneline:SKLabelNode){
        Oneline.fontName = "ArialMT"
        Oneline.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
        Oneline.fontSize = 5.5
    }
    func setTwoLineCountryNameLabels(labelLineFirst:SKLabelNode, labelLineSecond:SKLabelNode){
        labelLineFirst.fontName = "ArialMT"
        labelLineSecond.fontName = "ArialMT"
        labelLineFirst.fontSize = 5.0
        labelLineSecond.fontSize = 5.0
        labelLineFirst.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
        labelLineSecond.fontColor = UIColor.init(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
    }

     func addChildSKSpriteNodeToParentSKNode(parent:SKNode, children:SKSpriteNode){
         if children.parent == nil{ parent.addChild(children) }
     }
     func addChildSKLabelNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKLabelNode){
         if children.parent == nil{ parent.addChild(children) }
     }
     func addChildSKSpriteNodeToParentSKLabelNode(parent:SKLabelNode, children:SKSpriteNode){
         if children.parent == nil{ parent.addChild(children) }
     }
     func addChildSKSpriteNodeToParentSKSpriteNode(parent:SKSpriteNode, children:SKSpriteNode){
         if children.parent == nil{ parent.addChild(children) }
     }

    func createMapNode(from bezierPath: UIBezierPath, position: CGPoint, name: String, fillColor: UIColor? = nil, lineWidth: CGFloat = 0.75) -> SKSpriteNode {
        let bounds = bezierPath.bounds
        let padding: CGFloat = 0.0
        let size = CGSize(width: bounds.width + padding * 2, height: bounds.height + padding * 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        let fillColor = fillColor ?? UIColor(red: 0.78, green: 0.91, blue: 0.81, alpha: 1.00)
        let strokeColor = UIColor(red: 0.81, green: 1.00, blue: 0.81, alpha: 1.00)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.scaleBy(x: 1, y: -1)
            cgContext.translateBy(x: -bounds.minX + padding, y: -bounds.maxY - padding)
            cgContext.setFillColor(fillColor.cgColor)
            cgContext.setStrokeColor(strokeColor.cgColor)
            cgContext.setLineWidth(lineWidth)
            cgContext.addPath(bezierPath.cgPath)
            cgContext.drawPath(using: .fillStroke)
        }
        let texture = SKTexture(image: image)
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.position = position
        spriteNode.name = name
        spriteNode.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: spriteNode.size)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }

    func canadaBezierPathToSKSpriteNode(bpCanada: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 215.16, y: 423.97)
        let name = "Canada"
        let spriteNode = createMapNode(from: bpCanada, position: position, name: name)
        return spriteNode
    }
    
    func unitedStatesBezierPathToSKSpriteNode(bpUnitedStates: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 127.34, y: 380.5)
        let name = "United States"
        let spriteNode = createMapNode(from: bpUnitedStates, position: position, name: name)
        // Replace texture physics body with rectangle covering continental US only (excludes Alaska/Hawaii)
        // Offset from sprite center since Alaska shifts the full bounds north-west
        let rectSize = CGSize(width: 85.0, height: 35.0)
        let rectCenter = CGPoint(x: 38.0, y: -13.0)
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: rectSize, center: rectCenter)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }
    
    func mexicoBezierPathToSKSpriteNode(bpMexico: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 148.22, y: 324.1)
        let name = "Mexico"
        let spriteNode = createMapNode(from: bpMexico, position: position, name: name)
        return spriteNode
    }
    
    func greenlandBezierPathToSKSpriteNode(bpGreenland: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 332.96, y: 448.0)
        let name = "Greenland"
        let spriteNode = createMapNode(from: bpGreenland, position: position, name: name)
        return spriteNode
    }
    
    func guatemalaBezierPathToSKSpriteNode(bpGuatemala: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 172.5, y: 302.55)
        let name = "Guatemala"
        let spriteNode = createMapNode(from: bpGuatemala, position: position, name: name)
        return spriteNode
    }
    
    func belizeBezierPathToSKSpriteNode(bpBelize: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 177.19, y: 306.38)
        let name = "Belize"
        let spriteNode = createMapNode(from: bpBelize, position: position, name: name)
        // Replace texture physics body with rectangle extended east toward Caribbean for better tap detection
        let rectSize = CGSize(width: (spriteNode.size.width + 2) * 0.75, height: spriteNode.size.height - 2)
        let rectCenter = CGPoint(x: 1.0, y: -0.5) // east, slightly down
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: rectSize, center: rectCenter)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }
    
    func hondurasBezierPathToSKSpriteNode(bpHonduras: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 182.0, y: 299.43)
        let name = "Honduras"
        let spriteNode = createMapNode(from: bpHonduras, position: position, name: name)
        return spriteNode
    }
    
    func elSalvadorBezierPathToSKSpriteNode(bpElSalvador: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 175.3, y: 296.9)
        let name = "El Salvador"
        let spriteNode = createMapNode(from: bpElSalvador, position: position, name: name)
        // Replace texture physics body with centered rectangle for better tap detection
        let rectSize = CGSize(width: spriteNode.size.width - 1.5, height: spriteNode.size.height * 2)
        let rectCenter = CGPoint(x: 0.0, y: -3.0) // shift south away from Honduras
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: rectSize, center: rectCenter)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }
    
    func nicaraguaBezierPathToSKSpriteNode(bpNicaragua: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 183.7, y: 294.39)
        let name = "Nicaragua"
        let spriteNode = createMapNode(from: bpNicaragua, position: position, name: name)
        return spriteNode
    }
    
    func costaRicaBezierPathToSKSpriteNode(bpCostaRica: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 185.72, y: 285.45)
        let name = "Costa Rica"
        let spriteNode = createMapNode(from: bpCostaRica, position: position, name: name)
        return spriteNode
    }
    
    func panamaBezierPathToSKSpriteNode(bpPanama: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 195.42, y: 282.07)
        let name = "Panama"
        let spriteNode = createMapNode(from: bpPanama, position: position, name: name)
        return spriteNode
    }
    
    func colombiaBezierPathToSKSpriteNode(bpColombia: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 212.21, y: 270.19)
        let name = "Colombia"
        let spriteNode = createMapNode(from: bpColombia, position: position, name: name)
        return spriteNode
    }
    
    func venezuelaBezierPathToSKSpriteNode(bpVenezuela: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 228.44, y: 276.77)
        let name = "Venezuela"
        let spriteNode = createMapNode(from: bpVenezuela, position: position, name: name)
        return spriteNode
    }
    
    func guyanaBezierPathToSKSpriteNode(bpGuyana: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 246.5, y: 272.31)
        let name = "Guyana"
        let spriteNode = createMapNode(from: bpGuyana, position: position, name: name)
        return spriteNode
    }
    
    func surinameBezierPathToSKSpriteNode(bpSuriname: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 253.69, y: 269.69)
        let name = "Suriname"
        let spriteNode = createMapNode(from: bpSuriname, position: position, name: name)
        return spriteNode
    }
    
    func frenchGuianaBezierPathToSKSpriteNode(bpFrenchGuiana: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 260.58, y: 269.72)
        let name = "French Guiana"
        let spriteNode = createMapNode(from: bpFrenchGuiana, position: position, name: name)
        return spriteNode
    }
    
    func brazilBezierPathToSKSpriteNode(bpBrazil: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 257.94, y: 219.63)
        let name = "Brazil"
        let spriteNode = createMapNode(from: bpBrazil, position: position, name: name)
        return spriteNode
    }
    
    func ecuadorBezierPathToSKSpriteNode(bpEcuador: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 186.52, y: 254.0)
        let name = "Ecuador"
        let spriteNode = createMapNode(from: bpEcuador, position: position, name: name)
        return spriteNode
    }
    
    func peruBezierPathToSKSpriteNode(bpPeru: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 208.05, y: 233.49)
        let name = "Peru"
        let spriteNode = createMapNode(from: bpPeru, position: position, name: name)
        return spriteNode
    }
    
    func boliviaBezierPathToSKSpriteNode(bpBolivia: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 236.83, y: 213.89)
        let name = "Bolivia"
        let spriteNode = createMapNode(from: bpBolivia, position: position, name: name)
        return spriteNode
    }
    
    func paraguayBezierPathToSKSpriteNode(bpParaguay: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 251.44, y: 194.3)
        let name = "Paraguay"
        let spriteNode = createMapNode(from: bpParaguay, position: position, name: name)
        return spriteNode
    }
    
    func chileBezierPathToSKSpriteNode(bpChile: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 240.15, y: 158.2)
        let name = "Chile"
        let spriteNode = createMapNode(from: bpChile, position: position, name: name)
        return spriteNode
    }
    
    func argentinaBezierPathToSKSpriteNode(bpArgentina: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 245.19, y: 153.43)
        let name = "Argentina"
        let spriteNode = createMapNode(from: bpArgentina, position: position, name: name)
        return spriteNode
    }
    
    func uruguayBezierPathToSKSpriteNode(bpUruguay: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 261.98, y: 169.19)
        let name = "Uruguay"
        let spriteNode = createMapNode(from: bpUruguay, position: position, name: name)
        return spriteNode
    }
    
    func cubaBezierPathToSKSpriteNode(bpCuba: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 200.62, y: 318.24)
        let name = "Cuba"
        let spriteNode = createMapNode(from: bpCuba, position: position, name: name, lineWidth: 0.5)
        return spriteNode
    }

    func jamaicaBezierPathToSKSpriteNode(bpJamaica: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 204.66, y: 308.94)
        let name = "Jamaica"
        let spriteNode = createMapNode(from: bpJamaica, position: position, name: name, lineWidth: 0.5)
        // Replace texture physics body with rectangle larger than the island for easier tap detection
        // Taller than wide, centered on the island
        let rectSize = CGSize(width: 8.0, height: 6.0)
        let rectCenter = CGPoint(x: -0.5, y: 0.0)
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: rectSize, center: rectCenter)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }

    func haitiBezierPathToSKSpriteNode(bpHaiti: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 214.9, y: 311.31)
        let name = "Haiti"
        let spriteNode = createMapNode(from: bpHaiti, position: position, name: name, lineWidth: 0.5)
        return spriteNode
    }

    func dominicanRepublicBezierPathToSKSpriteNode(bpDominicanRepublic: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 222.14, y: 310.79)
        let name = "Dominican Republic"
        let spriteNode = createMapNode(from: bpDominicanRepublic, position: position, name: name, lineWidth: 0.5)
        return spriteNode
    }

    func puertoRicoBezierPathToSKSpriteNode(bpPuertoRico: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 230.76, y: 309.28)
        let name = "Puerto Rico"
        let spriteNode = createMapNode(from: bpPuertoRico, position: position, name: name, lineWidth: 0.5)
        // Replace texture physics body with rectangle larger than the island for easier tap detection
        // Taller than wide, offset slightly right to avoid overlapping Dominican Republic (2pt gap)
        let rectSize = CGSize(width: 5.0, height: 8.0)
        let rectCenter = CGPoint(x: 0.0, y: 0.0)
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: rectSize, center: rectCenter)
        spriteNode.physicsBody?.isDynamic = false
        return spriteNode
    }

    func bahamasBezierPathToSKSpriteNode(bpBahamas: UIBezierPath) -> SKSpriteNode {
        let position = CGPoint(x: 210.69, y: 325.03)
        let name = "The Bahamas"
        let spriteNode = createMapNode(from: bpBahamas, position: position, name: name, lineWidth: 0.5)
        return spriteNode
    }

    
}
