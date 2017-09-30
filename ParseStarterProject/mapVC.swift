//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation


class mapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var PFimage = PFFile()
    var caption = String()
    var poop = String()
    var lati = Double()
    var longi = Double()
    
    @IBOutlet weak var next: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func confirmLocation(sender: AnyObject) {
    }
    
    @IBAction func post(sender: AnyObject) { // now next
        self.performSegueWithIdentifier("next", sender: self)
    }
    
    var pops = [CLLocationCoordinate2D]()
    var size = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        next.hidden = true
        //print(poop)
        let latitude:CLLocationDegrees = 40.095181
        let longitude:CLLocationDegrees = -95.006424 // more neg = <-
        let latDelta:CLLocationDegrees = 70
        let lonDelta:CLLocationDegrees = 70
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        pops.append(location)
        mapView.setRegion(region, animated: false)
        
        // Regular annotations break the program
        
        /*let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Niagra Falls"
        annotation.subtitle = "One day I'll go here..."
        mapView.addAnnotation(annotation)*/
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 1
        mapView.addGestureRecognizer(uilpgr)
        
        
        if(size < pops.count){
            print("true")
            //zoomToFitMapAnnotations(map)
            //map.setRegion(coordinateRegionForCoordinates(pops), animated: true)
        }
        
        mapView.delegate = self
        
        
        
        /*
        Access a PFUser, check if he has coordinates, access and place them on map.
        */
        
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
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 3
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 3
        region = aMapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.Began) //YASSSS
        {
            print("Gesture Recognized")
            var annotationView:MKPinAnnotationView!
            var touchPoint = gestureRecognizer.locationInView(self.mapView)
            var newCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            var pointAnnoation:CustomPointAnnotation!
            
            pointAnnoation = CustomPointAnnotation()
            pointAnnoation.pinCustomImageName = "High income"
            
            
            pointAnnoation.coordinate = newCoordinate
            pops.append(pointAnnoation.coordinate)
            size++
            pointAnnoation.title = "New Place"
            pointAnnoation.subtitle = "One day I'll go here..."
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
            
            lati = newCoordinate.latitude
            longi = newCoordinate.longitude
            next.hidden = false
            
            self.mapView.addAnnotation(annotationView.annotation!)

        }
    }
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
            
            let reuseIdentifier = "pin"
            
            var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
            if v == nil {
                v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                v!.canShowCallout = true
            }
            else {
                v!.annotation = annotation
            }
            
            let customPointAnnotation = annotation as! CustomPointAnnotation
            v!.image = UIImage(named:customPointAnnotation.pinCustomImageName)
            
            return v
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var DVC : PostVC = segue.destinationViewController as! PostVC
        //DVC.poop = "a"
        //DVC.caption = thecaption
        //DVC.PFimage = imageFile
        DVC.latix = lati
        DVC.longx = longi
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
}
