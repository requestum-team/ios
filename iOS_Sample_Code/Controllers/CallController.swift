//
//  CallController.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import UIKit

let CallStateDidChangeNotification = "CallStateDidChangeNotification"

enum CallState: String {
    
    case none = "none"
    case creating = "creating"
    case connecting = "connecting"
    case connected = "connected"
    case answered = "answered"
    case disconnecting = "disconnecting"
    case disconnected = "disconnected"
}

class CallController: NSObject {
    
    static let shared = CallController()
    
    
    // MARK: Properties
    
    var callState: CallState = .none {
        didSet {
            if oldValue == callState {
                return
            }
            notifyStateDidChange()
        }
    }
    
    var lastNotifiedCallState: CallState?
    
    var callAnsweredAt: TimeInterval?
    var callTime: TimeInterval {
        return callAnsweredAt != nil ? (Date().timeIntervalSince1970 - callAnsweredAt!) : 0
    }
    
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        callState = .none
        monitorCallState()
    }
    
    
    // MARK: Actions
    
    func notifyStateDidChange() {
        
        lastNotifiedCallState = callState
            
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CallStateDidChangeNotification), object: nil)
        }
    }
}


// MARK: Helpers

extension CallController {
    
    func callState(from artcClientState: ARTCClientState) -> CallState {
        
        switch artcClientState {
        case .connected: return .connected
        case .connecting: return .connecting
        case .disconnecting: return .disconnecting
        case .disconnected: return .disconnected
        }
    }
    
    func monitorCallState() {
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkCallState), userInfo: nil, repeats: true)
    }
    
    func checkCallState() {
        
        if callState != lastNotifiedCallState {
            
            notifyStateDidChange()
        }
    }
}
