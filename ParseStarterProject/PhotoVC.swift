//
//  PhotoVC.swift
//  Timelapse
//
//  Created by CLICC User on 1/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PhotoVC: UIViewController {
    //@IBOutlet weak var userLabel: UILabel!
    
    var following = [String]()
    var follower = [String]()
    var sentId = String()
    var sentText = String()
    var likeArray = [String]()
    var comArray = [String]()
    var comuArray = [String]()
    var comnArray = [String]()
    
    var picuserId = String()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var user: UIButton!
    
    @IBOutlet weak var numLikes: UIButton!
    @IBAction func showLikers(sender: AnyObject) {
        // segue to a tvc with the list of likers
    }
    @IBAction func toProfile(sender: AnyObject) {
        performSegueWithIdentifier("pushToProfile", sender: self)
    }
    @IBOutlet weak var userCap: UILabel!
    
    @IBAction func likePhoto(sender: AnyObject) {
        /*
        obtain objectId of user, append it to the array of likers, update the value of likes by 1.
        */
        var i = 0
        for(var i = 0; i < likeArray.count; i++)
        {
            if(likeArray[i] == (PFUser.currentUser()?.objectId!)!){
                print("already liked")
                return
            }
        }
        likeArray.append((PFUser.currentUser()?.objectId!)!)
        
        var query2 = PFQuery(className:"photos")
        query2.whereKey("objectId", equalTo: (photoId))
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    
                    object.setValue(self.likeArray, forKey: "likers")
                    //object.setValue(self.statusUpdate.text, forKey: "Status")
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("success")
                            self.numLikes.setTitle("♡ \(self.likeArray.count) likes", forState: UIControlState.Normal)
                            //self.status.text = self.statusUpdate.text
                            // The score key has been incremented
                        } else {
                            print("error")
                            // There was a problem, check error.description
                        }
                    }
                    
                    
                }
            }
            
        })
        //theId.removeAll()
        //statusUpdate.hidden = true
        //update.hidden = true
    }
    
    @IBOutlet weak var comments: UITextView!
    
    @IBOutlet weak var postTextField: UITextField!
    
    @IBAction func postComment(sender: AnyObject) {
        //objId, append id, and comment, update comment value.
        
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
    
    var longis:[Double] = [Double]()
    var latis:[Double] = [Double]()
    //var user:[String] = [String]()
    var ltitle:[String] = [String]()
    var subtitle:[String] = [String]()
    var id:[String] = [String]() // not working
    
    
    var photoId = String()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func button(sender: AnyObject) {
        //downloadImage()
        //deleteImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        comments.hidden = true
        
        userCap.hidden = true
        self.likeArray.removeAll()
        
        //print("^^^")
        getPhotoInfo()
        
        
        //print(photoId)
        imageView.contentMode = .ScaleAspectFit
        //uploadImage()
        downloadImage()
        //print("likesArray")
        //print(likeArray)
        
        //numLikes.setTitle("♡ \(likeArray.count) likes", forState: UIControlState.Normal)
        // Do any additional setup after loading the view.
        
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
        query.getObjectInBackgroundWithId(photoId) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error == nil && gameScore != nil {
                //print(gameScore)
                if(gameScore?.objectForKey("imageFile") != nil){
                    let file = gameScore?.objectForKey("imageFile") as! PFFile
                    //let file = gameScore!["imageFile"] as! PFFile
                    var image: UIImage!
                    
                    image = UIImage(data: NSData(contentsOfURL: NSURL(string: file.url!)!)!)!
                    self.imageView.image = image
                    
                    
                }
                self.user.setTitle(gameScore?.objectForKey("name") as? String, forState: UIControlState.Normal)
                self.picuserId = (gameScore?.objectForKey("user") as? String)!
                self.sentId = gameScore?.objectForKey("user") as! String
                var doub = gameScore?.objectForKey("lati") as! Double
                //print(doub)
                self.userCap.text = gameScore?.objectForKey("imageCap") as! String
                //self.userLabel.hidden = false
                self.userCap.hidden = false
                //self.userLoc.hidden = false
                
            } else {
                print(error)
            }
        }
        
        
        
        var query2 = PFQuery(className:"photos")
        query2.getObjectInBackgroundWithId(photoId) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error == nil && gameScore != nil {
                //print(gameScore)
                if(gameScore?.objectForKey("arraytest") != nil){
                    var file:Array = [""]
                    file.removeAll()
                    file = gameScore?.objectForKey("arraytest") as! Array
                    //print("the element of the array is \(file[0])")
                    
                }
                
            } else {
                print(error)
            }
        }
        //let query = PFQuery(className: "photo")
        
        /*
        let object = try! query.getFirstObject()
        let controller = UIAlertController(title: "Title", message: (object!["imageName"] as! String), preferredStyle: .Alert)
        let action = UIAlertAction(title: "nice!", style: .Cancel, handler: nil)
        controller.addAction(action)
        self.presentViewController(controller, animated: true, completion: nil)
        */
        // let file = object?.objectForKey("imageFile") as! PFFile
        //image = UIImage(data: NSData(contentsOfURL: NSURL(string: file.url!)!)!)!
        //imageView.image = image
        
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
        var DVC : ProfileViewController = segue.destinationViewController as! ProfileViewController
        DVC.theId = sentId
        
    }
    
    override func viewDidAppear(animated: Bool) {
        numLikes.setTitle("♡ \(likeArray.count) likes", forState: UIControlState.Normal)
        updateComments()
        numLikes.hidden = false
        comments.hidden = false
        
        var query2 = PFQuery(className:"Profile")
        query2.whereKey("UserID", equalTo: picuserId)
        print("picuserid \(picuserId)")
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    
                    let file = object.objectForKey("profile_pic") as! PFFile
                    var image: UIImage!
                    
                    image = UIImage(data: NSData(contentsOfURL: NSURL(string: file.url!)!)!)!
                    self.profileView.image = image
                    
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("success")
                            // The score key has been incremented
                        } else {
                            print("error")
                            // There was a problem, check error.description
                        }
                    }
                    
                    
                }
            }
            
        })
    }
    
    func updateComments(){
        
        if(comments.text == "")
        {
            var i = 0
            for(var i = 0; i < comnArray.count; i++)
            {
                sentText += "\n\(comnArray[i]):   \(comArray[i]) "
            }
            print(sentText)
            comments.text = sentText
        }
        
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
