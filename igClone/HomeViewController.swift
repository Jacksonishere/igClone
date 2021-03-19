//
//  HomeViewController.swift
//  igClone
//
//  Created by Jackson Lu on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {

    var posts = [PFObject]()
    var numofPosts:Int = 0
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var selectedPost:PFObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    let myRefreshControl = UIRefreshControl()

    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showCommentBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        
        //anytime you want to fire off events based on something that happens in that object/class, prob has its own delegate protocols
        commentBar.delegate = self
        
        //when you pull down on tableview enough, it dismisses keyboard
        tableView.keyboardDismissMode = .interactive
        
        //for notifications. broadcasts all the notification
        let center = NotificationCenter.default
        //add an observer for when keyboard will be dismissed notification happens. once received, it will fire off this event which will dismiss the commentbar.
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        loadPosts()
    }
    //clears comment bar text and makes it disappear.
    @objc func keyboardWillBeHidden (note: Notification){
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        
    }
    //guess doesnt fire off notification to dismiss keyboard?
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create message
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        //the selected post we referenced, we will add this comment object for the comments field
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground{ (success, error) in
            if success{
                self.tableView.reloadData()
                print("comment saved")
            }
            else{
                print("There was an error")
            }
        }
        
        //clear and dismiss
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    @objc func loadPosts(){
        numofPosts = 5
        let query = PFQuery(className: "Posts")
        // Retrieve the most recent ones
        query.order(byDescending: "createdAt")
        // Only retrieve the last ten
        query.limit = numofPosts
        // Include these other objects that are related to posts such as author, comments, AND INCLUDING the authors for comments
        query.includeKeys(["author", "comments", "comments.author"])
        //get the info from database and if successful, store that array of pfobjects, which is a dict, in our datasource.
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts.removeAll()
                for post in posts!{
                    self.posts.append(post)
                }
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    func loadMorePosts(){
        numofPosts += 5
        let query = PFQuery(className: "Posts")
        // Retrieve the most recent ones
        query.order(byDescending: "createdAt")
        // Only retrieve the last ten
        query.limit = numofPosts
        // Include the post data with each author
        query.includeKeys(["author", "comments", "comments.author"])
         //get the info from database and if successful, store that array of pfobjects, which is a dict, in our datasource.
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts.removeAll()
                for post in posts!{
                    self.posts.append(post)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //before only one section with just post cells.
    //now we need to worry about comments so there are as many sections as posts, and because a section now contains a post and all its comment, gonna be 1 + num of comments stored in posts dict.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //in each section, analagous to posts, theres going to be 1 + the number of comments for that corresponding post.
        //we reference the post object to the section number which is passed, then take the comments, cast as array of pfobjects, and return 1 + count.
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        //plus one more for the last one being the add a comment row
        return 1 + comments.count + 1
    }
    
    //As many sections as you have posts
    func numberOfSections(in tableView: UITableView) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //dont need to cast, we already know its going to be an array of pfobjects from declaration
        //do indexpath.section because now, its not just 1 section with posts.count amount of rows in that 1 section. now its multiple sections, each with their own amount of rows.
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //if the row in the section is 0, meaning its the first row in the section, it should be a postcell
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "post") as! postCell
            

            //in our posts, "author" key is referencing to an actual user. we cast it and can take user info out of that user.
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String

            //we stored a pffileobject image. now we gonna use so we need to cast
            let imageFile = post["image"] as! PFFileObject
            //file object contains a url string.
            let urlString = imageFile.url!
            //convert ot url
            let myURL = URL(string: urlString)!
            
            //use almofire to display image through the url. makes request but its an http request and apple only allows https.
            cell.myImage.af.setImage(withURL: myURL)
            return cell
        }
        //the first indexpath is always going to be the post
        //the last has to be the add comment bar
        //these two conds make up the +2 for the numofrowsinsect
        //the rest in between map to the corresponding comment count IF THERE ARE ANY. if 0 comments, first time this condition hits is when indexpath.row is 1 so this will not check
        else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            //minus one becuse first indexpath.row is always taken by the post itself.
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddComment")!
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row + 1 == posts.count && indexPath.row + 1 >= posts.count - 2{
//            print("I am calling")
//            loadMorePosts()
//        }
        if indexPath.section + 1 == posts.count{
            print("\(indexPath.row) and post count is \(posts.count)")
            loadMorePosts()
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position > (tableView.contentSize.height-100-scrollView.frame.size.height){
//            loadPosts()
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        //remember comments inside post is going to be an array of comment objects, which are pfobjects
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //commets count + 1 is the comment bar
        if indexPath.row == comments.count + 1{
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            //we need to store the selected post which is also
            selectedPost = post
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        //clear parse cache so u not logged in anymore
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
         delegate.window?.rootViewController = loginViewController
    }
    
}
