//
//  SpringNode.swift
//  CatNap
//
//  Created by Jeffrey Trotz on 3/9/19.
//  Class: SC 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class SpringNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Calls function to interact with the spring when the user touches it
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func didMoveToScene()
    {
        // Enable user interaction
        isUserInteractionEnabled = true
    }
    
    func interact()
    {
        // Spring only works once, so disable user interaction
        isUserInteractionEnabled = false
        
        // Apply impuse to the spring
        physicsBody!.applyImpulse(CGVector(dx: 0, dy: 250), at: CGPoint(x: size.height/2, y: size.height))
        
        // Run action
        run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
    }
}
