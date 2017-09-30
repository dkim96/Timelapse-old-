//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation
import FBSDKCoreKit

extension UIImage{
    
    class func roundedRectImageFromImage(image:UIImage,imageSize:CGSize,cornerRadius:CGFloat)->UIImage{
        UIGraphicsBeginImageContextWithOptions(imageSize,false,0.0)
        let bounds=CGRect(origin: CGPointZero, size: imageSize)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        image.drawInRect(bounds)
        let finalImage=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
    
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dataX = [String:[String:AnyObject]]()
    
    var annotationData = [[String:AnyObject]]()
    
    var testFile = PFFile()
    
    var toDirectory = false
    var toPhoto = false
    var toProfile = false
    var allAnnotations = [String]()
    var matchingId = [String]()
    var sentPhotoId = String()
    var usernames = [""]
    var userids = [""]
    var isfollowing = ["":false]
    var longis:[Double] = [Double]()
    var latis:[Double] = [Double]()
    var user:[String] = [String]()
    var ltitle:[String] = [String]()
    var subtitle:[String] = [String]()
    var id:[String] = [String]() // not working
    var follower:[String] = [String]() // list of all
    var following:[String] = [String]() // list of all
    var following2:[String] = [String]() // people the current user follows
    var usedid:[String] = [String]() // pins on the map
    var objectIds:[String] = [String]() // photos' objectIds
    var log = [String]()
    
    
    var folArray = [String]()
    var photoIdArray = [String]()
    var userIdArray = [AnyObject]()
    var lonArray = [Double]()
    var latArray = [Double]()
    
    var sentUserId = Int()
    var sentPhotoNum = Int()
    
    /*
    NO. Create a dictionary that store all information for other photovc, profile, and relevant search.
    
    */
    
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func refresh(sender: AnyObject) {
        displayParsePins()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pops = [CLLocationCoordinate2D]()
    var size = 1;
    
    override func viewDidAppear(animated: Bool) {
        //refresh()
        addAnnotationToMap()
                print(data)
        //fillDataWithSingleUser((PFUser.currentUser()?.objectId)!, initialCall: true, finalCall: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            //print(data[(PFUser.currentUser()?.objectId)!]!["likers"])
            //var dataArray = Array(data.keys)
            for(var i = 0; i < Array(self.dataX.keys).count; i++)
            {
                print(self.dataX[Array(self.dataX.keys)[i]])
                //print(data[Array(data.keys)[i]]!["annotation"])
            }
        }
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 400)
        
        let latitude:CLLocationDegrees = 40.095181
        let longitude:CLLocationDegrees = -95.006424 // more neg = <-
        let latDelta:CLLocationDegrees = 70
        let lonDelta:CLLocationDegrees = 70
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 1
        mapView.addGestureRecognizer(uilpgr)
        mapView.delegate = self
        
