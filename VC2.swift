//
//  VC2.swift
//  Timelapse
//
//  Created by CLICC User on 1/20/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse

extension UIImage {
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/2, size.width/2)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

var data = [String:[String:AnyObject]]()

class VC2: UIViewController, FBSDKLoginButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var didPressSignUp: SpringButton!
    @IBOutlet weak var didPressLogin: SpringButton!
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    var signupActive = true
    var photoInView = false
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var imageTap: SpringImageView!
    
    @IBAction func choosePic(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion:nil)
        
        profileView.image = image
        photoInView = true
        imageTap.animation = "pop"
        imageTap.delay = 1
        imageTap.animate()
    }
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if(error != nil)
        {
            print(error.localizedDescription)
            return
        }
        if let userToken = result.token
        {
            // get user access token
            let token:FBSDKAccessToken = result.token
            print("token = \(FBSDKAccessToken.currentAccessToken().tokenString)")
            print("token = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            
            // add to Parse
            var requestParameters = ["fields": "id, email, first_name, last_name"]
            let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
            
            userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
                if(error != nil)
                {
                    print("\(error.localizedDescription)")
                    return
                }
                
                /* Work to make instant login with Facebook.
                PFUser.logInWithUsernameInBackground(self.username.text!, password: self.password.text!, block: { (user, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                
                // Logged In!
                self.performSegueWithIdentifier("login", sender: self)
                }
                })*/
                
                if(result != nil)
                {
                    let userId:String = result["id"] as! String
                    let userFirstName:String = result["first_name"] as! String
                    let userLastName:String = result["last_name"]as! String
                    let userEmail:String? = result["email"] as? String
                    
                    var user = PFUser()
                    user.username = self.username.text
                    user.password = self.password.text
                    user["name"] = "\(userFirstName) \(userLastName)"
                    user.email = userEmail
                    user["FB_id"] = userId
                    user["prof_user"] = self.username.text
                    var userProfile = "https://graph.facebook.com/\(userId)/picture?type=large"
                    let profPicUrl = NSURL(string: userProfile)
                    let profPicData = NSData(contentsOfURL: profPicUrl!)
                    if(profPicData != nil)
                    {
                        let profFileObj = PFFile(data: profPicData!)
                        user["profile_pic"] = profFileObj
                    }
                    
                    
                    
                    user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                        
                        //self.activityIndicator.stopAnimating()
                        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if error == nil {
                            
                            // Signup successful
                            //segue connector
                            var user2 = PFObject(className: "Profile")
                            user2["User"] = self.username.text
                            user2["UserID"] = user.objectId
                            user2["numFollower"] = 0;
                            user2["numFollowing"] = 0;
                            user2["numPosts"] = 0;
                            user2["Status"] = "Get money, eat chicken"
                            user2["Followers"] = []
                            user2["Following"] = []
                            user2["Photos"] = []
                            user2["Caption"] = []
                            user2["Latitude"] = []
                            user2["Longitude"] = []
                            user2["Likes"] = []
                            user2["Comments"] = []
                            user2["CommentsUser"] = []
                            user2["CommentsName"] = []
                            //let acl = PFACL()
                            //acl.getPublicWriteAccess()
                            //acl.getPublicReadAccess()
                            
                            user2.ACL?.setPublicWriteAccess(true)
                            user2.ACL?.setPublicReadAccess(true)
                            
                            user2.saveInBackgroundWithBlock { (success, error) -> Void in
                                if success {
                                    print("saved")
                                }
                            }
                            self.performSegueWithIdentifier("login", sender: self)
                            
                            
                        } else {
                            var errorMessage = "Please try again later"
                            
                            if let errorString = error!.userInfo["error"] as? String {
                                
                                errorMessage = errorString
                                
                            }
                            // why add self.?
                            self.displayAlert("Failed SignUp", message: errorMessage)
                            
                        }
                        
                    })
                    
                }
            }
            
            
            //self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        print("user is not logged out")
        
    }
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        //add a response button
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })))
        
        //make this viewable.
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func signUp(sender: AnyObject) {
        didPressSignUp.animation = "pop"
        didPressSignUp.damping = 0.1
        didPressSignUp.force = 0.5
        didPressSignUp.animate()
        
        if username.text == "" || password.text == ""  || email.text == "" || name.text == ""{
            
            displayAlert("Error in form", message: "Please enter a username and password")
            
        } else {
            // spinny thing describe
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            // creation
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            if signupActive == true {
                
                var user = PFUser()
                user.username = username.text
                user["prof_user"] = name.text
                user.password = password.text
                if(self.photoInView == false)
                {
                    self.displayAlert("No image uploaded", message: "Please upload an image and try again")
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    return
                }
                let imageData = UIImageJPEGRepresentation(self.profileView.image!, 0.5)
                user["profile_pic"] = PFFile(name: "image.jpg", data: imageData!)
                
                
                
                
                
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // Signup successful
                        //segue connector
                        var user2 = PFObject(className: "Profile")
                        user2["User"] = self.username.text
                        user2["UserID"] = user.objectId
                        user2["numFollower"] = 0;
                        user2["numFollowing"] = 0;
                        user2["numPosts"] = 0;
                        user2["Status"] = "Update your status!"
                        user2["Followers"] = []
                        user2["Following"] = []
                        user2["Photos"] = []
                        user2["Caption"] = []
                        user2["Latitude"] = []
                        user2["Longitude"] = []
                        user2["Likes"] = []
                        user2["Comments"] = []
                        user2["CommentsUser"] = []
                        user2["CommentsName"] = []
                        if(self.photoInView == false)
                        {
                            self.displayAlert("No image uploaded", message: "Please upload an image and try again")
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            return
                        }
                        let imageData = UIImageJPEGRepresentation(self.profileView.image!, 0.5)
                        user2["profile_pic"] = PFFile(name: "image.jpg", data: imageData!)
                        //let acl = PFACL()
                        //acl.getPublicWriteAccess()
                        //acl.getPublicReadAccess()
                        
                        user2.ACL?.setPublicWriteAccess(true)
                        user2.ACL?.setPublicReadAccess(true)
                        
                        user2.saveInBackgroundWithBlock { (success, error) -> Void in
                            if success {
                                print("saved")
                            }
                        }
                        self.performSegueWithIdentifier("login", sender: self)
                        
                        
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        // why add self.?
                        self.displayAlert("Failed SignUp", message: errorMessage)
                        
                    }
                    
                })
                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        // Logged In!
                        self.performSegueWithIdentifier("login", sender: self)
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("Failed Login", message: errorMessage)
                        
                    }
                    
                })
                
            }
            
        }
        
        
        
        
    }
    @IBAction func logIn(sender: AnyObject) {
        
        didPressLogin.animation = "pop"
        didPressLogin.damping = 0.1
        didPressLogin.force = 0.5
        didPressLogin.animate()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // creation
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        var errorMessage = "Please try again later"
        PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            print(user?.objectId)
            
            if user != nil {
                self.fillDataWithSingleUser((user?.objectId)!, initialCall: true, finalCall: false)
                // Logged In!
                //self.performSegueWithIdentifier("login", sender: self)
                
            } else {
                
                if let errorString = error!.userInfo["error"] as? String {
                    
                    errorMessage = errorString
                    
                }
                
                self.displayAlert("Failed Login", message: errorMessage)
                
            }
            
        })
        
    }
    
    // ?
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        var imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        var roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let watermarkImage = UIImage(named: "testprof")
        let backgroundImage = UIImage(named: "fbicon")
        
        let watermarkImage = UIImage(named: "yticon")
        watermarkImage!.rounded
        watermarkImage!.circle

        UIGraphicsBeginImageContextWithOptions(backgroundImage!.size, false, 0.0)
        backgroundImage!.drawInRect(CGRect(x: 0.0, y: 0.0, width: backgroundImage!.size.width, height: backgroundImage!.size.height))
        watermarkImage!.drawInRect(CGRect(x: backgroundImage!.size.width - watermarkImage!.size.width+8, y: backgroundImage!.size.height - watermarkImage!.size.height+8, width: watermarkImage!.size.width-15, height: watermarkImage!.size.height-15))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        profileView.image = result
        photoInView = true
        imageTap.animation = "pop"
        imageTap.delay = 1
        imageTap.animate()
        
        if(FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("not logged")
        }
        else
        {
            print("logged")
        }
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        // animate()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillDataWithSingleUser(parameterID: String, initialCall: Bool, finalCall: Bool)
    {
        /*
        1. access user profile and fill his data
        2. access his following array and for loop through these users
        3. when finish, segue to main vc.
*/
        
        var query = PFQuery(className:"Profile")
        query.whereKey("UserID", equalTo: (parameterID)) // boundary, specify specific row
        query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            if let objects = objects {
                for object in objects {
                    print("1")
                    var array1 = String() // UserID
                    var array2 = String() // User
                    var array3 = [String]() // Following
                    var array4 = [String]() // Followers
                    var array5 = String() // Status
                    var array6 = PFFile() // profile_pic
                    var array7a = [Double]() // Longitude
                    var array7b = [Double]() // Latitude
                    var array8 = [String]() // PhotoID
                    
                    var array9 = [AnyObject]() // comments
                    var array9x = [String]() // icomments
                    var array10 = [AnyObject]() // commentsUser
                    var array10x = [String]() // icomuser
                    var array11 = [AnyObject]() // commentsName
                    var array11x = [String]() // icomname
                    var array12 = [AnyObject]() // likes
                    var array12x = [String]() // ilikes
                    
                    //var array13 = [PFFile]() // imageFile
                    var array14 = [String]() // imageCap
                    
                    //var array15x = [CustomPointAnnotation]() //annots
                    var array15 = CustomPointAnnotation() //
                    
                    array1 = object.objectForKey("UserID") as! String
                    array2 = object.objectForKey("User") as! String
                    array3 = object.objectForKey("Following") as! Array
                    array4 = object.objectForKey("Followers") as! Array
                    array5 = object.objectForKey("Status") as! String
                    array6 = object.objectForKey("profile_pic") as! PFFile
                    array7a = object.objectForKey("Longitude") as! Array
                    array7b = object.objectForKey("Latitude") as! Array
                    array8 = object.objectForKey("Photos") as! Array
                    
                    var newUser = [String:AnyObject]()
                    
                    var query = PFQuery(className:"photos")
                    query.whereKey("user", equalTo: (array1)) // boundary, specify specific row
                    query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
                        if let objects = objects {
                            for object in objects {
                                print("2 \(array2)")
                                array9x = object.objectForKey("comments") as! Array
                                array9.append(array9x)
                                array10x = object.objectForKey("commentsUser") as! Array
                                array10.append(array10x)
                                array11x = object.objectForKey("commentsName") as! Array
                                array11.append(array11x)
                                array12x = object.objectForKey("likers") as! Array
                                array12.append(array12x)
                                //array13.append(object.objectForKey("imageFile") as! PFFile)
                                array14.append(object.objectForKey("imageCap") as! String)
                                
                                var longi = object.objectForKey("longi") as! Double
                                var lati = object.objectForKey("lati") as! Double
                                //array15.append(self.addAnnotationToMap(lati, lon: longi, isUser: array1.containsString((PFUser.currentUser()?.objectId)!), file: array6))
                                print("3 \(array2)")
                                
                                //print(array15x)
                                
                            }}
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                //print("firstsuc")
                                print("success2")
                                newUser.updateValue(array1, forKey: "UserID")
                                newUser.updateValue(array2, forKey: "User")
                                newUser.updateValue(array3, forKey: "Following")
                                newUser.updateValue(array4, forKey: "Followers")
                                newUser.updateValue(array5, forKey: "Status")
                                newUser.updateValue(array6, forKey: "profile_pic")
                                newUser.updateValue(array7a, forKey: "Longitude")
                                newUser.updateValue(array7b, forKey: "Latitude")
                                newUser.updateValue(array8, forKey: "Photos")
                                newUser.updateValue(array9, forKey: "comments")
                                newUser.updateValue(array10, forKey: "commentsUser")
                                newUser.updateValue(array11, forKey: "commentsName")
                                newUser.updateValue(array12, forKey: "likers")
                                //newUser.updateValue(array13, forKey: "imageFile")
                                newUser.updateValue(array14, forKey: "imageCap")
                                newUser.updateValue(array15, forKey: "annotation")
                                data.updateValue(newUser, forKey: array1)
                                newUser.removeAll()
                                //self.testFile = array6
                                if(array3.count > 0 && initialCall)
                                {
                                    print("This user has followers, accessing each one")
                                    for(var i = 0; i < array3.count; i++)
                                    {
                                        if(i == array3.count-1)
                                        {
                                        self.fillDataWithSingleUser(array3[i], initialCall: false, finalCall: true)
                                        }
                                        else{
                                            self.fillDataWithSingleUser(array3[i], initialCall: false, finalCall: false)
                                        }

                                    }
                                }
                                if(finalCall)
                                {
                                    print(data)
                                    self.performSegueWithIdentifier("login", sender: self)
                                }
                                
                                
                            } else {
                                print(error?.description)
                            }}
                    })
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            
                        } else {
                            print(error?.description)
                        }}
                }}})
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


