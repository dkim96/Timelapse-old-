//
//  LoginViewController.swift
//  Timelapse
//
//  Created by CLICC User on 2/22/16.
//  Copyright © 2016 dkimo. All rights reserved.
//

import UIKit
import Parse

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var dialogView: DesignableView!
    @IBOutlet weak var user: UIButton!
    
    @IBOutlet weak var numLikes: UIButton!
    @IBAction func showLikers(sender: AnyObject) {
        // segue to a tvc with the list of likers
    }
    @IBAction func toProfile(sender: AnyObject) {
        performSegueWithIdentifier("pushToProfile", sender: self)
    }
    @IBOutlet weak var userCap: UILabel!
    @IBOutlet weak var comments: UITextView!
    
    @IBOutlet weak var postTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numComments: UIButton!
    
    
    var directUser = String()
    var directPhoto = PFFile()
    var directProfilePic = PFFile()
    var directLikes = [String]()
    var directUserComments = [String]()
    var directNameComments = [String]()
    var directComments = [String]()
    var longis:[Double] = [Double]()
    var latis:[Double] = [Double]()
    var ltitle:[String] = [String]()
    var subtitle:[String] = [String]()
    var id:[String] = [String]() // not working
    var photoId = String()
    var userId = Int()
    var photoNum = Int()
    var following = [String]()
    var follower = [String]()
    var sentId = String()
    var sentText = String()
    var likeArray = [String]()
    var comArray = [String]()
    var comuArray = [String]()
    var comnArray = [String]()
    var dataUser = [String:AnyObject]()
    var numberComments = Int() // live value of comments for views
    var picuserId = String()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var commentView: DesignableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        var fetcher = [AnyObject]()
        var obj = ["User"]
        var objs = ["String"]
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
                    fetcher = getParseData("Profile", whereKey: "UserID", equalTo: (PFUser.currentUser()?.objectId)!, objectName: obj, objectType: objs)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            print("This is run on the background queue")
            ///
            fetcher = getParseData("Profile", whereKey: "UserID", equalTo: (PFUser.currentUser()?.objectId)!, objectName: obj, objectType: objs)
            ///
            dispatch_async(dispatch_get_main_queue()) {
                print("This is run on the main queue, after the previous block")
            }
        })
    

        print(fetcher)
        print(directLikes)
        print(directComments)
        profileView.layer.cornerRadius = profileView.frame.size.width/2;
        profileView.layer.masksToBounds = true
        profileView.layer.borderWidth = 0.1;
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        numLikes.hidden = true
        self.likeArray.removeAll()
        imageView.contentMode = .ScaleAspectFit
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    
    @IBAction func postComment(sender: AnyObject) {
        
        comuArray.append((PFUser.currentUser()?.objectId!)!)
        comArray.append(postTextField.text!)
        var selfuser = PFUser.currentUser()
        comnArray.append(selfuser!["username"] as! String)
        
        
        var query2 = PFQuery(className:"photos")
        query2.whereKey("objectId", equalTo: (photoId))
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    
                    object.setValue(self.comArray, forKey: "comments")
                    object.setValue(self.comuArray, forKey: "commentsUser")
                    object.setValue(self.comnArray, forKey: "commentsName")
                    
                    
                    //object.setValue(self.statusUpdate.text, forKey: "Status")
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("success")
                            self.numberComments++
                            self.numComments.setTitle("\(self.numberComments) comments", forState:  UIControlState.Normal)
                            
                            self.sentText += "\n\(selfuser!["username"] as! String):   \(self.postTextField.text!) "
                            print(self.sentText)
                            self.comments.text = self.sentText
                            //self.numLikes.setTitle("♡ \(self.likeArray.count) likes", forState: UIControlState.Normal)
                            //self.status.text = self.statusUpdate.text
                            // The score key has been incremented
                        } else {
                            print(error?.description)
                            // There was a problem, check error.description
                        }
                    }
                    
                    
                }
            }
            
        })
        
    }
    @IBAction func revealComments(sender: AnyObject) {
        commentView.animation = "slideUp"
        commentView.delay = 0.2
        commentView.damping = 1
        commentView.animate()
        commentView.hidden = false
        
    }

    @IBAction func likePhoto(sender: AnyObject) {
        /*
        obtain objectId of user, append it to the array of likers, update the value of likes by 1.
        */
        //var i = 0
        for(var i = 0; i < directLikes.count; i++)
        {
            if(directLikes[i] == (PFUser.currentUser()?.objectId!)!){
                print("already liked")
                return
            }
        }
        directLikes.append((PFUser.currentUser()?.objectId!)!)
        
        var query2 = PFQuery(className:"photos")
        query2.whereKey("objectId", equalTo: (photoId))
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    
                    object.setValue(self.directLikes, forKey: "likers")
                    //object.setValue(self.statusUpdate.text, forKey: "Status")
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("success")
                            self.numLikes.setTitle("♡ \(self.directLikes.count) likes", forState: UIControlState.Normal)
                           // var check = self.dataUser["likers"] as! [[String]]
                            //check[check.count-1].append((PFUser.currentUser()?.objectId!)!)
                            //[data[Array(data.keys)[self.userId]]!["likers"] as! [[String]]][self.photoNum].append((PFUser.currentUser()?.objectId!)!)
                          //  increment[self.photoNum].append((PFUser.currentUser()?.objectId!)!)
                        } else {
                            print("error")
                        }
                    }
                    
                    
                }
            }
            
        })
        //theId.removeAll()
        //statusUpdate.hidden = true
        //update.hidden = true
    }
    
    
    @IBAction func button(sender: AnyObject) {
        //downloadImage()
        //deleteImage()
    }
    
    
    func getPhotoInfo(){
        
        var query2 = PFQuery(className:"photos")
        query2.getObjectInBackgroundWithId(photoId) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error == nil && gameScore != nil {
                //print(gameScore)
                if(gameScore?.objectForKey("likers") != nil){
                    var file:Array = [""]
                    file.removeAll()
                    self.likeArray = gameScore?.objectForKey("likers") as! Array
                    print("this photo has \(self.likeArray.count) likes")
                    
                }
                
            } else {
                print(error)
            }
        }
        
        var query3 = PFQuery(className:"photos")
        query3.getObjectInBackgroundWithId(photoId) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error == nil && gameScore != nil {
                //print(gameScore)
                
                if(gameScore?.objectForKey("comments") != nil){
                    self.comArray = gameScore?.objectForKey("comments") as! Array
                    print("this photo has \(self.comArray.count) comments")
                }
                
                if(gameScore?.objectForKey("commentsUser") != nil){
                    self.comuArray = gameScore?.objectForKey("commentsUser") as! Array
                }
                
                if(gameScore?.objectForKey("commentsName") != nil){
                    self.comnArray = gameScore?.objectForKey("commentsName") as! Array
                }
                
                
            } else {
                print(error)
            }
        }
        
    }
    
    
    
    func downloadImage() {
        
        var query = PFQuery(className:"photos")
        query.whereKey("objectId", equalTo: (photoId)) // boundary, specify specific row
        query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    var loadedImage = object.objectForKey("imageFile") as! PFFile
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            let file = loadedImage
                            var image: UIImage!
                            image = UIImage(data: NSData(contentsOfURL: NSURL(string: file.url!)!)!)!
                            self.imageView.image = image
                            
                        } else {
                            print(error?.description)
                        }}}}})
        
        
        user.setTitle(directUser, forState: UIControlState.Normal)
        numLikes.setTitle("♡ \(directLikes.count) likes", forState: UIControlState.Normal)
        numComments.setTitle("\(directComments.count) comments", forState:  UIControlState.Normal)
        
        let file2 = directProfilePic
        var image2: UIImage!
        image2 = UIImage(data: NSData(contentsOfURL: NSURL(string: file2.url!)!)!)!
        self.profileView.image = image2
        
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
        self.numLikes.hidden = false
        self.user.hidden = false
        self.numComments.hidden = false
        }
    }
    
    func deleteImage() {
        let query = PFQuery(className: "image")
        let object = try! query.getFirstObject()
        try! object!.delete()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
     //var DVC : ViewController = segue.destinationViewController as! ViewController
        
        
        
    //DVC.theId = sentId
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        downloadImage()
        //var specificPhotoLikes = data[Array(data.keys)[userId]]!["likers"] as! [[String]]
        //var specificPhotoComments = data[Array(data.keys)[userId]]!["comments"] as! [[String]]
        
        updateComments()
        numberComments = comArray.count
    }
    
    
    func updateComments(){
        
        if(comments.text == "")
        {
            var i = 0
            for(var i = 0; i < comnArray.count; i++)
            {
                sentText += "\n\(comnArray[i]):   \(comArray[i]) "
            }
            print("comments:  \(sentText)")
            comments.text = sentText
        }
        
    }
    
}



   