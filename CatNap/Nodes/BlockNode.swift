//
//  BlockNode.swift
//  CatNap
//
//  Created by Jeff Trotz on 2/27/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class BlockNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Disables user interaction after a block is
    // destroyed to ignore touches on the same block
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        print("Destroy block")
        interact()
    }
    
    // Enables user interaction
    func didMoveToScene()
    {
        isUserInteractionEnabled = true
    }
    
    // Disables user interaction
    func interact()
    {
        isUserInteractionEnabled = false
        
        // Plays a sound, scales down the block, and removes it from the scene
        run(SKAction.sequence([
            SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
            SKAction.scale(to: 0.8, duration: 0.1),
            SKAction.removeFromParent()
            ]))
    }
}
