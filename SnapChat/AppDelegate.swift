//
//  AppDelegate.swift
//  SnapChat
//
//  Created by David Melgar on 3/3/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Maintains reference to singleton GalleryViewController
    var galleryViewController: GalleryViewController?
    
    // Images are kept stores in Document directory with name = indexNumber.png. 
    // ImageCount is the number of images the app knows about. In this demo the count is not
    // saved although images are. Could use UserDefaults or other file to save previous count
    var imageCount = 0


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getImageFilePath(index: Int) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        let path = paths[0]
        let filename = path + "/" + String(index) + ".png"
        return filename
    }

    // Invoked from background thread
    func processImage(image: UIImage) {
        let filename = getImageFilePath(imageCount-1)
        
        // Calculate new size
        let scale = 640/image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSizeMake(640, newHeight)
        
        println("AppDelegate.newSize = \(newSize)")
        
        // Resize image
        let newImage = resizeImage(image, size: newSize)
        println("new image size: \(newImage.size)")
        UIImagePNGRepresentation(newImage).writeToFile(filename, atomically: true)
        // UIImageJPEGRepresentation(newImage, 0.5).writeToFile(filename, atomically: true)
        
        // imageCount++
        
        // Invoke method on gallery view to update
        NSThread.sleepForTimeInterval(1)
        dispatch_sync(dispatch_get_main_queue(), {
            self.galleryViewController?.replacePlaceholder(newImage)
        })
    }
    
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}

