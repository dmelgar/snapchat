//
//  GalleryViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/3/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UIScrollViewDelegate {

    var currentImageIndex: Int = 0
    var scrollView: UIScrollView = UIScrollView()
    var topView: UIImageView?
    var middleView: UIImageView?
    var bottomView: UIImageView?
    var iv: [UIImageView] = [UIImageView]()
    var previousOffset = CGPointZero
    var numberOfImages = 5
    
    override init() {
        super.init()
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup() {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let path = (paths[0] as! NSURL).absoluteString
        println(path)
        // Assume the current view is the size of the screen
    
        adjustContentSize()
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.cyanColor()
        view.addSubview(scrollView)
        
        var ivFrame = view.bounds
        topView = UIImageView(frame: ivFrame)
        ivFrame.origin.y = ivFrame.height
        middleView = UIImageView(frame: ivFrame)
        ivFrame.origin.y = ivFrame.height * 2
        bottomView = UIImageView(frame: ivFrame)
        
        scrollView.addSubview(topView!)
        scrollView.addSubview(middleView!)
        scrollView.addSubview(bottomView!)
        
        middleView!.backgroundColor = UIColor.greenColor()
        bottomView!.backgroundColor = UIColor.blueColor()
        topView!.backgroundColor = UIColor.redColor()
        
        topView!.image = imageForIndex(0)
        middleView!.image = imageForIndex(1)
        bottomView!.image = imageForIndex(2)
        // middleView!.image = imageForIndex(currentImageIndex)
        // bottomView!.image = imageForIndex(currentImageIndex+1)
        scrollView.contentOffset = CGPointMake(0, 0)
        // scrollView.contentOffset = CGPointMake(0, view.bounds.height)
        
        
        for i in 0...2 {
            iv.append(UIImageView())
        }
    }
    
    func adjustContentSize() {
        let numberOfImageViews = min(3, numberOfImages)
        let viewSize = view.frame.size
        let scContentSize = CGSizeMake(viewSize.width, viewSize.height * CGFloat(numberOfImageViews))
        scrollView.contentSize = scContentSize
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
        
        /* Create a UIScrollView thats 3x the height of the screen so that it can hold the previous and next image
        the middle image
        */
    }
    
    // Returns nil if the image is not found
    func imageForIndex(index: Int) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        let path = paths[0]
//        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        let path = (paths[0] as! NSURL).absoluteString
//        println(path)
        let filename = path + "/" + String(index) + ".jpg"
        println(filename)
        let image = UIImage(contentsOfFile: filename)
        return image
    }
    
    func viewForIndex(index: Int) -> UIView? {
        return nil
    }
    
    
    //MARK: ScrollView Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // View has stopped scrolling. Readjust
        
        /*
        If moved down:
        1. move imageView at middleView to topView
        2. move imageView at bottomView to middleView
        3. reset current scroll view position to middleView
        4. load new image into imageView for bottomView
        */
        var rejectPage = false
        // if offset is below the start of middle view, then it was a scroll down
        if scrollView.contentOffset.y > previousOffset.y {
            // Scroll down
            if currentImageIndex == 0 {
                // Slide content view down 1
                // Other images should already be loaded
                if numberOfImages > currentImageIndex + 1 {
                    // Move to next image IF there is another image
                    currentImageIndex++
                }
            } else
            if currentImageIndex == numberOfImages - 2 {
                // We're scrolling down to the last image
                // Slide the content offset down to the last image
                // Don't load a new image
                currentImageIndex++
                scrollView.contentOffset = CGPointMake(0, scrollView.bounds.height * 2)
            } else
            if currentImageIndex > 0 {
                // main case
                // rearrange views
                // Rearrange imageViews frames
                var tmpFrame = bottomView!.frame
                
                bottomView!.frame = middleView!.frame
                middleView!.frame = topView!.frame
                topView!.frame = tmpFrame
                
                var tmpIV = topView
                topView = middleView
                middleView = bottomView
                bottomView = tmpIV
                
                // Load new image into bottom view
                currentImageIndex++
                bottomView!.image = imageForIndex(currentImageIndex + 1)
                
                // reset offset to middle view
                scrollView.contentOffset = CGPointMake(0, scrollView.bounds.height)
                scrollView.setNeedsDisplay()
            }
        } else if scrollView.contentOffset.y < previousOffset.y {
            // Scrolled up
            
            // Special cases
            if currentImageIndex == 1 {
                // Let the content view go up. Don't change anything.
                // Don't load a new image, 0 should already be there
                currentImageIndex--
            } else
            if currentImageIndex == 0 {
                // Let the content view stay where it is. Should bounce on edge
            } else
            if currentImageIndex == numberOfImages - 1 {
                 // Slide contentOffset to middle view from bottom. No need to do anything else
                scrollView.contentOffset = CGPointMake(0, scrollView.bounds.height)
                currentImageIndex--
            } else
            if currentImageIndex > 1 {
                // Move views
                var tmpFrame = topView!.frame
                topView!.frame = middleView!.frame
                middleView!.frame = bottomView!.frame
                bottomView!.frame = tmpFrame
                
                // Rename views
                var tmpIV = bottomView
                bottomView = middleView
                middleView = topView
                topView = tmpIV
                
                currentImageIndex--
                topView!.image = imageForIndex(currentImageIndex - 1)
                
                // reset offset to middle view
                scrollView.contentOffset = CGPointMake(0, scrollView.bounds.height)
                scrollView.setNeedsDisplay()
            }
        }
        previousOffset = scrollView.contentOffset
        println("CurrentImageIndex = \(currentImageIndex)")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
