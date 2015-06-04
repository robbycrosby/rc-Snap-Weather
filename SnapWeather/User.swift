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

class User: UIViewController {
    let likesnum : Int = 0
    let postsnum : Int = 0
    var moviePlayer:MPMoviePlayerController!
    @IBOutlet weak var videobar: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet var posts: UILabel!
    @IBOutlet var likes: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var signout: UIButton!
    
        override func viewDidLoad() {
            
        super.viewDidLoad()
        self.getuser()
        signout.layer.cornerRadius = 9
                      // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.getuser()
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
    }
    func getuser(){
        var query = PFQuery(className:"UserAcct")
        query.whereKey("username", equalTo:NSUserDefaults.standardUserDefaults().objectForKey("username") as! String)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                
                let account : PFObject = object!
                let likecount = account["posts"] as! Int
                if likecount < 5 {
                    self.rank.text = "Reads The Paper"
                }
                if (likecount < 10) && (likecount > 4){
                    self.rank.text = "Watches The Weather"
                }
                if (likecount < 15) && (likecount > 9){
                    self.rank.text = "Goes On Weather.com"
                }
                if (likecount < 20) && (likecount > 14){
                    self.rank.text = "Watches On The 8's"
                }
                if (likecount < 25) && (likecount > 19){
                    self.rank.text = "Studying Meteorology"
                }
                if (likecount < 30) && (likecount > 24){
                    self.rank.text = "Public Access TV"
                }
                if (likecount < 35) && (likecount > 29){
                    self.rank.text = "Intern on Network"
                }
                if (likecount < 40) && (likecount > 34){
                    self.rank.text = "Meteorologist"
                }
                if (likecount < 100000) && (likecount > 41){
                    self.rank.text = "National Weatherman"
                }
                self.username.text = (NSUserDefaults.standardUserDefaults().objectForKey("username") as! String)
                self.likes.text = String(account["likes"] as! Int)
                self.posts.text = String(account["posts"] as! Int)
                
            }
        }
    }
    
    
    

}

