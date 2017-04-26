//
//  Offer.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation

import ObjectMapper
import SwiftKVC

public class Offer: Mappable, Object {
    
    // MARK: Properties
    
    var id: String?
    var title: String?
    var content: String?
    var image: String?
    var published: Date?
    var publishAt: Date?
    var expireAt: Date?
    var state: String?
    
    
    // MARK: Mappable
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        content <- map["content"]
        image <- map["image"]
        published <- (map["published"], ISO8601DateTransform())
        publishAt <- (map["publish_at"], ISO8601DateTransform())
        expireAt <- (map["expire_at"], ISO8601DateTransform())
        state <- map["state"]
    }
}
