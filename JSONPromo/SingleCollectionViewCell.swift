//
//  SingleCollectionViewCell.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 12/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import Nuke
class SingleCollectionViewCell: UICollectionViewCell {
    var promo : Promo?
    {
        didSet {
            updateUI(promo: promo)
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    func updateUI(promo: Promo?) {
        imageView.image = #imageLiteral(resourceName: "Picture")
        layer.cornerRadius = 5
        layer.masksToBounds = true
        if let promo = promo {
            if let imageURL = URL(string: promo.image_url) {
                Nuke.loadImage(with: imageURL, into: imageView)
            }
        }
    }
}
