//
//  PostController.swift
//  Post
//
//  Created by Apps on 8/12/19.
//  Copyright © 2019 Cameron Stuart. All rights reserved.
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
    
    func addNewPostWith(username: String, text: String, completion: @escaping (Bool) -> Void) {
        // initialize post
        let post = Post(text: text, username: username)  // I am not sure that I properly understand this basic initialization - like what is it doing?
        
        guard let unwrappedBaseURL = baseURL else { return }
        let postEndpoint = unwrappedBaseURL.appendingPathExtension("json")
        var postData: Data?
        
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            print("Error encoding data. \(error)")
        }
        
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        // this sends the data with the request
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending data to firebase - \(error) - \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else { return }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            
            self.posts.append(post)
            self.fetchPosts(completion: {
                completion(true) // Need more clarity on how completions work.
            })
        }
        dataTask.resume()
    }
}
