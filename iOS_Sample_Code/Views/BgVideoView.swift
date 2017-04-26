//
//  BgVideoView.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import UIKit

class BgVideoView: UIView {
    
    // MARK: Properties
    
    var videoFileName: String? {
        didSet {
            prepareVideo()
        }
    }
    
    fileprivate var player: AVPlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    
    
    // MARK: Lifecycle
    
    // MARK: Actions
    
    fileprivate func prepareVideo() {
        
        guard videoFileName != nil else {
            return
        }
        
        let type = (videoFileName! as NSString).pathExtension
        let resource = (videoFileName! as NSString).deletingPathExtension
        
        isUserInteractionEnabled = false
        
        let filePath = Bundle.main.path(forResource: resource, ofType: type)
        player = AVPlayer(url: URL(fileURLWithPath: filePath!))
        
        playerLayer = AVPlayerLayer()
        playerLayer.player = player
        playerLayer.frame = bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.addSublayer(playerLayer)
        
        addObservers()
    }
    
    func playVideo() {
        
        player.play()
    }
    
    func pauseVideo() {
        
        player.pause()
    }
    
    func updateVideoFrame() {
        
        if !playerLayer.frame.equalTo(bounds) {
            playerLayer.frame = bounds
        }
    }
}


// MARK: Observers 

extension BgVideoView {
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(myVideoFinishedCallback(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func myVideoFinishedCallback(_ notification: Notification) {
        
        guard let playerItem: AVPlayerItem = notification.object as? AVPlayerItem, playerItem == player.currentItem else {
            return
        }
        
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seek(to: seekTime)
        player.play()
    }
    
    func didBecomeActive() {
        
        player.play()
    }
}
