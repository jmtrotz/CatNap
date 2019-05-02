//
//  PictureNode.swift
//  CatNap
//
//  Created by Jeffery Trotz on 3/18/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class PictureNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Called when the picture is tapped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        // Call interact() to make the picture fall
        interact()
    }
    
    func didMoveToScene()
    {
        // Enable user interaction
        isUserInteractionEnabled = true
        
        // Load zombie picture
        let pictureNode = SKSpriteNode(imageNamed: "picture")
        
        // Load picture frame (circle with transparent center)
        let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
        
        // Create the node for cropping the picture
        let cropNode = SKCropNode()
        
        // Add the picture to be cropped
        cropNode.addChild(pictureNode)
        
        // Set the image to crop it with and add it to the scene
        cropNode.maskNode = maskNode
        addChild(cropNode)
    }
    
    // Called by touchesEnded() when the picture is tapped.
    func interact()
    {
        // Disable interaction
        isUserInteractionEnabled = false
        
        // Set the picture's physics body to
        // dynamic so it will be affected by gravity
        physicsBody!.isDynamic = true
    }
}
