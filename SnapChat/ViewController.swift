//
//  ViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/3/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func displayCamera() {
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        let camera = UIImagePickerController()
        camera.delegate = self
        if hasCamera {
            camera.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        camera.mediaTypes = [kUTTypeImage]
        camera.allowsEditing = true     // Don't see a disadvantage to supporting this
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("Image taken")
        
        // Here or after dismiss?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        println("Received image2")
        
        appDelegate.imageCount++
        appDelegate.galleryViewController = GalleryViewController()
        
        // Background thread to resize, save image and update gallery view
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            appDelegate.processImage(image)
        })
        
        appDelegate.galleryViewController!.displayPlaceHolder()
        self.navigationController!.pushViewController(appDelegate.galleryViewController!, animated: true)
        
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

