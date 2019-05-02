//
//  HookBaseNode.swift
//  CatNap
//
//  Created by Jeffrey Trotz on 3/9/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit

class HookBaseNode: SKSpriteNode, EventListenerNode
{
    // Various nodes to create the hook that catches the cat when it is sprung up
    private var hookNode = SKSpriteNode(imageNamed: "hook")
    private var ropeNode = SKSpriteNode(imageNamed: "rope")
    private var hookJoint: SKPhysicsJointFixed!
    
    var isHooked: Bool
    {
        return hookJoint != nil
    }
    
    // Releases the cat from the hook when the cat is tapped
    @objc func catTapped()
    {
        if isHooked
        {
            releaseCat()
        }
    }
    
    func didMoveToScene()
    {
        guard let scene = scene else
        {
            return
        }
        
        // Secures the hook base to the top of the scene
        let ceilingFix = SKPhysicsJointFixed.joint(withBodyA: scene.physicsBody!, bodyB: physicsBody!, anchor: CGPoint.zero)
        scene.physicsWorld.add(ceilingFix)
        
        // Adds rope node to the scene and scures it to the hook base
        ropeNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        ropeNode.zRotation = CGFloat(270).degreesToRadians()
        ropeNode.position = position
        scene.addChild(ropeNode)
        
        // Creates physics body/sets position/physics properties for the hook node
        hookNode.position = CGPoint(x: position.x, y: position.y - ropeNode.size.width)
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.size.width / 2)
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.Cat
        hookNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        scene.addChild(hookNode)
        
        // Calculate position where the joint should attach itself to the hook
        let hookPosition = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height / 2)
        
        // Connect the hook base's body to the hook node with a spring joint and add it to the scene
        let ropeJoint = SKPhysicsJointSpring.joint(withBodyA: physicsBody!, bodyB: hookNode.physicsBody!,
                                                   anchorA: position, anchorB: hookPosition)
        scene.physicsWorld.add(ropeJoint)
        
        // Constraints to change the zRotation of the rope node so it always points towards
        // another "target node". Range is 0 so the hook and rope stay tightly connected
        let range = SKRange(lowerLimit: 0.0, upperLimit: 0.0)
        let orientConstraint = SKConstraint.orient(to: hookNode, offset: range)
        ropeNode.constraints = [orientConstraint]
        
        // Impulse for the hook node so it will swing
        hookNode.physicsBody!.applyImpulse(CGVector(dx: 50, dy: 0))
        
        // Listens for a notifcation saying the cat was tapped. When received it
        // calls the function to release the cat from the hook
        NotificationCenter.default.addObserver(self, selector: #selector(catTapped), name:
            Notification.Name(CatNode.kCatTappedNotification), object: nil)
    }
    
    // Holds the cat in place when it contacts the hook
    func hookCat(catPhysicsBody: SKPhysicsBody)
    {
        // Manually alter the physics simulation by forcing the
        // velocity and angular velocity on the cat's body to 0
        catPhysicsBody.velocity = CGVector(dx: 0, dy: 0)
        catPhysicsBody.angularVelocity = 0
        
        // Calculate where both bodies will be anchored together
        let pinPoint = CGPoint(x: hookNode.position.x, y: hookNode.position.y
            + hookNode.size.height / 2)
        
        // Create joint to connect the cat and hook together
        hookJoint = SKPhysicsJointFixed.joint(withBodyA: hookNode.physicsBody!,
                                              bodyB: catPhysicsBody, anchor: pinPoint)
        
        // Add it to the scene
        scene!.physicsWorld.add(hookJoint)
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
    }
    
    // Unhooks the cat from the hook
    func releaseCat()
    {
        // Remove joint connecting the hook/cat and straightens the hook/cat
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.None
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
        hookJoint.bodyA.node!.zRotation = 0
        hookJoint.bodyB.node!.zRotation = 0
        scene?.physicsWorld.remove(hookJoint)
        hookJoint = nil
    }
}
