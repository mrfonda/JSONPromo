//
//  ContentCollectionReusableView.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 15/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import Nuke

class ContentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var promo : ContentPromo?
    {
        didSet {
            updateUI(promo: promo)
            selectedBackgroundView?.backgroundColor = UIColor.getRandomColor()
        }
    }
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.goAway() // animate selection
            } else {
                
            }
        }
    }
    
    func updateUI(promo: ContentPromo?) {
        imageView.image = #imageLiteral(resourceName: "Picture")
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        layer.cornerRadius = 5
        layer.masksToBounds = true
        if let promo = promo {
            if let imageURL = URL(string: promo.image_url) {
                Nuke.loadImage(with: imageURL, into: imageView)
            }
        }
    }
}

