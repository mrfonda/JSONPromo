//
//  PairCollectionViewswift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 11/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import Nuke

class PairCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageRight: UIImageView!
    @IBOutlet weak var imageLeft: UIImageView!
    
    var promotions : (left: Promo?, right: Promo?)?
    {
        didSet {
            updateUI(left: promotions?.left, right: promotions?.right)
        }
    }
    
    
    func updateUI(left: Promo?, right: Promo?) {
    
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        if let promo = promotions?.left {
            imageLeft.image = #imageLiteral(resourceName: "Picture")
            imageLeft.layer.cornerRadius = 5
            imageLeft.layer.masksToBounds = true
            if let imageURL = URL(string: promo.image_url) {
                Nuke.loadImage(with: imageURL, into: imageLeft)
            }
        } else {
            imageLeft.image = nil
        }
        if let promo = promotions?.right {
            imageRight.image = #imageLiteral(resourceName: "Picture")
            imageRight.layer.cornerRadius = 5
            imageRight.layer.masksToBounds = true
            if let imageURL = URL(string: promo.image_url) {
                Nuke.loadImage(with: imageURL, into: imageRight)
            }
        } else {
            imageRight.image = nil
        }
    }

  
}
