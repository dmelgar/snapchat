//
//  ImageTableViewCell.swift
//  SnapChat
//
//  Created by David Melgar on 3/6/15.
//  Copyright (c) 2015 Broad Reach Software. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    var iv: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        self.iv = UIImageView()
        self.iv.contentMode = .ScaleAspectFit
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // self.iv = UIImageView()
        self.addSubview(iv)
        self.iv.frame = self.bounds
    }

    
    override init() {
        iv = UIImageView()
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        // Add image view
        iv = UIImageView()
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
