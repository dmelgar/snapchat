//
//  ViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/3/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

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
        // appDelegate.galleryViewController = GalleryTableViewController()
        appDelegate.galleryViewController!.viewDidLoad()
        // appDelegate.galleryViewController = GalleryViewController()
        
        // appDelegate.galleryViewController!.displayPlaceHolder = true
        appDelegate.galleryViewController!.displayPlaceHolder()
        
        // Background thread to resize, save image and update gallery view
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            appDelegate.processImage(image)
        })

        self.navigationController!.pushViewController(appDelegate.galleryViewController!, animated: true)
        
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

