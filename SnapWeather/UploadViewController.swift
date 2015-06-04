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

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    var locationstring : String!
    var zip : Int!
    @IBOutlet weak var topblur: UILabel!
    var manager: CLLocationManager?
    @IBOutlet var close: UIButton!
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var moviePlayer:MPMoviePlayerController!
    var isplaying = true
    var declareurl = NSURL()
    @IBOutlet var recordbutton: UIButton!
    @IBOutlet var video: UIView!
    @IBOutlet var pause: UIButton!
    @IBOutlet var submit: UIButton!
    @IBOutlet var weather: UILabel!
    
    @IBOutlet weak var blurbottom: UILabel!
    
    @IBAction func quit(sender: AnyObject) {
        moviePlayer.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func viewDidLoad() {
        self.blur(topblur)
        self.blur(blurbottom)
        recordbutton.layer.cornerRadius = recordbutton.frame.width/2
        recordbutton.layer.borderColor = UIColor.whiteColor().CGColor
        recordbutton.layer.borderWidth = 5.0
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
                        self.locationstring = pm.postalCode
                        self.zip = pm.postalCode.toInt()
                        let x = pm.locality
                        let weatherAPI = WeatherAPI()
                        weatherAPI.fetchWeather(x)
                    }
                    else {
                        println("Problem with the data received from geocoder")
                    }
                })
            }
        }
        super.viewDidLoad()
        let delay = 0.1 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera;
            imagePicker.mediaTypes = [kUTTypeMovie!]
            imagePicker.videoMaximumDuration = 10
            imagePicker.allowsEditing = true
            
            imagePicker.showsCameraControls = true
            // Insert the overlay
            
            self.presentViewController(imagePicker, animated: false, completion: nil)

        })
                // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    @IBAction func submit(sender: AnyObject) {
        
        
        
        // Convert to Video data.
        
        let weatherData = NSData(contentsOfURL: declareurl)
        
        //Subir video a Parse
        var weathervideo = PFFile(name: "WeatherVideo.mov", data: weatherData!)
        var userPhoto = PFObject(className:"Weather")
        userPhoto["video"] = weathervideo
        userPhoto["name"] = NSUserDefaults.standardUserDefaults().objectForKey("username")
        userPhoto["Zip"] = self.zip
        userPhoto["Weather"] = weather.text
        let uploadalert = UIAlertView()
        uploadalert.title = "Uploading..."
        uploadalert.show()
        userPhoto.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                var query = PFQuery(className:"UserAcct")
                query.whereKey("username", equalTo:NSUserDefaults.standardUserDefaults().objectForKey("username")!)
                query.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error != nil || object == nil {
                        println("The getFirstObject request failed.")
                    } else {
                        let useracct : PFObject = object!
                        useracct.incrementKey("posts")
                        useracct.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // Delay the dismissal by 5 seconds
                                uploadalert.dismissWithClickedButtonIndex(-1, animated: true)
                                
                                self.moviePlayer.stop()
                                let alert = UIAlertView()
                                alert.title = "Shared!"
                                alert.show()
                                // Delay the dismissal by 5 seconds
                                let delay = 1.5 * Double(NSEC_PER_SEC)
                                var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                dispatch_after(time, dispatch_get_main_queue(), {
                                    alert.dismissWithClickedButtonIndex(-1, animated: true)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                })

                            } else {
                                // There was a problem, check error.description
                            }
                    }
                }
                    
                }
                // There was a problem, check error.description
            }
        }
        

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(false, completion: {})
        
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        if tempImage == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            declareurl = info[UIImagePickerControllerMediaURL] as! NSURL!
            weather.hidden = false
            pause.hidden = false
            submit.hidden = false
            moviePlayer = MPMoviePlayerController(contentURL: tempImage)
            moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
            
            video.addSubview(moviePlayer.view)
            moviePlayer.fullscreen = true
            moviePlayer.repeatMode = .One
            moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
            moviePlayer.controlStyle = MPMovieControlStyle.None
            weather.text = (NSUserDefaults.standardUserDefaults().objectForKey("weather") as! String)
            

        }
            }
    func blur(view: UIView){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
        
        visualEffectView.frame = view.bounds
        
        view.addSubview(visualEffectView)
        [view .sendSubviewToBack(visualEffectView)];
    }
    func darkblur(view: UIView){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        
        visualEffectView.frame = view.bounds
        
        view.addSubview(visualEffectView)
        [view .sendSubviewToBack(visualEffectView)];
    }

    @IBAction func pause(sender: AnyObject) {
        if (isplaying == true) {
            moviePlayer.pause()
            [pause .setBackgroundImage(UIImage(named: "wplay.png"), forState: UIControlState.Normal)]
            isplaying = false
        } else {
            moviePlayer.play()
            [pause .setBackgroundImage(UIImage(named: "wpause.png"), forState: UIControlState.Normal)]
            isplaying = true
        }
        
    }
    
    @IBAction func record(sender: AnyObject) {
        moviePlayer.pause()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            
            println("captureVideoPressed and camera available.")
            
            var imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = .Camera;
            imagePicker.mediaTypes = [kUTTypeMovie!]
            imagePicker.videoMaximumDuration = 10
            imagePicker.allowsEditing = true
            
            imagePicker.showsCameraControls = true
            // Insert the overlay
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
            
        else {
            println("Camera not available.")
        }

    }

}

