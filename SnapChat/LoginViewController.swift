//
//  LoginViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/4/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var user: UITextField?
    @IBOutlet var password: UITextField?
    
    override func viewDidAppear(animated: Bool) {
        // Would implement differently second time. Modal view for login or not with storyboard
        if NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") {
            performSegueWithIdentifier("loggedIn", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        // Check for valid userid/password
        if (password!.text == "demo") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "loggedIn")
        } else {
            // Display alert
            if (count(user!.text) == 0) && (count(password!.text) == 0) {
                var alert = UIAlertController(title: "Enter userid and password", message: "(testing password = demo)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                var alert = UIAlertController(title: "Invalid userid or password", message: "(testing password = demo)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        // Falls through and performs segue unless alert is displayed
    }
}
