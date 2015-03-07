//
//  GalleryViewController.swift
//  SnapChat
//
//  Created by David Melgar on 3/3/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

/*
Manages a set of three UIImageViews in a paging UIScrollView.
Images are placed into the views and moved around based on paging.
Content size and content offset adjusted as paging occurs and in relation
to edge cases
*/

class GalleryViewController: UIViewController, UIScrollViewDelegate {
    enum ActiveImageViewEnum {
        case T, M, B
        func description () -> String {
            switch self {
            case T:
                return "Top"
            case M:
                return "Middle"
            case B:
                return "Bottom"
            }
        }
    }
    var activeImageView: ActiveImageViewEnum = .T

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
    
    func activeImageViewForOffset(offset: CGFloat) -> ActiveImageViewEnum {
        let result: ActiveImageViewEnum
        if offset >= scrollView.bounds.height * 2 {
            result = .B
        } else if offset < scrollView.bounds.height {
            result = .T
        } else {
            result = .M
        }
        return result
    }
    
    func offsetForActiveImageView(position: ActiveImageViewEnum) -> CGFloat {
        var offset: CGFloat = 0
        switch position {
            case .T:
                offset = 0
            case .M:
                offset = scrollView.bounds.height
            case .B:
                offset = 2 * scrollView.bounds.height
        }
        return offset
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
    func replacePlaceHolder(image: UIImage) {
        topView!.image = image
        middleView!.image = imageForIndex(1)
    }

    func setup() {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let path = (paths[0] as! NSURL).absoluteString
        println(path)
        // Assume the current view is the size of the screen
    
        automaticallyAdjustsScrollViewInsets = false
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
    
    func adjustContentSize(numberOfViews: Int? = nil) {
        let numberOfImages: Int
        if numberOfViews == nil {
            numberOfImages = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCount
        } else {
            numberOfImages = numberOfViews!
        }
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
        println("ScrollviewdidendDecelerating stoped at offset.y= \(scrollView.contentOffset.y)")
        // println("Scrollview bounds: \(scrollView.bounds) TopImageViewFrame: \(topView!.frame)")
        // View has stopped scrolling. Readjust
        
        /*
        If moved down:
        1. move imageView at middleView to topView
        2. move imageView at bottomView to middleView
        3. reset current scroll view position to middleView
        4. load new image into imageView for bottomView
        
        Handle special cases.
        Normally view port is in middle image view, but when at the beginning view port moves to the top image.
        Likewise when at the end, view port moves to the bottom image.
        Content size is also adjusted when at the ends to limit paging.
        
        */
        var rejectPage = false
        var newY: CGFloat = 0
        // if offset is below the start of middle view, then it was a scroll down
        if scrollView.contentOffset.y > previousOffset.y && activeImageView != .B {
            // Scroll down
            println("Scrolled down")
            if currentImageIndex == 0 {
                activeImageView = .M
                println("Top image")
                // Slide content view down 1
                // Other images should already be loaded
                if numberOfImages > 1 {
                    // Move to next image IF there is another image
                    currentImageIndex++
                    
                    // Adjust content size to 1, 2, 3 imageviews based on # of images available
                    adjustContentSize()
                }
            } else
            if currentImageIndex == numberOfImages - 2 {
                activeImageView = .B
                println("Second to last image")
                // We're scrolling down to the last image
                // Slide the content offset down to the last image
                // Don't load a new image
                currentImageIndex++
            } else
            if currentImageIndex > 0 {
                activeImageView = .M
                println("Standard next image")
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
            }
        } else if scrollView.contentOffset.y < previousOffset.y && activeImageView != .T {
            // Scrolled up
            println("Scrolled up")
            var doubleJump = false
            // Very rare case. If at the bottom view and managed to scroll up twice,
            // move to middle view AND act like you scrolled up once so you end up at the same image
            if activeImageView == .B && scrollView.contentOffset.y < scrollView.bounds.height {
                activeImageView = .M
                doubleJump = true
                currentImageIndex--
                // Then let it fall through and perform the action for scrolling up once.
            }
            
            // Special cases
            if currentImageIndex == 1 {
                activeImageView = .T
                // Let the content view go up. Don't change anything.
                // Don't load a new image, 0 should already be there
                currentImageIndex--
                
                // When at top view, only allow 2 view to prevent scrolling down twice
                adjustContentSize(numberOfViews: 2)
            } else
            if currentImageIndex == 0 {
                // Let the content view stay where it is. Should bounce on edge
                activeImageView = .T
            } else
            if currentImageIndex == numberOfImages - 1 && !doubleJump {
                 // Slide contentOffset to middle view from bottom. No need to do anything else
                activeImageView = .M
                currentImageIndex--
                
                // Set the content view height back to 3
                adjustContentSize(numberOfViews: 3)
            } else
            if currentImageIndex > 1 {
                activeImageView = .M
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
            }
        }
        
        newY = offsetForActiveImageView(activeImageView)
//        if activeImageView == .T {
//            newY = 0
//        } else if activeImageView == .M {
//            newY = scrollView.bounds.height
//        } else if activeImageView == .B {
//            newY = scrollView.bounds.height * 2
//        }
        
        println("ScrollView end newY= \(newY) oldY= \(previousOffset.y)" +
            " ActiveImageView = \(activeImageView.description()) imageIndex:\(currentImageIndex) \n")

        scrollView.contentOffset = CGPointMake(0, newY)
        previousOffset = scrollView.contentOffset
        
        if scrollView.contentOffset.y < 0 {
            scrollView.scrollRectToVisible(topView!.bounds, animated: true)
            // scrollView.contentOffset.y = 0
        }
        // println("CurrentImageIndex = \(currentImageIndex)")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
