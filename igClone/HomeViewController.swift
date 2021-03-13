//
//  HomeViewController.swift
//  igClone
//
//  Created by Jackson Lu on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var posts = [PFObject]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 400
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        // Retrieve the most recent ones
        query.order(byDescending: "createdAt")

        // Only retrieve the last ten
        query.limit = 20

        // Include the post data with each author
        query.includeKey("author")
        
        //get the info from database and if successful, store that array of pfobjects, which is a dict, in our datasource.
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "post") as! postCell
        
        //dont need to post, we already know its going to be an array of pfobjects from declaration
        let post = posts[indexPath.row]
        
        //in our posts, "author" key is referencing to an actual user. we cast it and can take user info out of that user.
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        //we stored a pffileobject image. now we gonna use so we need to cast
        let imageFile = post["image"] as! PFFileObject
        //file object contains a url string.
        let urlString = imageFile.url!
        //convert ot url
        let myURL = URL(string: urlString)!
        
        //use almofire to display image through the url. makes request but its an http request and apple only allows https.
        print("\(myURL)")
        cell.myImage.af.setImage(withURL: myURL)
        
        return cell
    }
    
    
    
}
