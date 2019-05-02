//
//  BedNode.swift
//  CatNap
//
//  Created by Jeffery Trotz on 2/27/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class BedNode: SKSpriteNode, EventListenerNode
{
    func didMoveToScene()
    {
        // Set up physics body for the cat bed
        let bedBodySize = CGSize(width: 40.0, height: 30.0)
        physicsBody = SKPhysicsBody(rectangleOf: bedBodySize)
        physicsBody!.isDynamic = false
        
        // Set the bed's category bit mask
        physicsBody!.categoryBitMask = PhysicsCategory.Bed
        
        // Set the bed to collide with nothing
        physicsBody!.collisionBitMask = PhysicsCategory.None
        print("Bed added to scene")
    }
}
