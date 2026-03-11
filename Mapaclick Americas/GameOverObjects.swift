//
//  GameOverObjects.swift
//  mapaclick
//
//  Created by javier pizarro on 9/25/23.
//
//  UPDATED: Uses a single shared SKView instance for texture generation
//

import Foundation
import SpriteKit

class GameOverObjects{
    
    // MARK: - Shared SKView for texture generation
    private static let textureGeneratorView: SKView = {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        return view
    }()
    
    
    func endGameRectangleBezierPathToSKSpriteNode(bpEndGameRectangle: UIBezierPath)-> SKSpriteNode{//Big island frame properties
           
        let shapeNode = SKShapeNode(path:bpEndGameRectangle.cgPath)
        shapeNode.strokeColor = UIColor.init(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)/*init(red: 0.9098, green: 0.7412, blue: 0.051, alpha: 1.0)*/
        shapeNode.fillColor = UIColor.init(red: 0.2392, green: 0.698, blue: 1, alpha: 1.0)/*(red: 0.1255, green: 0.451, blue: 0.5961, alpha: 1.0)*/
        shapeNode.lineWidth = 4.0
        let texture = GameOverObjects.textureGeneratorView.texture(from: shapeNode)!
        let rectangleNode = SKSpriteNode(texture: texture)
        //rectangleNode.position = CGPoint(x:280, y:190)
        return  rectangleNode
    }
    
    func createEndGameRectangle()->UIBezierPath{
        // Initialize the path.
           var path = UIBezierPath()
        
           // Specify the point that the path should start get drawn.
           path.move(to: CGPoint(x: 0.0, y: 0.0))
        
           // Create a line between the starting point and the bottom-left side of the view.
           path.addLine(to: CGPoint(x: 0.0, y:250))
        
           // Create the bottom line (bottom-left to bottom-right).
           path.addLine(to: CGPoint(x:350 , y:250))
        
           //Create the vertical line from the bottom-right to the top-right side.
           path.addLine(to: CGPoint(x:350, y: 0.0))
        
           // Close the path. This will create the last line automatically.
           path.close()
           
           path = UIBezierPath(roundedRect:path.bounds,cornerRadius: 4.0)
           
           return path
    }
    
    func endGameRectangleMapButtonBezierPathToSKSpriteNode(bpEndGameRectangleButton: UIBezierPath)-> SKSpriteNode{//Big island frame properties
           
        let shapeNode = SKShapeNode(path:bpEndGameRectangleButton.cgPath)
        shapeNode.strokeColor = UIColor.init(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)/*(red: 0.9373, green: 0.9608, blue: 0.9686, alpha: 1.0)*//*(red: 0.9098, green: 0.7412, blue: 0.051, alpha: 1.0)*///(red: 0.97, green: 0.56, blue: 0.12, alpha: 1.00)//(red: 1.00, green: 0.40, blue: 0.00, alpha: 1.00)//c1d3c8
        shapeNode.fillColor = UIColor.init(red: 0.2588, green: 0.7608, blue: 1, alpha: 1.0)/*(red: 0.9765, green: 0.4118, blue: 0.0549, alpha: 1.0)*/
        shapeNode.lineWidth = 2.5
        let texture = GameOverObjects.textureGeneratorView.texture(from: shapeNode)!
        let button = SKSpriteNode(texture: texture)
        //rectangleNode.position = CGPoint(x:280, y:190)
        setEndGameRectangleMapButtonAndLabels(button:button)
        return  button
    }
    
    func createEndGameRectangleSidesButtons()->UIBezierPath{
        // Initialize the path.
           var path = UIBezierPath()
        
           // Specify the point that the path should start get drawn.
           path.move(to: CGPoint(x: 0.0, y: 0.0))
        
           // Create a line between the starting point and the bottom-left side of the view.
           path.addLine(to: CGPoint(x: 0.0, y:63))
        
           // Create the bottom line (bottom-left to bottom-right).
           path.addLine(to: CGPoint(x:88 , y:63))
        
           //Create the vertical line from the bottom-right to the top-right side.
           path.addLine(to: CGPoint(x:88, y: 0.0))
        
           // Close the path. This will create the last line automatically.
           path.close()
           
           path = UIBezierPath(roundedRect:path.bounds,cornerRadius: 4.0)
           
           return path
    }
    
