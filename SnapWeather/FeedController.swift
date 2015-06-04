//
//  ViewController.swift
//  VideoRecord1
//
//  Created by Raj Bala on 9/17/14.
//  Copyright (c) 2014 Raj Bala. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVFoundation
import Parse
import CoreLocation
import MapKit

class FeedController: UIViewController, CLLocationManagerDelegate {
    var timer : NSTimer!
    var played = 0
        var zip : Int!
    var timeplayed = 0
    var isplaying : Bool!
    @IBOutlet var testvideoview: UIView!
    var manager: CLLocationManager?
    
    @IBOutlet weak var darkblur: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    @IBOutlet var collection: UICollectionView!
    var moviePlayer:MPMoviePlayerController!
    var array = NSMutableArray()
    @IBOutlet var pausebutton: UIButton!
    @IBOutlet var username: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var menubarback: UILabel!
    @IBOutlet var record: UIButton!
    
    @IBOutlet weak var bottomblur: UILabel!
    @IBOutlet var startover: UIButton!
    @IBAction func pause(sender: AnyObject) {
        if isplaying == true {
            [pausebutton .setBackgroundImage(UIImage(named: "wplay.png"), forState: UIControlState.Normal)]
            moviePlayer.pause()
            isplaying = false
        } else {
                        moviePlayer.play()
            [pausebutton .setBackgroundImage(UIImage(named: "wpause.png"), forState: UIControlState.Normal)]
            isplaying = true
        }
    }
    @IBAction func dislike(sender: AnyObject) {
        var query = PFQuery(className:"UserAcct")
        query.whereKey("username", equalTo:username.text!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                let useracct : PFObject = object!
                let likecount = useracct["likes"] as! Int
                let x = likecount - 1
                useracct["likes"] = x
                useracct.saveInBackground()
            }
        }
        let alert = UIAlertView()
        alert.title = "Disliked"
        alert.show()
        
        // Delay the dismissal by 5 seconds
        let delay = 0.4 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        })

    }
    @IBOutlet var scrollcont: UIScrollView!
    @IBAction func likeup(sender: AnyObject) {
       
        var query = PFQuery(className:"UserAcct")
        query.whereKey("username", equalTo:username.text!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                let useracct : PFObject = object!
                useracct.incrementKey("likes")
                useracct.saveInBackground()
            }
        }
        let alert = UIAlertView()
        alert.title = "Liked"
        alert.show()
        // Delay the dismissal by 5 seconds
        let delay = 0.4 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissWithClickedButtonIndex(-1, animated: true)
        })

    }
    @IBAction func startover(sender: AnyObject) {
                played = 0
        [self .pullall()]
        
    }
    
    
    @IBAction func like(sender: AnyObject) {
        var query = PFQuery(className:"UserAcct")
        query.whereKey("username", equalTo:username.text!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                let useracct : PFObject = object!
                useracct.incrementKey("likes")
                useracct.saveInBackground()
            }
        }    }
    
    @IBAction func home(sender: AnyObject) {
        if self.array.count == 0 {
            self.scrollcont.setContentOffset(CGPointMake(0, 0), animated: true)
            isplaying = false
        } else {
            isplaying = true
            moviePlayer.play()
            /*
            isplaying = false
            moviePlayer.stop()
            played = 0
            [self .pullall()]
            */
            self.scrollcont.setContentOffset(CGPointMake(0, 0), animated: true)

        }
            }
    @IBAction func locations(sender: AnyObject) {
        if self.array.count == 0 {
            isplaying = false
            self.scrollcont.setContentOffset(CGPointMake(375, 0), animated: true)
        } else {
            moviePlayer.pause()
            isplaying = false
            self.scrollcont.setContentOffset(CGPointMake(375, 0), animated: true)
        }
        
        
    }
    @IBAction func recordubtton(sender: AnyObject) {
        if self.array.count == 0 {
            isplaying = false
        } else {

        moviePlayer.pause()
        isplaying = false
        }
    }
    
    
    @IBAction func hotsection(sender: AnyObject) {
        
    }
    
    @IBAction func profile(sender: AnyObject) {
        if self.array.count == 0 {
            self.scrollcont.setContentOffset(CGPointMake(750, 0), animated: true)
            isplaying = false
        } else {
            self.scrollcont.setContentOffset(CGPointMake(750, 0), animated: true)
            moviePlayer.pause()
            isplaying = false
        }
        
    }
    func blur(view: UIView){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
        
        visualEffectView.frame = view.bounds
        
        view.addSubview(visualEffectView)
        [view .sendSubviewToBack(visualEffectView)];
    }
    override func viewDidLoad() {
        self.blur(bottomblur)
        self.blur(menubarback)
        
        self.scrollcont.contentSize = CGSizeMake(1125, 647)
      //record.layer.cornerRadius = record.frame.width/2
       // record.layer.borderColor = UIColor.whiteColor().CGColor
        //record.layer.borderWidth = 8.0
        super.viewDidLoad()
        played = 0
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                var longitude :CLLocationDegrees = geoPoint!.longitude as Double
                var latitude :CLLocationDegrees = geoPoint!.latitude as Double
                
                var location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
                println(location)
                
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    println(location)
                    
                    if error != nil {
                        println("Reverse geocoder failed with error" + error.localizedDescription)
                        return
                    }
                    
                    if placemarks.count > 0 {
                        let pm = placemarks[0] as! CLPlacemark
                        self.zip = pm.postalCode.toInt()
                        let weatherAPI = WeatherAPI()
                        let x = pm.locality
                        weatherAPI.fetchWeather(x)
                        self.pullall()
                    }
                    else {
                        println("Problem with the data received from geocoder")
                    }
                })
            }
        }
          // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
    }
    func playvideo(){
        
            let object : PFObject = array[played] as! PFObject
            
            let weathervideo : PFObject = object
            username.text = weathervideo["name"] as? String
            weather.text = weathervideo["Weather"] as? String
            //location.text = weathervideo["Location"] as? String
            let applicantResume = weathervideo["video"] as! PFFile
            let resumeData = applicantResume.getData()
            if let fileData
                = resumeData {
                let tempDirectoryTemplate = NSTemporaryDirectory().stringByAppendingPathComponent(weathervideo.objectId!+".mov")
                fileData.writeToFile(tempDirectoryTemplate, atomically: true)
                let urlpath : NSURL = NSURL.fileURLWithPath(tempDirectoryTemplate)!
                self.moviePlayer = MPMoviePlayerController(contentURL: urlpath)
                self.moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
                self.testvideoview.addSubview(self.moviePlayer.view)
                self.moviePlayer.fullscreen = false
                    self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
                isplaying = true
                self.moviePlayer.controlStyle = MPMovieControlStyle.None
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinishPlaying:" , name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer)

        }
        
    }

    func moviePlayerDidFinishPlaying(notification: NSNotification) {
        
        if played == array.count - 1 {
            moviePlayer.pause()
            } else {
            moviePlayer.stop()
            played++
            self.playvideo()
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
        func pullall(){
            let mindist = zip - 100
            let maxdist = zip + 100
        var query = PFQuery(className:"Weather")
        query.orderByDescending("createdAt")
            query.whereKey("Zip", greaterThan: mindist)
            query.whereKey("Zip", lessThan: maxdist)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) videos.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    if objects.count == 0 {
                        
                    } else {
                        for object in objects {
                            
                            self.array.addObject(object)
                            println(object.objectId)
                            self.playvideo()
                            //[self.collection .reloadData()]
                        }
                    }
                    
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    

}

