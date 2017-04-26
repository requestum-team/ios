//
//  CallManager.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation

import Alamofire
import ObjectMapper

class CallManager: ObjectManager {
    
    static let shared = CallManager()
    
    
    // MARK: Properties
    
    // MARK: Lifecycle
    
    // MARK: Actions
    
    func postCall(specialistId: Int, completion: @escaping (_ call: Call?, _ error: NSError?) -> Void) {
        
        var params: Parameters = [
            "specialist_id": "\(specialistId)"
        ]
        if let coordinate = LocationManager.sharedInstance.location?.coordinate {
            params["latitude"] = coordinate.latitude
            params["longitude"] = coordinate.longitude
        }
        
        request(method: .post, serverAPI: .call, parameters: params, urlParameters: nil).responseJSON { (response) in
            
            let obj: Call? = DataSource.fromJson(response.JSON()?["call"])
            completion(obj, response.error)
        }
    }
    
    func hangupCall(with id: String, completion: @escaping (_ call: Call?,_ error: NSError?) -> Void) {
        
        let urlParams = [
            "call_id": "\(id)"
        ]
        request(method: .get, serverAPI: .callHangup, parameters: nil, urlParameters: urlParams).responseJSON { (response) in
            
            let obj: Call? = DataSource.fromJson(response.JSON()?["call"])
            completion(obj, response.error)
        }
    }
}