        //updateParseArray()
        
        
        
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters:["fields": "first_name"])
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                print("Friends are : \(result)")
                if let friendObjects = result["data"] as? [NSDictionary] {
                    for friendObject in friendObjects {
                        print(friendObject["id"] as! NSString)
                        print(friendObject["first_name"] as! NSString)
                        //BUILD OFF OF THIS!
                    }
                }
            }
            else {
                print("Error Getting Friends"); //\(error)
            }
        }
    }
    
    func refresh()
    {
        /* GOAL: delete all annotations, update info
        */
    }
    
    
    func loadArrays()
    {
        
        
        // searching each photo and appending it to arrays
        var query2:PFQuery = PFQuery(className: "photos")
        query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            self.longis = [Double]()
            self.latis = [Double]()
            self.user = [String]()
            self.ltitle = [String]()
            self.subtitle = [String]()
            self.id = [String]()
            for messageObject in objects! {
                let messageText:Double? = (messageObject as! PFObject)["longi"] as? Double
                if messageText != nil {
                    self.longis.append(messageText!)
                }
                let latiText:Double? = (messageObject as! PFObject)["lati"] as? Double
                if latiText != nil {
                    self.latis.append(latiText!)
                }
                let messageText1:String? = (messageObject as! PFObject)["user"] as? String
                if messageText1 != nil {
                    self.user.append(messageText1!)
                }
                let messageText2:String? = (messageObject as! PFObject)["title"] as? String
                if messageText2 != nil {
                    self.ltitle.append(messageText2!)
                }
                let messageText3:String? = (messageObject as! PFObject)["subtitle"] as? String
                if messageText3 != nil {
                    self.subtitle.append(messageText3!)
                }
            }
        })
        
        //searching each follower and appending
        var query3:PFQuery = PFQuery(className: "followers")
        query3.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
            
            self.follower = [String]()
            self.following = [String]()
            self.id = [String]()
            
            for messageObject in objects! {
                let messageText2:String? = (messageObject as! PFObject)["follower"] as? String
                if messageText2 != nil {
                    self.follower.append(messageText2!)
                }
                let messageText3:String? = (messageObject as! PFObject)["following"] as? String
                if messageText3 != nil {
                    self.following.append(messageText3!)
                }
                let messageText4:String? = (messageObject as! PFObject)["objectId"] as? String
                if messageText4 != nil {
                    self.id.append(messageText4!)
                }
                
                
            }
            self.following2.append((PFUser.currentUser()?.objectId)!)
            var index: Int
            for index = 0; index < self.follower.count; ++index {
                if self.follower[index] == PFUser.currentUser()?.objectId{
                    self.following2.append(self.following[index])
                }
                
            }
            
            
        })
        
        //self.objectIds = [""]
        self.objectIds.removeAll()
        var queryx = PFQuery(className:"photos")
        queryx.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil {
                // The find succeeded.
                print("Retrieved \(objects!.count) scores.")
                // Do something with the found objects
                for object in objects! {
                    self.objectIds.append(object.objectId!! as String)
                    //print("^")
                }
                //print(self.objectIds)
            } else {
                //print("!!!! \(error)")
            }
            
        })
        
        
    }
    
    
    func displayParsePins()
    {
        //allAnnotations.removeAll()
        loadArrays()
        // print("objIds at ppins")
        //print(objectIds)
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            var index: Int
            var index2: Int
            var index3: Int
            //print("display parse pins*** f2 ud l")
            //print(following2.count)
            //print(following2)
            //print(usedid.count)
            //print(id.count)
            
            // FIX FIX FIX
            print("array out of index point")
            for index = 0; index < self.latis.count; ++index {
                var test1 = true
                var test2 = false
                
                // repeat check
                for index2 = 0; index2 < self.usedid.count; ++index2 {
                    if self.objectIds[index] == self.usedid[index2]{
                        test1 = false
                        break
                    }
                    
                }
                
                for index3 = 0; index3 < self.following2.count; ++index3 {
                    if self.user[index] == self.following2[index3]{
                        test2 = true
                        break
                    }
                    
                }
                if(test1 && test2)
                {
                    var annotationView:MKPinAnnotationView!
                    let latitude:CLLocationDegrees = self.latis[index]
                    let longitude:CLLocationDegrees = self.longis[index]
                    let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                    var pointAnnoation:CustomPointAnnotation!
                    
                    pointAnnoation = CustomPointAnnotation()
                    if(self.user[index] == PFUser.currentUser()?.objectId){
                        pointAnnoation.pinCustomImageName = "set2"
                    }
                    else{
                        pointAnnoation.pinCustomImageName = "High income"
                    }
                    
                    pointAnnoation.coordinate = coordinate
                    pointAnnoation.title = self.ltitle[index]
                    pointAnnoation.subtitle = self.subtitle[index]
                    annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
                    self.mapView.addAnnotation(annotationView.annotation!)
                    self.usedid.append(self.objectIds[index])
                    
                    self.allAnnotations.append(pointAnnoation.description)
                    self.matchingId.append(self.objectIds[index])
                    //print("check")
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    
    func coordinateRegionForCoordinates(coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var rect: MKMapRect = MKMapRectNull
        for coord in coords {
            let point: MKMapPoint = MKMapPointForCoordinate(coord)
            rect = MKMapRectUnion(rect, MKMapRectMake(point.x, point.y, 0, 0))
        }
        return MKCoordinateRegionForMapRect(rect)
    }
    
    func zoomToFitMapAnnotations(aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in mapView.annotations as! [MKAnnotation]{
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        
        var span1 = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 3
        var span2 = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 3
        print("\(span1) and \(span2)")
        if(span1 <= 180 && span2 <= 180)
        {
            region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 3
            region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 3
        }
        else{
            region.span.latitudeDelta = 180
            region.span.longitudeDelta = 180
        }
        region = aMapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        print("?")
        if(gestureRecognizer.state == UIGestureRecognizerState.Began) //YASSSS
        {
            var annotationView:MKPinAnnotationView!
            var touchPoint = gestureRecognizer.locationInView(self.mapView)
            var newCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            var pointAnnoation:CustomPointAnnotation!
            
            pointAnnoation = CustomPointAnnotation()
            pointAnnoation.pinCustomImageName = "High income"
            pointAnnoation.coordinate = newCoordinate
            pops.append(pointAnnoation.coordinate)
            size++
            //pointAnnoation.title = "New Place"
            //pointAnnoation.subtitle = "One day I'll go here..."
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
            self.mapView.addAnnotation(annotationView.annotation!)
            zoomToFitMapAnnotations(mapView)
        }
    }
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
            
            let reuseIdentifier = "pin"
            
            var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
            if v == nil {
                v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                v!.canShowCallout = false // title subtitle show
            }
            else {
                v!.annotation = annotation
            }
            
            let customPointAnnotation = annotation as! CustomPointAnnotation
            v!.image = customPointAnnotation.customUIImage
            print("VIMAGE: \(v!.image)")
            
            if annotation is MKUserLocation{
                return nil
            }
            return v
            }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView annotationView: MKAnnotationView) {
        print("deselect annot")
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView annotationView: MKAnnotationView) {
        print("clicked annot")
        annotationView.canShowCallout = false
        mapView.deselectAnnotation(annotationView.annotation, animated: false)
        var index = Int()
        var val = false
        
        
        
        for(var i = 0; i < Array(data.keys).count; i++)
        {
            var check = data[Array(data.keys)[i]]!["annotation"] as! CustomPointAnnotation
            //print(check[0])
            
            if(((annotationView.annotation?.description == (check.description)))){
                var check2 = data[Array(data.keys)[i]]!["Photos"] as! [String]
                
                print(annotationView.annotation?.description)
                print(check.description)
                //print("Value checker: \(check2[j])")
                //print(j)
                print(i)
                
                sentPhotoId = check2[check2.count-1]
                sentPhotoNum = check2.count-1
                sentUserId = i
                val = true
                toDirectory = true
                print("prep segue")
                performSegueWithIdentifier("modalPhoto", sender: self)
                break
            }
        }
        if(val == false){
            print("error no match found")
            return
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(toDirectory){
            print("prep segue")
            var DVC : PhotoViewController = segue.destinationViewController as! PhotoViewController
            DVC.photoId = sentPhotoId
            DVC.userId = sentUserId
            DVC.photoNum = sentPhotoNum
            DVC.follower = follower
            DVC.following = following
            toDirectory = false
            DVC.dataUser = data[Array(data.keys)[sentUserId]]!
            
            DVC.directUser = data[Array(data.keys)[sentUserId]]!["User"] as! String
            //DVC.directPhoto = (data[Array(data.keys)[sentUserId]]!["imageFile"] as! [PFFile])[sentPhotoNum]
            DVC.directProfilePic = data[Array(data.keys)[sentUserId]]!["profile_pic"] as! PFFile
            DVC.directLikes = (data[Array(data.keys)[sentUserId]]!["likers"] as! [[String]])[sentPhotoNum]
            DVC.directUserComments = (data[Array(data.keys)[sentUserId]]!["commentsUser"] as! [[String]])[sentPhotoNum]
            DVC.directNameComments = (data[Array(data.keys)[sentUserId]]!["commentsName"] as! [[String]])[sentPhotoNum]
            DVC.directComments = (data[Array(data.keys)[sentUserId]]!["comments"] as! [[String]])[sentPhotoNum]
            
            //print(check[0])
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize.width = 200
        self.scrollView.contentSize.height = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()}
    
    // access user following array and get an array of user and following ids
    // for each user and following
    // grab most recent photo id, location, put it into an annotation and post
    
    func fillDataAndSetPins()
    {
        var query = PFQuery(className:"Profile")
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
                    var array8 = [String]() // Photos
                    
                    var array9 = [AnyObject]() // comments
                    var array9x = [String]() // icomments
                    var array10 = [AnyObject]() // commentsUser
                    var array10x = [String]() // icomuser
                    var array11 = [AnyObject]() // commentsName
                    var array11x = [String]() // icomname
                    var array12 = [AnyObject]() // likes
                    var array12x = [String]() // ilikes
                    
                    var array13 = [PFFile]() // imageFile
                    var array14 = [String]() // imageCap
                    
                    var array15x = [CustomPointAnnotation]() //annots
                    var array15 = [CustomPointAnnotation]() //
                    
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
                                array13.append(object.objectForKey("imageFile") as! PFFile)
                                array14.append(object.objectForKey("imageCap") as! String)
                                
                                var longi = object.objectForKey("longi") as! Double
                                var lati = object.objectForKey("lati") as! Double
                                //array15.append(self.addAnnotationToMap(lati, lon: longi, isUser: array1.containsString((PFUser.currentUser()?.objectId)!), file: array6))
                                print("3 \(array2)")
                                
                                print(array15x)
                                
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
                                newUser.updateValue(array13, forKey: "imageFile")
                                newUser.updateValue(array14, forKey: "imageCap")
                                newUser.updateValue(array15, forKey: "annotation")
                                self.dataX.updateValue(newUser, forKey: array1)
                                newUser.removeAll()
                                self.testFile = array6
                                
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
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        print(self.mapView.region.span)
        print(self.mapView.region.center)
        }
    
    func fillDataWithSingleUser(parameterID: String, initialCall: Bool, finalCall: Bool)
    {
        /*
        1. access user profile and fill his data
        2. access his following array and for loop through these users
        3. when finish, segue to main vc.
        */
        annotationData.removeAll()
        data.removeAll()
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
                                if(array7b.count != 0)
                                {
                                self.appendAnnotationData(array7b, Longitude: array7a, profile_pic: array6, which: "mostRecent")
                                }
                                newUser.removeAll()
                                // function receives multiple arrays and appends it to annotationData according to pref
                                //seperate add function adds these specified valeus to map.
                                
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
                                    self.applyAnnotationData()
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
    
    // function receives multiple arrays and appends it to annotationData according to pref
    func appendAnnotationData(Latitude: [Double], Longitude: [Double], profile_pic: PFFile, which: String)
    {
        if(which == "mostRecent")
        {
            var newEntry = [String:AnyObject]()
            newEntry.updateValue(Latitude[Latitude.count-1], forKey: "Latitude")
            newEntry.updateValue(Longitude[Longitude.count-1], forKey: "Longitude")
            newEntry.updateValue(profile_pic, forKey: "profile_pic")
            annotationData.append(newEntry)
        }
    }
    //seperate add function adds these specified valeus to map.
    func applyAnnotationData()
    {
        // delete all old annotations
        print("There should be \(annotationData.count) pins")
        for(var i = 0; i < annotationData.count; i++)
        {
            var image: UIImage!
            image = UIImage(data: NSData(contentsOfURL: NSURL(string: annotationData[i]["profile_pic"]!.url!!)!)!)!
            let backgroundImage = UIImage(named: "lightblue")
            let watermarkImage = UIImage.roundedRectImageFromImage(image, imageSize: CGSize(width: 30, height: 30), cornerRadius: CGFloat(15))
            UIGraphicsBeginImageContextWithOptions(backgroundImage!.size, false, 0.0)
            backgroundImage!.drawInRect(CGRect(x: 0.0, y: 0.0, width: 50, height: 50))
            watermarkImage.drawInRect(CGRect(x: 5, y: 5, width: 40, height: 40))
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            var annotationView:MKPinAnnotationView!
            let latitude:CLLocationDegrees = annotationData[i]["Latitude"]! as! CLLocationDegrees
            let longitude:CLLocationDegrees = annotationData[i]["Longitude"]! as! CLLocationDegrees
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var pointAnnoation:CustomPointAnnotation!
            pointAnnoation = CustomPointAnnotation()
            pointAnnoation.customUIImage = result
            pointAnnoation.coordinate = coordinate
            pointAnnoation.title = "."
            pointAnnoation.subtitle = "."
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
            data[Array(data.keys)[i]]?.updateValue(pointAnnoation, forKey: "annotation")
            self.mapView.addAnnotation(pointAnnoation)
            self.allAnnotations.append(pointAnnoation.description)
        }
    }
    
    func addAnnotationToMap()
    {
        for(var i = 0; i < Array(data.keys).count; i++)
        {
            var numPhotos = data[Array(data.keys)[i]]!["Photos"]
            print("numPhotos:  \(numPhotos!.count)")
            if(numPhotos!.count != 0)
            {
                // most recent photo
                var lat = (data[Array(data.keys)[i]]!["Latitude"] as! [Double])[numPhotos!.count - 1]
                var lon = (data[Array(data.keys)[i]]!["Longitude"] as! [Double])[numPhotos!.count - 1]
                var file = data[Array(data.keys)[i]]!["profile_pic"]
                print(file)
                //print(data[Array(data.keys)[i]]!["annotation"])
                
                //let file = file
                var image: UIImage!
                image = UIImage(data: NSData(contentsOfURL: NSURL(string: file!.url!!)!)!)!
                let backgroundImage = UIImage(named: "lightblue")
                let watermarkImage = UIImage.roundedRectImageFromImage(image, imageSize: CGSize(width: 30, height: 30), cornerRadius: CGFloat(15))
                UIGraphicsBeginImageContextWithOptions(backgroundImage!.size, false, 0.0)
                backgroundImage!.drawInRect(CGRect(x: 0.0, y: 0.0, width: 50, height: 50))
                watermarkImage.drawInRect(CGRect(x: 5, y: 5, width: 40, height: 40))
                
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                var annotationView:MKPinAnnotationView!
                let latitude:CLLocationDegrees = lat as CLLocationDegrees
                let longitude:CLLocationDegrees = lon as CLLocationDegrees
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                var pointAnnoation:CustomPointAnnotation!
                pointAnnoation = CustomPointAnnotation()
                pointAnnoation.customUIImage = result
                pointAnnoation.coordinate = coordinate
                pointAnnoation.title = "."
                pointAnnoation.subtitle = "."
                annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
                data[Array(data.keys)[i]]?.updateValue(pointAnnoation, forKey: "annotation")
                self.mapView.addAnnotation(pointAnnoation)
                self.allAnnotations.append(pointAnnoation.description)
            }
        }
    }
    
}


