//
//  StudentProfileCollectionViewCell.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/15/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class StudentProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var studentLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        studentImageView.contentMode = UIViewContentMode.ScaleAspectFill
        studentImageView.clipsToBounds = true
        
        flagImageView.contentMode = UIViewContentMode.ScaleAspectFill
        flagImageView.clipsToBounds = true
        flagImageView.layer.borderColor = UIColor.grayColor().CGColor
        flagImageView.layer.borderWidth = 0
        
        activityIndicator.hidesWhenStopped = true
    }
    
}
