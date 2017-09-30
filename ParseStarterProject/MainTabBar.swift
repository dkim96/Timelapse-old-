//
//  MainTabBar.swift
//  Timelapse
//
//  Created by CLICC User on 2/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//
import Parse
import UIKit
import FBSDKLoginKit

// This class holds the data for my model.
class ModelData {
    var name = "Fred"
    var age = 50
    //var userid = PFUser.currentUser()?.objectId!
}




class MainTabBar: UITabBarController , UITabBarControllerDelegate{
    
    @IBAction func logout(sender: AnyObject) {
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            PFUser.logOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            self.navigationController?.navigationBarHidden = true
            self.performSegueWithIdentifier("logout", sender: self)
        }
    }
    
    var model = ModelData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //navigationController?.navigationBar.translucent = false
        //self.edgesForExtendedLayout.insert(UIRectEdge.None)
        
        
        
        //self.tabBarController?.navigationItem.setHidden
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        var logView = self.viewControllers![0] as! ViewController
        logView.log.append("Testing 123")
    }
    
}

