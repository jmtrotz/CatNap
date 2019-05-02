//
//  HintNode.swift
//  CatNap
//
//  Created by Jeffery Trotz on 3/18/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class HintNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Colors the arrow will change to when tapped
    private var colors = [SKColor.red, SKColor.yellow, SKColor.orange]
    
    // Shape node for the arrow hint indicator
    private var shape: SKShapeNode!
    
    // Creates an arrow to be used as a hint
    var arrowPath: CGPath
    {
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw lines that makes up the arrow
        bezierPath.move(to: CGPoint(x: 0.5, y: 65.69))
        bezierPath.addLine(to: CGPoint(x: 74.99, y: 1.5))
        bezierPath.addLine(to: CGPoint(x: 74.99, y: 38.66))
        bezierPath.addLine(to: CGPoint(x: 257.5, y: 38.66))
        bezierPath.addLine(to: CGPoint(x: 257.5, y: 92.72))
        bezierPath.addLine(to: CGPoint(x: 74.99, y:92.72))
        bezierPath.addLine(to: CGPoint(x: 74.99, y: 126.5))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 65.69))
        bezierPath.close()
        
        // Return the arrow
        return bezierPath.cgPath
    }
    
    // Calls interact() when the arrow is tapped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func didMoveToScene()
    {
        // Make background of the placeholder node invisible
        color = SKColor.clear
        
        // Arrow to be placed inside the placeholder
        shape = SKShapeNode(path: arrowPath)
        
        // Set node properties and add it to the scene
        shape.strokeColor = SKColor.gray
        shape.lineWidth = 4
        shape.fillColor = SKColor.green
        addChild(shape)
        
        // Add texture to the arrow
        shape.fillTexture = SKTexture(imageNamed: "wood_tinted")
        shape.alpha = 0.8
        
        // Actions to make the arrow move
        let move = SKAction.moveBy(x: -40, y: 0, duration: 1.0)
        let bounce = SKAction.sequence([move, move.reversed()])
        let bounceAction = SKAction.repeat(bounce, count: 3)
        
        // Run the action, then remove the arrow from the scene
        shape.run(bounceAction, completion:
        {
            self.removeFromParent()
        })
        
        // Make the arrow "tappable"
        isUserInteractionEnabled = true
    }
    
    // Changes the color of the arrow when it is tapped
    func interact()
    {
        shape.fillColor = colors[Int.random(min: 0, max: colors.count - 1)]
    }
}
