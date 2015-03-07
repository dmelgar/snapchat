//
//  GalleryTableTableViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/6/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit
import MobileCoreServices

class GalleryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var _displayPlaceHolder = false
    var tableView = UITableView()
    
    override func viewDidLoad() {
        println("GalleryTableViewController viewDidLoad")
        super.viewDidLoad()
        self.tableView.registerClass(ImageTableViewCell.self, forCellReuseIdentifier: "imageCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Add button
        var camera = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        camera.setTitle("Camera", forState: UIControlState.Normal)
        camera.setTranslatesAutoresizingMaskIntoConstraints(false)
        camera.addTarget(self, action: "actionCamera", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(camera)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.pagingEnabled = true
        
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["camera"] = camera
        viewsDict["table"] = tableView
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[camera]-20-|", options: nil, metrics: nil, views: viewsDict));
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[camera]", options: nil, metrics: nil, views: viewsDict));
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[table]|", options: nil, metrics: nil, views: viewsDict));
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|", options: nil, metrics: nil, views: viewsDict));
        view.bringSubviewToFront(camera)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
        return numberOfImages
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageTableViewCell
        // var cell = ImageTableViewCell()
        
        // NSThread.sleepForTimeInterval(1)

        // Configure the cell...
        if _displayPlaceHolder {
            if indexPath.row == 0 {
                cell.iv.image = UIImage(named: "placeholder.jpg")
            } else {
                println("Loading image \(indexPath.row)")
                cell.iv.image = imageForIndex(indexPath.row - 1)
            }
        } else {
           cell.iv.image = imageForIndex(indexPath.row)
        }

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
    
    func displayPlaceHolder() {
        _displayPlaceHolder = true
    }
    
    func replacePlaceHolder(image: UIImage) {
        // Refresh the table view
        _displayPlaceHolder = false
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
    
    func actionCamera() {
        // Check permissions. iOS 8 bug. 2nd try using camera comes up with blank/empty/black view.
        // Taking the picture anyway seems to work. Same effect on my iPad Air and iPhone 6 both running iOS 8.1
        
        //        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        //        println(status)
        
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        let camera = UIImagePickerController()
        camera.delegate = self
        if hasCamera {
            camera.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        camera.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        camera.mediaTypes = [kUTTypeImage]
        camera.allowsEditing = false
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerController delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.imageCount++
        displayPlaceHolder()
        appDelegate.galleryViewController = self
        
        // Background thread to resize, save image and update gallery view
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            appDelegate.processImage(image)
        })
        
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
