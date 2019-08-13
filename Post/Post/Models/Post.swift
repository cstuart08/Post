//
//  Post.swift
//  Post
//
//  Created by Cameron Stuart on 8/12/19.
//  Copyright © 2019 Cameron Stuart. All rights reserved.
//

import Foundation

class Post: Codable {
    var text: String
    var timestamp: TimeInterval
    var username: String
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String) {
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}
