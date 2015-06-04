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


class Locations: UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet var table: UITableView!
    var cities = NSMutableArray()
    var states = NSMutableArray()
    var names = NSMutableArray()
    var zips = NSMutableArray()
        override func viewDidLoad() {
            
        super.viewDidLoad()
            [self .pullall()]
          // Do any additional setup after loading the view, typically from a nib.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("LocationsCell") as! LocationsCell!
        if cell == nil {
            //tableView.registerNib(UINib(nibName: "UICustomTableViewCell", bundle: nil), forCellReuseIdentifier: "UICustomTableViewCell")
            tableView.registerClass(LocationsCell.classForCoder(), forCellReuseIdentifier: "LocationsCell")
            
            cell = LocationsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "LocationsCell")
        }
        cell = LocationsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "LocationsCell")
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(20)
            cell.textLabel!.text =  names[indexPath.row] as? String
        cell.detailTextLabel?.text = "\(cities[indexPath.row] as! String), \(states[indexPath.row] as! String)"
        
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let text = cell?.textLabel?.text
        let x = zips[indexPath.row] as! Int
        NSUserDefaults.standardUserDefaults().setInteger(x, forKey: "zip")
        NSUserDefaults.standardUserDefaults().setObject(text, forKey: "place")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.performSegueWithIdentifier("collegevisit", sender: self.view)
        table.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    func pullall(){
        var query = PFQuery(className:"Regions")
        query.orderByDescending("Zips")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        self.cities.addObject(object["City"] as! String)
                        self.states.addObject(object["States"] as! String)
                        self.names.addObject(object["Name"] as! String)
                        self.zips.addObject(object["Zips"] as! Int)
                        [self.table .reloadData()]
                        //[self.collection .reloadData()]
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }


}


