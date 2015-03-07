//
//  GalleryTableTableViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/6/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

class GalleryTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var displayPlaceHolder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(ImageTableViewCell.self, forCellReuseIdentifier: "imageCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
        return numberOfImages
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageTableViewCell

        // Configure the cell...
        if displayPlaceHolder {
            if indexPath.row == 0 {
                cell.iv.image = UIImage(named: "placeholder.jpg")
            } else {
                cell.iv.image = imageForIndex(indexPath.row - 1)
            }
        } else {
           cell.iv.image = imageForIndex(indexPath.row)
        }
        cell.frame = self.view.bounds
        cell.iv.frame = self.view.bounds
        println("Getting image for \(indexPath.row)")
        return cell
    }

    
    // Returns nil if the image is not found
    // Reverse order here
    func imageForIndex(index: Int) -> UIImage? {
        let numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
        let reversedIndex = numberOfImages - 1 - index
        let image: UIImage?
        if reversedIndex < 0 {
            image = nil
        } else {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
            let path = paths[0]
            let filename = path + "/" + String(reversedIndex) + ".png"
            // println(filename)
            image = UIImage(contentsOfFile: filename)
        }
        return image
    }
    
    func replacePlaceholder(image: UIImage) {
        // Refresh the table view
        displayPlaceHolder = false
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 640
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
