//
//  PostController.swift
//  Post
//
//  Created by Apps on 8/12/19.
//  Copyright © 2019 Apps. All rights reserved.
//

import Foundation

class PostController {
    
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    // Methods
    func fetchPosts(completion: @escaping() -> Void) {
        guard let unwrappedURL = baseURL else { return }
        let getterEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpMethod = "GET"
        request.httpBody = nil
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            if let error = error {
                print("\(error)")
                completion()
                return
            }
        
            guard let data = data else { completion(); return }
            
            let decoder = JSONDecoder()
            
            do {
                let postDictionary = try decoder.decode([String:Post].self, from: data)
                var posts: [Post] = postDictionary.compactMap({ $0.value })
                posts.sort(by: { $0.timestamp > $1.timestamp })
                self.posts = posts
                completion()
            } catch {
                print("Error: \(error)")
                completion()
                return
            }
        })
        dataTask.resume()
    }
}
