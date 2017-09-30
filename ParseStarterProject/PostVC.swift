//
//  PostVC.swift
//  Timelapse
//
//  Created by CLICC User on 1/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

//NOTE: Really really dont want to reference parse twice, but until..


class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func camera(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
    var userx = String()
    var namex = String()
    var latix = Double()
    var longx = Double()
    var titlex = String()
    var subtx = String()
    var objid = String()
    var photoArray = [String]()
    var latArray = [Double]()
    var lonArray = [Double]()
    
    //var imageFile = PFFile()
    var thecaption = String()
    var photoInView = false
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func uploadLibrary(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion:nil)
        
        imageView.image = image
        photoInView = true
        
        
        
    }
    @IBAction func uploadURL(sender: AnyObject) {
        let url = urlTextfield.text
        let data = NSData(contentsOfURL: NSURL(string: url!)!)!
        //let imageFile: PFFile = PFFile(name: "poppy.jpg", data: data)
        
        var image: UIImage!
        image = UIImage(data: NSData(contentsOfURL: NSURL(string: url!)!)!)!
        imageView.image = image
        photoInView = true //loose
    }
    
    
    
    
    
    @IBOutlet weak var urlTextfield: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var captionTextfield: UITextField!
    
    func uploadImage() {
        let url = urlTextfield.text
        let data = NSData(contentsOfURL: NSURL(string: url!)!)!
        let imageFile: PFFile = PFFile(name: "poppy.jpg", data: data)
        try! imageFile.save()
        let userPhoto: PFObject = PFObject(className: "image")
        userPhoto["imageName"] = "reddit"
        userPhoto["imageFile"] = imageFile
        try! userPhoto.save()
    }
    
    func downloadImage() {
        let query = PFQuery(className: "image")
        let object = try! query.getFirstObject()
        let controller = UIAlertController(title: "Title", message: (object!["imageName"] as! String), preferredStyle: .Alert)
        let action = UIAlertAction(title: "nice!", style: .Cancel, handler: nil)
        controller.addAction(action)
        self.presentViewController(controller, animated: true, completion: nil)
        var image: UIImage!
        let file = object?.objectForKey("imageFile") as! PFFile
        image = UIImage(data: NSData(contentsOfURL: NSURL(string: file.url!)!)!)!
        imageView.image = image
    }
    
    func deleteImage() {
        let query = PFQuery(className: "image")
        let object = try! query.getFirstObject()
        try! object!.delete()
    }
    
    @IBAction func next(sender: AnyObject) {
        
        /*activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()*/
        
        if(photoInView == false)
        {
            self.displayAlert("No image uploaded", message: "Please upload an image and try again")
        }
        else{
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
            
            //imageData = imagePassed.lowestQualityJPEGNSData
            
            
            //imageFile = PFFile(name: "image.png", data: imageData!)
            thecaption = captionTextfield.text!
            
            
            
            print("!!")
            
            //let userPhoto: PFObject = PFObject(className: "photos")
            //try! userPhoto.saveInBackground()
            
            var photo = PFObject(className: "photos")
            photo["user"] = PFUser.currentUser()?.objectId
            photo["name"] = PFUser.currentUser()?.username
            photo["lati"] = latix
            photo["longi"] = longx
            photo["title"] = "Photo"
            photo["imageFile"] = PFFile(name: "image.jpg", data: imageData!)
            photo["imageCap"] = captionTextfield.text
            photo["subtitle"] = "created by " + (PFUser.currentUser()?.username)!
            photo.ACL?.setPublicWriteAccess(true)
            photo.ACL?.setPublicReadAccess(true)
            
            var competition:Array = [""]
            competition.removeAll()
            photo["arraytest"] = competition
            photo["likers"] = competition
            photo["comments"] = competition
            photo["commentsUser"] = competition
            photo["commentsName"] = competition
            
            
            photo.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    var ojId = photo.objectId
                    photo["objId"] = ojId
                    print("&&")
                    print(ojId)
                    
                    self.activityIndicator.startAnimating()
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    var notinUserArray = true
                    var notinFollowingArray = true
                    
                    if(self.accessParse((PFUser.currentUser()?.objectId!)!, key: "any", function: "get"))
                    {
                        let delay = 0.4 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            
                            print("appending")
                            self.photoArray.append(photo.objectId!)
                            self.lonArray.append(self.longx)
                            self.latArray.append(self.latix)
                        }
                    }
                    // SET
                    let delay = 1.0 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.accessParse((PFUser.currentUser()?.objectId!)!, key: "Following", function: "set")
                        print("stop")
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    }
                    
                    var query = PFQuery(className:"Profile")
                    
                    query.whereKey("UserID", equalTo: (PFUser.currentUser()?.objectId)!)
                    query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                        
                        if let objects = objects {
                            for object in objects {
                                print("got here")
                                //object.setValue(photo.objectId, forKey: "Photos")
                                //object.setValue(self.latix, forKey: "Latitude")
                                //object.setValue(self.longx, forKey: "Longitude")
                                object.incrementKey("numPosts")
                                object.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        // The score key has been incremented
                                        photo.saveInBackground()
                                        self.performSegueWithIdentifier("home", sender: self)
                                    } else {
                                        // There was a problem, check error.description
                                    }
                                }
                                
                                
                            }
                        }
                        
                    })
                    
                    
                }
            }
            // print("did this wait a while??")
            
            let delay = 5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                //print("did this wait a while??")
            }
            //print("did this wait a while??")
            
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        print(latix)
        print(longx)
        //urlTextfield.hidden = true
        // Do any additional setup after loading the view.
    }
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func accessParse(userId: String, key: String, function: String) -> Bool
    {
        var query = PFQuery(className:"Profile")
        query.whereKey("UserID", equalTo: (userId)) // boundary, specify specific row
        query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    //print("operation")
                    if(function == "get")
                    {
                        self.photoArray = object.objectForKey("Photos") as! Array
                        self.latArray = object.objectForKey("Latitude") as! Array
                        self.lonArray = object.objectForKey("Longitude") as! Array
                    }
                    if(function == "set"){
                        print("setting")
                        object.setValue(self.photoArray, forKey: "Photos")
                        
                        object.setValue(self.latArray, forKey: "Latitude")
                        
                        object.setValue(self.lonArray, forKey: "Longitude")
                        
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                //print("success")
                            } else {
                                print(error?.description)
                            }}}}}})
        return true
    }
    
    
    
    
    
    
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //var DVC : mapVC = segue.destinationViewController as! mapVC
    //DVC.poop = "a"
    //DVC.caption = thecaption
    //DVC.PFimage = imageFile
    
    //}
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
