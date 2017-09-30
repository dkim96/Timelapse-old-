/*
GETTING WITH ARRAY

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

////////////////////////// UPDATING ARRAY

comuArray.append((PFUser.currentUser()?.objectId!)!)
comArray.append(postTextField.text!)
var selfuser = PFUser.currentUser()
comnArray.append(selfuser!["username"] as! String)


(Id, newArray, Key)
var query2 = PFQuery(className:"Profile") // insert className
query2.whereKey("UserID", equalTo: (Id)) // boundary, specify specific row
query2.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
    
    if let objects = objects {
        for object in objects {
            // found a row, now change its column contents
            object.setValue(newArray, forKey: Key)
            
            object.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("success")

                } else {
                    print(error?.description)
                }
            }
            
            
        }
    }
    
})

}*/


