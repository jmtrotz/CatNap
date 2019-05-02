//
//  StoneNode.swift
//  CatNap
//
//  Created by Jeffrey Trotz on 3/10/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class StoneNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Called when the user touches the "L" shaped stone block.
    // Calls interact() to remove the "L" shaped stone block
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    // Creates a compound physics body out of individual pieces from the scene
    static func makeCompoundNode(in scene: SKScene) -> SKNode
    {
        // Holds the compound node built below
        let compound = StoneNode()
        
        // Finds all stone pieces and removes them from the scene
        // and adds them to the compound property (above) instead
        for stone in scene.children
            .filter({node in node is StoneNode})
            {
                stone.removeFromParent()
                compound.removeFromParent()
                compound.addChild(stone)
            }
        
        // Store all found pieces in an array
        let bodies = compound.children.map
        {
            node in SKPhysicsBody(rectangleOf: node.frame.size, center: node.position)
        }
        
        // Create compound physics body out of all of the pieces
        compound.physicsBody = SKPhysicsBody(bodies: bodies)
        
        // Set it so the edge, cat, and blocks don't pass right through it
        compound.physicsBody!.collisionBitMask = PhysicsCategory.Edge
            | PhysicsCategory.Cat | PhysicsCategory.Block
        
        // Set physics category, enable interaction, and z position
        compound.physicsBody!.categoryBitMask = PhysicsCategory.Block
        compound.isUserInteractionEnabled = true
        compound.zPosition = 1
        
        return compound
    }
    
    func didMoveToScene()
    {
        guard let scene = scene else
        {
            return
        }
        
        // For each node, check if its parent is scene. If so, then the stone nodes
        // haven't been moved to a compound node yet, so the function to do so is called
        if parent == scene
        {
            scene.addChild(StoneNode.makeCompoundNode(in: scene))
        }
    }
    
    // Removes the "L" shaped stone block from the scene
    func interact()
    {
        // Disable user interaction
        isUserInteractionEnabled = false
        
        // Run action to play a sound file and remove the node from the scene
        run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                               SKAction.removeFromParent()]))
    }
}
