//
//  MessageNode.swift
//  CatNap
//
//  Created by Jeffrey Trotz on 2/28/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class MessageNode: SKLabelNode
{
    // Keeps track of the number of times the message bounces
    var bounces = 0
    
    // Shows text on screen
    convenience init(message: String)
    {
        // Sets label font
        self.init(fontNamed: "AvenirNext-Regular")
        
        // Set label text, size, color, etc
        text = message
        fontSize = 256.0
        fontColor = SKColor.gray
        zPosition = 100	
        
        // Create "poor man's" drop shaddow for the label above
        let font = SKLabelNode(fontNamed: "AvenirNext-Regular")
        font.text = message
        font.fontSize = 256.0
        font.fontColor = SKColor.white
        font.position = CGPoint(x: -2, y: -2)
        addChild(font)
        
        // Create circular physics body for the label
        physicsBody = SKPhysicsBody(circleOfRadius: 10)
        
        // Set it to bounce off the scene's edge
        physicsBody!.collisionBitMask = PhysicsCategory.Edge
        
        // Assign physics category
        physicsBody!.categoryBitMask = PhysicsCategory.Label
        
        // Set what counts as contact
        physicsBody!.contactTestBitMask = PhysicsCategory.Edge
        
        // Set bounciness
        physicsBody!.restitution = 0.7
    }
    
    // Counts how many times the message node bounces
    func didBounce()
    {
        // Increment the counter
        bounces += 1
        
        // If it bounces 4 times, remove it from the scene
        if bounces >= 4
        {
            removeFromParent()
        }
    }
}
