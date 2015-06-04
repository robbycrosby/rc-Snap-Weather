//
//  Login.swift
//  Record Video With Swift
//
//  Created by Robert Crosby on 4/29/15.
//  Copyright (c) 2015 Raj Bala. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MediaPlayer
import MobileCoreServices
import AVFoundation

class Login: UIViewController,PFSignUpViewControllerDelegate {

    

    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var blurview: UILabel!
    @IBOutlet weak var password: UITextField!
    var moviePlayer:MPMoviePlayerController!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var movieview: UIView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        var currentUser = PFUser.currentUser()
        
        if currentUser != nil {
            self.performSegueWithIdentifier("login", sender: self)
        } else {
            username.becomeFirstResponder()
        }
        

        
            }
    func blur(view: UIView){
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        
        visualEffectView.frame = view.bounds
        
        view.addSubview(visualEffectView)
        [view .sendSubviewToBack(visualEffectView)];
    }

    @IBAction func signup(sender: AnyObject) {
        var user = PFUser()
        user.username = username.text
        user.password = password.text
        // other fields can be set just like with PFObject
        user.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
            
           
            
            if ((error) != nil) {
                
                var alert = UIAlertView(title: "Error", message: "\(error?.description)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
            }else {
                var gameScore = PFObject(className:"UserAcct")
                gameScore["username"] = self.username.text
                gameScore["likes"] = 0
                gameScore["posts"] = 0
                gameScore.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        NSUserDefaults.standardUserDefaults().setObject(self.username.text, forKey: "username")
                        NSUserDefaults.standardUserDefaults().setObject(self.password.text, forKey: "password")
                        self.performSegueWithIdentifier("login", sender: sender)
                    } else {
                        // There was a problem, check error.description
                    }
                }
                
                
            }
            
        })    }

    @IBAction func login(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(username.text, password:password.text) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                NSUserDefaults.standardUserDefaults().setObject(self.username.text, forKey: "username")
                NSUserDefaults.standardUserDefaults().setObject(self.password.text, forKey: "password")
               self.performSegueWithIdentifier("login", sender: sender)
            } else {
                var alert = UIAlertView(title: "Error", message: "\(error?.description)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
