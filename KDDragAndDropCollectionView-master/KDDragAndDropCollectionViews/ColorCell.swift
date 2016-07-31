//
//  ColorCell.swift
//  KDDragAndDropCollectionViews
//
//  Created by Michael Michailidis on 13/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    //    self.imageView.image = UIImage(data: correctPicture)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
