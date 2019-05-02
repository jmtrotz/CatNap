//
//  DiscoBallNode.swift
//  CatNap
//
//  Created by Jeffery Trotz on 3/18/19.
//  Class: CS 430
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import SpriteKit
import AVFoundation

class DiscoBallNode: SKSpriteNode, EventListenerNode, InteractiveNode
{
    // Static property to expose isDiscoTime to other classes
    static private(set) var isDiscoTime = false
    
    // Video player and video nodes to play and display the video
    private var player: AVPlayer!
    private var video: SKVideoNode!
    
    // Shows/hides the video whenever isDiscoTime changes
    private var isDiscoTime: Bool = false
    {
        didSet
        {
            video.isHidden = !isDiscoTime
            
            // If isDiscoTime is true, play the video and run the spin animation
            if isDiscoTime
            {
                video.play()
                run(spinAction)
            }
            
            // If it's false, pause the video and stop the spin animation
            else
            {
                video.pause()
                removeAllActions()
            }
            
            // If isDiscoTime is true, play disco music, else play the standard background music
            SKTAudio.sharedInstance().playBackgroundMusic(isDiscoTime ? "disco-sound.m4a" : "backgroundMusic.mp3")
            
            // Checks if disco mode is active. If so, wait 5 seconds, then set isDiscoTime
            // to false to trigger the didSet handler again to pause/hide the video
            if isDiscoTime
            {
                video.run(SKAction.wait(forDuration: 5.0), completion:
                {
                        self.isDiscoTime = false
                })
            }
            
            // Keeps static property in sync with the instance property
            DiscoBallNode.isDiscoTime = isDiscoTime
        }
    }
    
    // Action to animate the disco ball spinning
    private let spinAction = SKAction.repeatForever(
        SKAction.animate(with:
            [
                SKTexture(imageNamed: "discoball1"),
                SKTexture(imageNamed: "discoball2"),
                SKTexture(imageNamed: "discoball3")
            ], timePerFrame: 0.2)
    )
    
    // Rewinds the video
    @objc func didReachEndOfVideo()
    {
        print("Rewind video")
        
        // Seek to the beginning of the video and play it again
        player.currentItem!.seek(to: CMTime.zero)
        {
            [weak self] _ in self?.player.play()
        }
    }
    
    // Called when the disco ball is tapped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func didMoveToScene()
    {
        isUserInteractionEnabled = true
        
        // Get the location of the video file
        let fileURL = Bundle.main.url(forResource: "discolights-loop", withExtension: "mov")!
        
        // Feed the file to the player, then use that to create a video node
        player = AVPlayer(url: fileURL)
        video = SKVideoNode(avPlayer: player)
        
        // Set the size/position of the video node
        video.size = scene!.size
        video.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        video.zPosition = -1
        
        // Add the video node to the scene and hide/pause it
        // until the disco ball is tapped
        scene!.addChild(video)
        video.isHidden = true
        video.pause()
        
        // Listens for a notification that's posted when the AVPlayer
        // reaches the end of the video file and calls didReachEndOfVideo()
        // to rewind the video and play it again
        NotificationCenter.default.addObserver(self, selector: #selector(didReachEndOfVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        video.alpha = 0.75
    }
    
    // Changes the state of isDiscoTime
    func interact()
    {
        // If isDiscoTime is false, change it to true
        if !isDiscoTime
        {
            isDiscoTime = true
        }
    }
}