    func setEndGameRectangleMapButtonAndLabels(button:SKSpriteNode)/*-> SKSpriteNode*/ {
           /*La funcion comienza proveyendo los valores de las propiedades que comparten los tres botones**/
           //let buttonNode:SKSpriteNode = buttonNodeDefaults()
           button.name = "buttonMap"
           /*buttonNode.color = UIColor.init(red: 1, green: 0.1686, blue: 0.1686, alpha: 1.0)//color is same in all three buttons
           buttonNode.size = CGSize(width:endGameRectangle.size.width/5 + 20, height:endGameRectangle.size.height/4)
           buttonNode.zPosition = 3*/
          

           button.position = CGPoint(x:-115.5, y:-78.4)
           button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:button.size.width, height:button.size.height), center: CGPoint(x:0.5, y: 0.5))
           button.physicsBody?.isDynamic = false
           
           
           let buttonOneLabelOne = SKLabelNode()
           buttonOneLabelOne.fontName = "AvenirNext-Bold"
           buttonOneLabelOne.fontSize = 16
           buttonOneLabelOne.fontColor = UIColor.white//init(red: 0.6157, green: 0.9098, blue: 0.851, alpha: 1.0)
           buttonOneLabelOne.text = "Mapa"
           //buttonOneLabelOne.position = CGPoint(x:0, y:0)
           //buttonOneLabelOne.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
           button.addChild(buttonOneLabelOne)
           
           let buttonOneLabelTwo = SKLabelNode()
           buttonOneLabelTwo.fontName = "AvenirNext-Bold"
           buttonOneLabelTwo.fontSize = 13
           buttonOneLabelTwo.fontColor = UIColor.white//(red: 0.6157, green: 0.9098, blue: 0.851, alpha: 1.0)
           buttonOneLabelTwo.text = "(Map)"
           buttonOneLabelTwo.position = CGPoint(x:0, y:-13)
           //buttonOneLabelTwo.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
           button.addChild(buttonOneLabelTwo)

           //return buttonNode

    }
    
    func endGameRectangleJugarOtraButtonBezierPathToSKSpriteNode(bpEndGameRectangleButton: UIBezierPath)-> SKSpriteNode{//Big island frame properties
           
        let shapeNode = SKShapeNode(path:bpEndGameRectangleButton.cgPath)
        shapeNode.strokeColor = UIColor.init(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)//(red: 0.97, green: 0.56, blue: 0.12, alpha: 1.00)//(red: 1.00, green: 0.40, blue: 0.00, alpha: 1.00)//c1d3c8
        shapeNode.fillColor = UIColor.init(red: 0.1529, green: 0.8824, blue: 0.8078, alpha: 1.0)
        shapeNode.lineWidth = 2.5
        let texture = GameOverObjects.textureGeneratorView.texture(from: shapeNode)!
        let button = SKSpriteNode(texture: texture)
        //rectangleNode.position = CGPoint(x:280, y:190)
        setEndGameRectangleJugarOtraButtonAndLabels(button:button)
        return  button
    }
    
    func setEndGameRectangleJugarOtraButtonAndLabels(button:SKSpriteNode)/*-> SKSpriteNode*/ {
        /*La funcion comienza proveyendo los valores de las propiedades que comparten los tres botones**/
        //let buttonNode:SKSpriteNode = buttonNodeDefaults()
        button.name = "buttonJugarOtraVez"
       /* buttonNode.color = UIColor.init(red: 1, green: 0.1686, blue: 0.1686, alpha: 1.0)//color is same in all three buttons
        buttonNode.size = CGSize(width:endGameRectangle.size.width/5 + 20, height:endGameRectangle.size.height/4)
        buttonNode.zPosition = 3*/
       
        //buttonNode.size = CGSize(width:endGameRectangle.size.width/3, height:endGameRectangle.size.height/4)//Size is overriden pq es de los tres botones el unico que su tamano es diferente.
        button.position = CGPoint(x:0.5, y: -78.4)
        button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:button.size.width, height:button.size.height), center: CGPoint(x:0.5, y: 0.5))
        button.physicsBody?.isDynamic = false
        
        let buttonTwoLabelOne = SKLabelNode()
        buttonTwoLabelOne.fontName = "AvenirNext-Bold"
        buttonTwoLabelOne.fontSize = 16
        buttonTwoLabelOne.fontColor = UIColor.white
        buttonTwoLabelOne.text = "Jugar Otra Vez"
        //buttonOneLabelOne.position = CGPoint(x:0, y:0)
        //buttonTwoLabelOne.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
        button.addChild(buttonTwoLabelOne)
        
        let buttonTwoLabelTwo = SKLabelNode()
        buttonTwoLabelTwo.fontName = "AvenirNext-Bold"
        buttonTwoLabelTwo.fontSize = 13
        buttonTwoLabelTwo.fontColor = UIColor.white
        buttonTwoLabelTwo.text = "(Play Again)"
        buttonTwoLabelTwo.position = CGPoint(x:0, y:-13)
        //buttonTwoLabelTwo.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
        button.addChild(buttonTwoLabelTwo)
    

        //return buttonNode

    }
    
    func createEndGameRectangleMiddleButton()->UIBezierPath{
        // Initialize the path.
           var path = UIBezierPath()
        
           // Specify the point that the path should start get drawn.
           path.move(to: CGPoint(x: 0.0, y: 0.0))
        
           // Create a line between the starting point and the bottom-left side of the view.
           path.addLine(to: CGPoint(x: 0.0, y:63))
        
           // Create the bottom line (bottom-left to bottom-right).
           path.addLine(to: CGPoint(x:132 , y:63))
        
           //Create the vertical line from the bottom-right to the top-right side.
           path.addLine(to: CGPoint(x:132, y: 0.0))
        
           // Close the path. This will create the last line automatically.
           path.close()
           
           path = UIBezierPath(roundedRect:path.bounds,cornerRadius: 4.0)
           
           return path
    }
    
    func endGameRectangleSalirButtonBezierPathToSKSpriteNode(bpEndGameRectangleButton: UIBezierPath)-> SKSpriteNode{//Big island frame properties
           
        let shapeNode = SKShapeNode(path:bpEndGameRectangleButton.cgPath)
        shapeNode.strokeColor = UIColor.init(red: 0.6471, green: 0.8431, blue: 0.9098, alpha: 1.0)//(red: 0.97, green: 0.56, blue: 0.12, alpha: 1.00)//(red: 1.00, green: 0.40, blue: 0.00, alpha: 1.00)//c1d3c8
        shapeNode.fillColor = UIColor.init(red: 0.8941, green: 0.5765, blue: 0.5765, alpha: 1.0)
        shapeNode.lineWidth = 2.5
        let texture = GameOverObjects.textureGeneratorView.texture(from: shapeNode)!
        let button = SKSpriteNode(texture: texture)
        //rectangleNode.position = CGPoint(x:280, y:190)
        setEndGameRectangleSalirButtonAndLabels(button:button)
        return  button
    }
    
    func setEndGameRectangleSalirButtonAndLabels(button:SKSpriteNode)/*-> SKSpriteNode*/ {
        /*La funcion comienza proveyendo los valores de las propiedades que comparten los tres botones**/
        //let buttonNode:SKSpriteNode = buttonNodeDefaults()
        button.name = "buttonSalir"
       /* buttonNode.color = UIColor.init(red: 1, green: 0.1686, blue: 0.1686, alpha: 1.0)//color is same in all three buttons
        buttonNode.size = CGSize(width:endGameRectangle.size.width/5 + 20, height:endGameRectangle.size.height/4)
        buttonNode.zPosition = 3*/
       

        //buttonNode.size = CGSize(width:endGameRectangle.size.width/5 + 20, height:endGameRectangle.size.height/4)
        button.position = CGPoint(x:115.5, y:-78.4)
        button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:button.size.width, height:button.size.height), center: CGPoint(x:0.5, y: 0.5))
        button.physicsBody?.isDynamic = false

        let buttonThreeLabelOne = SKLabelNode()
        buttonThreeLabelOne.fontName = "AvenirNext-Bold"
        buttonThreeLabelOne.fontSize = 16
        buttonThreeLabelOne.fontColor = UIColor.white//init(red: 0.6157, green: 0.9098, blue: 0.851, alpha: 1.0)
        buttonThreeLabelOne.text = "Salir"
        //buttonOneLabelOne.position = CGPoint(x:0, y:0)
        //buttonThreeLabelOne.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
        button.addChild(buttonThreeLabelOne)
        
        let buttonThreeLabelTwo = SKLabelNode()
        buttonThreeLabelTwo.fontName = "AvenirNext-Bold"
        buttonThreeLabelTwo.fontSize = 13
        buttonThreeLabelTwo.fontColor = UIColor.white//init(red: 0.6157, green: 0.9098, blue: 0.851, alpha: 1.0)
        buttonThreeLabelTwo.text = "(Exit)"
        buttonThreeLabelTwo.position = CGPoint(x:0, y:-13)
        //buttonThreeLabelTwo.fontColor = UIColor.init(red: 0.88, green: 0.90, blue: 1.00, alpha: 1.00)
        button.addChild(buttonThreeLabelTwo)
        
    

        //return buttonNode

    }
    
    func redButtonBpDrawToSKSpriteNode()->SKSpriteNode{
        
        //Drawing
       var path = UIBezierPath()
       // Specify the point that the path should start get drawn.
       path.move(to: CGPoint(x: 0.0, y: 0.0))
       // Create a line between the starting point and the bottom-left side of the view.
       path.addLine(to: CGPoint(x: 0.0, y:20))
       // Create the bottom line (bottom-left to bottom-right).
       path.addLine(to: CGPoint(x:150 , y:20))
       //Create the vertical line from the bottom-right to the top-right side.
       path.addLine(to: CGPoint(x:150, y: 0.0))
       // Close the path. This will create the last line automatically.
       path.close()
         
       path = UIBezierPath(roundedRect:path.bounds,cornerRadius: 4.0)//Esta linea trabaja el curveado de las esquinas
       //path = UIBezierPath(roundedRect: path.bounds, cornerRadius: CGFloat(4.0))//otra version de la linea de arriba con el mismo resultado
       //Drawing to Shapenode
       let shapeNode = SKShapeNode(path:path.cgPath)
       shapeNode.lineWidth = 2.0
       shapeNode.strokeColor = UIColor.init(red: 0.6471, green: 0.9451, blue: 0.9137, alpha: 1.0)
       shapeNode.fillColor = UIColor.init(red: 0.498, green: 0.7373, blue: 0.8235, alpha: 1.0)
       //Shapenode To SKSpriteNode
       let texture = GameOverObjects.textureGeneratorView.texture(from: shapeNode)!
       let redButton = SKSpriteNode(texture: texture)
        
       setResultadosButton(buttonResultadosSKSpriteNode:redButton)

       return redButton
            
    }
    
    
    func setResultadosButton(buttonResultadosSKSpriteNode:SKSpriteNode)/*->SKSpriteNode*/{
        let label = setLabelDefaults()
        label.fontName = "AvenirNext-Bold"
        label.fontColor = UIColor.white//init(red: 0.7922, green: 0.8353, blue: 0.8863, alpha: 1.0)
        label.fontSize = 12
        label.text = "Resultados (Results)"
        label.position = CGPoint(x:0.5, y:-5.5)
        buttonResultadosSKSpriteNode.addChild(label)
        //buttonResultadosSKSpriteNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2 * 0.475)
        //buttonResultadosSKSpriteNode.size = label.frame.size
        buttonResultadosSKSpriteNode.name = "resultadosButton"
        buttonResultadosSKSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:buttonResultadosSKSpriteNode.size.width, height:buttonResultadosSKSpriteNode.size.height), center: CGPoint(x:0.5, y: 0.5))
        buttonResultadosSKSpriteNode.physicsBody?.isDynamic = false
        
        //return buttonResultadosSKSpriteNode
    }
    
    func setLabelDefaults()-> SKLabelNode{
        let label = SKLabelNode()
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 14
        label.position = CGPoint(x:0.5,y:-5.5)
        //.zPosition = 1
        return label
    }
}

