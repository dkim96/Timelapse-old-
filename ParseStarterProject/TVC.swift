
import UIKit
import Parse

class TVC: UITableViewController {
    
    var usernames = [""]
    var userids = [""]
    var isfollowing = ["":false]
    var userArray = [""]
    var followingArray = [""]
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //when the user taps on a cell
        updateParseArray((PFUser.currentUser()?.objectId)!, followingId: userids[indexPath.row], tableView: tableView, indexPath: indexPath)
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        accessParse((PFUser.currentUser()?.objectId)!, key: "Following", function: "get")
        
        var query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let users = objects {
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isfollowing.removeAll(keepCapacity: true)
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId != PFUser.currentUser()?.objectId{

                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            //print(self.usernames)
                            self.tableView.reloadData()
                            }}}}})
        
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        let followedObjectId = userids[indexPath.row]
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
        if(self.userArray.contains(followedObjectId)){
            print("addcheckmark")
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        }
        return cell
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
                        if(object.objectForKey(key) != nil || object.objectForKey(key)!.count != 0)
                        {
                            print("found a non nil array")
                            if(key == "Following"){
                                self.userArray = object.objectForKey(key) as! Array
                            }
                            if(key == "Followers"){
                                self.followingArray = object.objectForKey(key) as! Array
                            }
                        }
                        else
                        {
                            print("found a nil array, making a new one")
                        }
                    }
                    if(function == "set"){
                        
                        if(key == "Following"){
                            object.setValue(self.userArray, forKey: key)
                            object.setValue(self.userArray.count, forKey: "numFollowing")
                        }
                        if(key == "Followers"){
                            object.setValue(self.followingArray, forKey: key)
                            object.setValue(self.followingArray.count, forKey: "numFollower")
                        }
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                //print("success")
                            } else {
                                print(error?.description)
                            }}}}}})
        return true
    }
    
    func updateParseArray(userId: String, followingId: String, tableView: UITableView,indexPath: NSIndexPath)
    {
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        var notinUserArray = true
        var notinFollowingArray = true
        followingArray.removeAll()
        
        if(accessParse(followingId, key: "Followers", function: "get"))
        {
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                for(var i = 0; i < self.userArray.count; i++)
                {
                    if(self.userArray[i] == followingId)
                    {
                        print("DELETING A VALUE")
                        cell.accessoryType = UITableViewCellAccessoryType.None
                        self.userArray.removeAtIndex(i)
                        notinUserArray = false
                    }
                }
                for(var j = 0; j < self.followingArray.count; j++)
                {
                    if(self.followingArray[j] == userId)
                    {
                        self.followingArray.removeAtIndex(j)
                        notinFollowingArray = false
                    }
                }
                if(notinUserArray && notinFollowingArray)
                {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    self.userArray.append(followingId)
                    self.followingArray.append(userId)
                }
            }
        }
        // SET
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            print("arrays set to parse")
            print(self.userArray)
            print(self.userArray.count)
            print(self.followingArray)
            self.accessParse(userId, key: "Following", function: "set")
            self.accessParse(followingId, key: "Followers", function: "set")
            print("stop")
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}
