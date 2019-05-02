//
//  CatNode.swift
//  CatNap
//
//  Created by Jeffery Trotz on 2/27/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class CatNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Notification to broadcast when the cat is tapped
    static let kCatTappedNotification = "kCatTappedNotification"
    
    // Keeps track if the cat is dancing to the disco music or not
    private var isDoingTheDance = false
    
    // Calls interact() after the user touches the cat
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func didMoveToScene()
    {
        // Create texture object
        let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
        
        // Create physics body using the texture object
        parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
        
        // Set the cat's category bit mask
        parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        
        // Set the cat to collide with the blocks, edge of the scene, and the spring
        parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge | PhysicsCategory.Spring
        
        // Set what counts as contact
        parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
        
        // Enable user interaction
        isUserInteractionEnabled = true
        
        print("Cat added to scene")
    }
    
    // "Wakes up" the cat if it hits the floor
    func wakeUp()
    {
        // Loop over all of the cat's child nodes (eyes,
        // mouth, etc) and remove them from the cat's body
        for child in children
        {
            child.removeFromParent()
        }
        
        // Reset the cat to an empty node
        texture = nil
        color = SKColor.clear
        
        // Load CatWakeUp.sks and fetch the scene child named "cat_awake"
        let catAwake = SKSpriteNode(fileNamed: "CatWakeUp")!.childNode(withName: "cat_awake")!
        
        // Change parent from CatWakeUp.sks to the CatNode
        catAwake.move(toParent: self)
        
        // Set position to appear over the existing texture
        catAwake.position = CGPoint(x: -30, y: 100)
    }
    
    // "Curls up" the cat if it lands in the bed
    func curlAt(scenePoint: CGPoint)
    {
        // Remove the cat's physics body
        parent!.physicsBody = nil
        
        // Loop over all of the cat's child nodes (eyes,
        // mouth, etc) and remove them from the cat's body
        for child in children
        {
            child.removeFromParent()
        }
        
        // Reset the cat to an empty node
        texture = nil
        color = SKColor.clear
        
        // Load CatCurl.sks and cetch the scene child named "cat_curl"
        let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNode(withName: "cat_curl")!
        
        // Set position to appear over the existing texture
        catCurl.position = CGPoint(x: -30, y: 100)
        
        // Get the location of the bed
        var localPoint = parent!.convert(scenePoint, from: scene!)
        
        // Add 1/3 of the cat's height to the curl point so the curl
        // happens towards the bottom of the bed instead of the center
        localPoint.y += frame.size.height / 3
        
        // Moves the cat to the center of the bed and straightens
        // it up in case it was falling over
        run(SKAction.group([
            SKAction.move(to: localPoint, duration: 0.66),
            SKAction.rotate(toAngle: -parent!.zRotation, duration: 0.5)
            ]))
    }
    
    // Broadcasts a notification when the cat is tapped
    func interact()
    {
        NotificationCenter.default.post(Notification(name:
            NSNotification.Name(CatNode.kCatTappedNotification), object: nil))
        
        if DiscoBallNode.isDiscoTime && !isDoingTheDance
        {
            isDoingTheDance = true
            
            // Actions for the "dance" the cat does on level 6
            let move = SKAction.sequence(
            [
                SKAction.moveBy(x: 80, y: 0, duration: 0.5),
                SKAction.wait(forDuration: 0.5),
                SKAction.moveBy(x: -30, y: 0, duration: 0.5)
            ])
            
            // Repeats the dance 3 times
            let dance = SKAction.repeat(move, count:3)
            
            // Run the dance, then set isDoingTheDance back to false when it's over
            parent!.run(dance, completion:
            {
                self.isDoingTheDance = false
            })
        }
    }
}
