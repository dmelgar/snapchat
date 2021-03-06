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
    
    override init() {
        super.init()
        setup()
        // println("init bare called")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // setup()
        // println("Init nib called")
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // println("init coder called")
    }
    
    // Resets gallery to top, display placeholder and fill in images below it
    func displayPlaceHolder() {
        let placeholder = UIImage(named: "placeholder.jpg")
        topView!.image = placeholder
        currentImageIndex = 0
        middleView!.image = imageForIndex(0)
        adjustContentSize()
    }
    
    // A little risky timing wise. Assumption is that the resize will be very quick, user not able to scroll down
    // to replace top view in time to cause an issue
    func replacePlaceholder(image: UIImage) {
        topView!.image = image
        middleView!.image = imageForIndex(1)
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
        // scrollView.backgroundColor = UIColor.cyanColor()
        view.addSubview(scrollView)
        
        var ivFrame = view.bounds
        topView = UIImageView(frame: ivFrame)
        ivFrame.origin.y = ivFrame.height
        middleView = UIImageView(frame: ivFrame)
        ivFrame.origin.y = ivFrame.height * 2
        bottomView = UIImageView(frame: ivFrame)
        
        topView!.contentMode    = .ScaleAspectFit
        middleView!.contentMode = .ScaleAspectFit
        bottomView!.contentMode = .ScaleAspectFit
        
        scrollView.addSubview(topView!)
        scrollView.addSubview(middleView!)
        scrollView.addSubview(bottomView!)
        
        // Set colors for debugging
//        middleView!.backgroundColor = UIColor.greenColor()
//        bottomView!.backgroundColor = UIColor.blueColor()
//        topView!.backgroundColor    = UIColor.redColor()
        
        topView!.image = imageForIndex(0)
        middleView!.image = imageForIndex(1)
        bottomView!.image = imageForIndex(2)
        
        scrollView.contentOffset = CGPointMake(0, 0)
    }
    
    func adjustContentSize() {
        let numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
        let numberOfImageViews = min(3, numberOfImages)
        let viewSize = view.frame.size
        let scContentSize = CGSizeMake(viewSize.width, viewSize.height * CGFloat(numberOfImageViews))
        scrollView.contentSize = scContentSize
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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

    //MARK: ScrollView Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
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
        // println("CurrentImageIndex = \(currentImageIndex)")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
