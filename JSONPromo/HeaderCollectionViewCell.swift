//
//  HeaderCollectionViewCell.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 12/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import RealmSwift

class HeaderCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var collectionView: UICollectionView!
    var headerNotificationToken: NotificationToken? = nil
    var promotions : List<Promo>? {
        didSet {
           
           headerNotificationToken = promotions?.registerNotification(collectionView: collectionView, section: 0)
        }
    }
    
    var collectionViewOffset: CGFloat {
        
        get {
            return collectionView.contentOffset.x
        }
        
        set {
            collectionView.contentOffset.x = newValue
        }
        
    }
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}
