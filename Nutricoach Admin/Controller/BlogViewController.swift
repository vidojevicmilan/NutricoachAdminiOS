//
//  BlogViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 4/20/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase

class BlogViewController: UITableViewController {
    
    var articles = [(id: String, article: Article)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func fetchArticles() {
        Database.database().reference().child("articles").observe(.childAdded) { (snapshot) in
            let id = snapshot.key
            let title = snapshot.childSnapshot(forPath: "title").value as! String
            let text = snapshot.childSnapshot(forPath: "text").value as! String
            var image : UIImage!
            Storage.storage().reference().child("articles/\(id).png").getData(maxSize: 1024*1024*4, completion: { (data, err) in
                if err != nil {
                    image = UIImage(named: "gallery")
                } else {
                    image = UIImage(data: data!)
                }
                let article = Article(title: title, text: text, thumbnail: image)
                self.articles.insert((id, article), at: 0)
                self.articles.sort(by: { (arg0, arg1) -> Bool in
                    return(arg0.id > arg1.id)
                })
                self.tableView.reloadData()
            })
        }
        
        Database.database().reference().child("articles").observe(.childChanged) { (snap) in
            let id = snap.key
            let title = snap.childSnapshot(forPath: "title").value as! String
            let text = snap.childSnapshot(forPath: "text").value as! String
            var image : UIImage!
            
            Storage.storage().reference().child("articles/\(id).png").getData(maxSize: 1024*1024*4, completion: { (data, err) in
                if err != nil {
                    image = UIImage(named: "gallery")
                } else {
                    image = UIImage(data: data!)
                }
                
                for i in 0..<self.articles.count {
                    if self.articles[i].id == id {
                        self.articles[i].article = Article(title: title, text: text, thumbnail: image)
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.article = articles[indexPath.row].article
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let articleVC = ArticleViewController()
        articleVC.article = articles[indexPath.row].article
        articleVC.articleId = articles[indexPath.row].id
        articleVC.isCalledForEdit = true
        navigationController?.pushViewController(articleVC, animated: true)
    }
    
    @IBAction func newArticleButtonHandle(_ sender: Any) {
        let articleVC = ArticleViewController()
        articleVC.isCalledForEdit = false
        navigationController?.pushViewController(articleVC, animated: true)
    }
}
