//
//  ImageTableViewCell.swift
//  SnapChat
//
//  Created by David Melgar on 3/6/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    var iv = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        self.iv.contentMode = .ScaleAspectFit
        self.iv.setTranslatesAutoresizingMaskIntoConstraints(false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // self.iv = UIImageView()
        self.contentView.addSubview(iv)
        
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["image"] = self.iv

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]|", options: nil, metrics: nil, views: viewsDict));
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[image]|", options: nil, metrics: nil, views: viewsDict));

        // self.iv.frame = self.bounds
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        iv.contentMode = .ScaleAspectFit
        self.addSubview(iv)
        self.iv.frame = self.bounds
    }
    
    override init() {
        super.init()
        iv.contentMode = .ScaleAspectFit
        addSubview(iv)
        iv.frame = bounds
    }
    required init(coder aDecoder: NSCoder) {
        // Add image view
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
