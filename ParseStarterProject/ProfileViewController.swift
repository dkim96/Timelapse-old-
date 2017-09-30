//
//  ProfileViewController.swift
//  Timelapse
//
//  Created by CLICC User on 1/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class ProfileViewController: UIViewController {
    
    var theId = String()
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var numPosts: UILabel!
    @IBOutlet weak var numFollower: UILabel!
    @IBOutlet weak var numFollowing: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var update: UIButton!
    
    @IBOutlet weak var statusUpdate: UITextField!
    
    @IBAction func updatex(sender: AnyObject) {
        
        
        var query2 = PFQuery(className:"Profile")
        query2.whereKey("UserID", equalTo: (theId))
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    object.setValue(self.statusUpdate.text, forKey: "Status")
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("success")
                            self.status.text = self.statusUpdate.text
                            // The score key has been incremented
                        } else {
                            print("error")
                            // There was a problem, check error.description
                        }
                    }
                    
                    
                }
            }
            
        })
        theId.removeAll()
        statusUpdate.hidden = true
        update.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView.layer.cornerRadius = profileView.frame.size.width/2;
        profileView.layer.masksToBounds = true
        profileView.layer.borderWidth = 0.1;
        
        
        /*var selfuser = PFUser.currentUser()
        
        var img = selfuser!["profile_pic"] as! PFFile
        var image: UIImage!
        image = UIImage(data: NSData(contentsOfURL: NSURL(string: img.url!)!)!)!
        profileView.image = image*/
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        action()
        
        var query2 = PFQuery(className:"Profile")
        query2.whereKey("UserID", equalTo: (theId))
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
    
    func action()
    {
        statusUpdate.hidden = true
        update.hidden = true
        if(theId.isEmpty || theId == (PFUser.currentUser()?.objectId!)!)
        {
            print("Self Profile Called")
            theId = (PFUser.currentUser()?.objectId!)!
            statusUpdate.hidden = false
            update.hidden = false
        }
        else{
            print("theId is not the user, \(theId)")
        }
        //let model = (self.tabBarController as! MainTabBar).model
        //theId = model.userid!
        
        
        
        //print("!")
        //print(theId)
        /*
        name.hidden = true
        status.hidden = true
        numPosts.hidden = true
        numFollower.hidden = true
        numFollowing.hidden = true*/
        
        var query = PFQuery(className:"Profile")
        
        
        
        query.whereKey("UserID", equalTo: (theId))
        query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            //print("!")
            if let objects = objects {
                for object in objects {
                    //print("got here")
                    self.name.text = object["User"] as! String
                    self.status.text = object["Status"] as! String
                    
                    let x : Int = object["numPosts"] as! Int
                    let y : Int = object["numFollowing"] as! Int
                    let z : Int = object["numFollower"] as! Int
                    self.numPosts.text = String(x)
                    self.numFollowing.text = String(y)
                    self.numFollower.text = String(z)
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // The score key has been incremented
                        } else {
                            // There was a problem, check error.description
                        }
                    }
                    
                    
                }
            }
            
        })
        
        name.hidden = false
        status.hidden = false
        numPosts.hidden = false
        numFollower.hidden = false
        numFollowing.hidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
