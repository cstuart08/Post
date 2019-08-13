//
//  PostListViewController.swift
//  Post
//
//  Created by Cameron Stuart on 8/12/19.
//  Copyright © 2019 Cameron Stuart. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let postController = PostController()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    @IBAction func addNewPostButton(_ sender: Any) {
        newPost()
    }
    
    
    @objc func refreshControlPulled(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "(\(post.username) | \(Date(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }
    
    func newPost() {
        let alert = UIAlertController(title: "New Post", message: "Enter Message:", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Username:"
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Text:"
        }
        
        alert.addAction(UIAlertAction(title: "Post This!", style: .default, handler: { (action) in
            guard let username = alert.textFields?[0].text,
                let text = alert.textFields?[1].text,
            !username.isEmpty,
            !text.isEmpty else { return }
            self.postController.addNewPostWith(username: username, text: text, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("success")
                    }
                } else {
                        print("failed to post")
                    }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
