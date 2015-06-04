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

class Colleges: UIViewController {
    var timer : NSTimer!
    var played = 0
    var timeplayed = 0
    var isplaying : Bool!
    @IBOutlet var testvideoview: UIView!
    
    @IBOutlet weak var crest: UIImageView!
    
    @IBOutlet weak var weather: UILabel!
    @IBOutlet var collection: UICollectionView!
    var moviePlayer:MPMoviePlayerController!
    var array = NSMutableArray()
    @IBOutlet var pausebutton: UIButton!
    @IBOutlet var username: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var record: UIButton!
    
    @IBOutlet weak var bottomblur: UILabel!
    @IBOutlet var startover: UIButton!
    @IBOutlet var nomore: UIButton!
    @IBAction func pause(sender: AnyObject) {
        if isplaying == true {
            
            moviePlayer.pause()
            isplaying = false
        } else {
                        moviePlayer.play()
            isplaying = true
        }
    }
    @IBAction func dismiss(sender: AnyObject) {
        moviePlayer.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet var scrollcont: UIScrollView!
    @IBAction func startover(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {
            self.nomore.alpha = 0.7
            self.nomore.backgroundColor = UIColor.clearColor()
            self.nomore.titleLabel?.textColor = UIColor.clearColor()
            self.startover.alpha = 0
            }, completion: {
                (value: Bool) in
                self.nomore.userInteractionEnabled = true
        })
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
    
    
    func blur(view: UIView){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        
        visualEffectView.frame = view.bounds
        
        view.addSubview(visualEffectView)
        [view .sendSubviewToBack(visualEffectView)];
    }
    override func viewDidLoad() {
        self.blur(bottomblur)
        super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        played = 0
        super.viewDidAppear(true)
        [self .pullall()]
        self.getcrest()
    }
    
    func getcrest() {
        var query = PFQuery(className:"Crests")
        let x = NSUserDefaults.standardUserDefaults().objectForKey("place") as! String
        query.whereKey("place", equalTo:x)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                
                println("Successfully retrieved the object.")
                let account : PFObject = object!
                let userImageFile = account["crest"] as! PFFile
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            let crestimage = UIImage(data:imageData)
                            self.crest.image = crestimage
                        }
                    }
                }
            }
        }
        
    }
    
    func playvideo(){
        UIView.animateWithDuration(0.5, animations: {
            self.nomore.alpha = 0.7
            self.nomore.backgroundColor = UIColor.clearColor()
            self.nomore.titleLabel?.textColor = UIColor.clearColor()
            self.startover.alpha = 0
            }, completion: {
                (value: Bool) in
                self.nomore.userInteractionEnabled = true
        })
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
            UIView.animateWithDuration(0.5, animations: {
                self.nomore.alpha = 0.7
                self.nomore.backgroundColor = UIColor.blackColor()
                self.nomore.titleLabel?.textColor = UIColor.whiteColor()
                self.startover.alpha = 1
                }, completion: {
                    (value: Bool) in
                    self.nomore.userInteractionEnabled = false
            })
            
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
            let zip = NSUserDefaults.standardUserDefaults().integerForKey("zip")
            println("\(zip)")
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
                        UIView.animateWithDuration(0.5, animations: {
                            self.nomore.alpha = 0.7
                            self.nomore.backgroundColor = UIColor.blackColor()
                            self.nomore.titleLabel?.textColor = UIColor.whiteColor()
                            //self.startover.alpha = 1
                            }, completion: {
                                (value: Bool) in
                                self.nomore.userInteractionEnabled = false
                        })

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

