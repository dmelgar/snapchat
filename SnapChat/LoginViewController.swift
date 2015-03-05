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
        if NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") {
            performSegueWithIdentifier("loggedIn", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        // Previously logged in successfully
        // Eventually need some policy to time out etc.
        if NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") {
            return
        }
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
