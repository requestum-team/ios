//
//  OfferManager.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import UIKit

class OfferManager: ObjectManager {
    
    static let shared = OfferManager()
    
    
    // MARK: Properties
    
    // MARK: Lifecycle
    
    // MARK: Actions
    
    func getOffers(completion: @escaping (_ offers: [Offer]?, _ error: NSError?) -> Void) {
        
        request(method: .get, serverAPI: .offers, parameters: nil, urlParameters: nil).responseJSON { (response) in
            
            let objs: [Offer]? = response.resultArray()
            completion(objs, response.error)
        }
    }
    
    func getOffer(with id: String, completion: @escaping (_ offer: Offer?, _ error: NSError?) -> Void) {
        
        let urlParams = [
            "id": id
        ]
        request(method: .get, serverAPI: .offer, parameters: nil, urlParameters: urlParams).responseJSON { (response) in
            
            let obj: Offer? = response.resultObject()
            completion(obj, response.error)
        }
    }
}
