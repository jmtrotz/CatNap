//
//  GameScene.swift
//  CatNap
//
//  Created by Jeffery Trotz on 2/21/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit
import GameplayKit

// Used to access physics body categories
struct PhysicsCategory
{
    // Define categories for physics bodies
    static let None: UInt32 = 0 // 0
    static let Cat: UInt32 = 0b1 // 1
    static let Block: UInt32 = 0b10 // 2
    static let Bed: UInt32 = 0b100 // 4
    static let Edge: UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
    static let Spring: UInt32 = 0b100000 // 32
    static let Hook: UInt32 = 0b1000000 // 64
}

// Listens for nodes being added to the scene
protocol EventListenerNode
{
    func didMoveToScene()
}

// Destroys a block when the user taps it
protocol InteractiveNode
{
    func interact()
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    // Cat and bed nodes
    var bedNode: BedNode!
    var catNode: CatNode!
    
    // Used to avoid multiple message nodes
    var playable = true
    
    // Keeps track of the current level
    var currentLevel: Int = 0
    
    // Used to check if the hook is set up or not
    var hookBaseNode: HookBaseNode?
    
    // Sets the current level and scale mode if the level file loads correctly
    class func level(levelNum: Int) -> GameScene?
    {
        let scene = GameScene(fileNamed: "Level\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didSimulatePhysics()
    {
        // Check to make sure the game is still playable
        // Checks isHooked so the cat won't wake up while swinging on the hook
        if playable && hookBaseNode?.isHooked != true
        {
            // If the cat tilts more than 25 degrees the player loses
            if abs(catNode.parent!.zRotation) > CGFloat(25).degreesToRadians()
            {
                lose()
            }
        }
    }
    
    override func didMove(to view: SKView)
    {
        // Calculate playable area
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        let playableArea = CGRect(x: 0, y: playableMargin, width: size.width,
                                  height: size.height - playableMargin * 2)
        
        // Set playable area
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableArea)
        
        // Set GameScene as the contact delegate for the scene's physics world
        physicsWorld.contactDelegate = self
        
        // Assign PhysicsCategory.Edge as the edge loop body's category
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        // Starts at the root and moves recursively down the
        // hierarchy and matches nodes using EventListenerNode
        enumerateChildNodes(withName: "//*", using:
        {
            node, _ in
            if let eventListenerNode = node as? EventListenerNode
            {
                eventListenerNode.didMoveToScene()
            }
        })
        
        bedNode = childNode(withName: "bed") as! BedNode
        catNode = childNode(withName: "//cat_body") as! CatNode
        
        // Start background music
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        
        // Set rotation constraints on the cat node
        //let rotationConstraint = SKConstraint.zRotation(SKRange(lowerLimit: -π / 4, upperLimit: π / 4))
        //catNode.parent!.constraints = [rotationConstraint]
        
        // Find the hook base in the scene
        hookBaseNode = childNode(withName: "hookBase") as? HookBaseNode
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        // Get what bodies collided
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // If it was the message and the floor, increment the bounce counter
        if collision == PhysicsCategory.Label | PhysicsCategory.Edge
        {
            // Figure out which body was the message
            let labelNode = contact.bodyA.categoryBitMask ==
                PhysicsCategory.Label ? contact.bodyA.node : contact.bodyB.node
            
            // Increment the bounce counter
            if let message = labelNode as? MessageNode
            {
                message.didBounce()
            }
        }
        
        // If not playable, return
        if !playable
        {
            return
        }
        
        // If was the cat and bed, they win
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed
        {
            print("Success!")
            win()
        }
        
        // If was the cat and floor, they lose
        else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge
        {
            print("FAIL!!! You're awful at this game!!! LOSER!!!")
            lose()
        }
        
        // Checks if the cat has contacted the hook
        if collision == PhysicsCategory.Cat | PhysicsCategory.Hook && hookBaseNode?.isHooked == false
        {
            hookBaseNode!.hookCat(catPhysicsBody: catNode.parent!.physicsBody!)
        }
    }
    
    // Shows message when game is over
    func inGameMessage(text: String)
    {
        // Create message node
        let message = MessageNode(message: text)
        
        // Set message position
        message.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Add it to the scene
        addChild(message)
    }
    
    // Reloads the scene when a new game is started
    func newGame()
    {
        // Remove current scene and replace it with the new one
        view!.presentScene(GameScene.level(levelNum: currentLevel))
    }
    
    // Called if the cat contacts the floor
    func lose()
    {
        // Decrement the level number
        if currentLevel > 1
        {
            currentLevel -= 1
        }
        
        // Set to false to avoid multiple message nodes
        playable = false
        
        // Stop music and play "lose" sound
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("lose.mp3")
        
        // Show lose message
        inGameMessage(text: "Try Again...")
        
        // Start a new game after 5 seconds
        run(SKAction.afterDelay(5, runBlock: newGame))
        
        // Change the cat to the distressed version
        catNode.wakeUp()
    }
    
    // Called if the cat lands in the bed
    func win()
    {
        // Increment the level number
        if currentLevel < 6
        {
            currentLevel += 1
        }
        
        // Set to false to avoid multiple message nodes
        playable = false
        
        // Stop music and play "win" sound
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("win.mp3")
        
        // Show win message
        inGameMessage(text: "Nice Job!!!")
        
        // Start a new game after 3 seconds
        run(SKAction.afterDelay(3, runBlock: newGame))
        
        // Curl up the cat in the bed
        catNode.curlAt(scenePoint: bedNode.position)
    }
}
