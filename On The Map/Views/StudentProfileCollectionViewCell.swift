//
//  StudentProfileCollectionViewCell.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/15/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class StudentProfileCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var studentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        studentImageView.contentMode = UIViewContentMode.ScaleAspectFill
        studentImageView.clipsToBounds = true

    }
    
}
