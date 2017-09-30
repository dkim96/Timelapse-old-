//
//  globalFunctions.swift
//  Timelapse
//
//  Created by CLICC User on 3/4/16.
//  Copyright © 2016 dkimo. All rights reserved.
//

import UIKit
import Parse

class globalFunctions: NSObject {


}

func test()
{
    print("TEST")
}

func getParseData(className: String, whereKey: String, equalTo: String, objectName: [String], objectType: [String]) ->[AnyObject]
{
    var returnedData = [AnyObject]()
    var query = PFQuery(className:className)
    query.whereKey(whereKey, equalTo: equalTo) // boundary, specify specific row
    query.findObjectsInBackgroundWithBlock({(objects, error) -> Void in
        if let objects = objects {
            for object in objects {
                for(var i = 0; i < objectName.count; i++)
                {
                    if(objectType[i] == "String")
                    {
                        var array1 = String() // UserID
                        array1 = object.objectForKey(objectName[i]) as! String
                        returnedData.append(array1)
                    }
                    if(objectType[i] == "Array")
                    {
                        var array1 = [AnyObject]() // UserID
                        array1 = object.objectForKey(objectName[i]) as! Array
                        returnedData.append(array1)
                    }
                    if(objectType[i] == "PFFile")
                    {
                        var array1 = PFFile() // UserID
                        array1 = object.objectForKey(objectName[i]) as! PFFile
                        returnedData.append(array1)
                    }
                    if(objectType[i] == "Double")
                    {
                        var array1 = Double() // UserID
                        array1 = object.objectForKey(objectName[i]) as! Double
                        returnedData.append(array1)
                    }
                    print("!!!!!!\(returnedData)")
                }

                

                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            //fetchedData = returnedData
                            //return returnedData
                            
                        } else {
                            print(error?.description)
                        }}
                            }}})
    print("finished")
    return returnedData
}


