//
//  CollectionViewController.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 11/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import RealmSwift
import Nuke

private let singleIdentifier = "SingleCell"
private let pairIdentifier = "PairCell"
private let contentIdentifier = "ContentCell"
class CollectionViewController: UICollectionViewController {
    
    //MARK: - Variables
    
    let realm = try! Realm()
        
    var headerNotificationToken: NotificationToken? = nil { didSet { oldValue?.stop() } }
    var singleNotificationToken: NotificationToken? = nil { didSet { oldValue?.stop() } }
    //var pairNotificationToken: NotificationToken? = nil { didSet { oldValue?.stop() } }
    var contentNotificationToken: NotificationToken? = nil { didSet { oldValue?.stop() } }
    
    var promotions: Promotions = Promotions() {
        didSet {
           collectionView?.reloadData()
        }
    }

    var storedOffsets = [Int: CGFloat]()
    
    enum Sections : Int, CaseCountable {
        case header = 0
        case single = 1
        case pair = 2
        case content = 3
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.autoresizesSubviews = true
        self.collectionView!.register(UINib(nibName: "PairCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: pairIdentifier)
        
        promotions = realm.objects(Promotions.self)[0]

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reparse))
    }
    
    //MARK: - UI
    
    func reparse() {
        let promotions = Promotions(JSON: JSONUtils.goodJSON)
        try! realm.write {
            realm.add(promotions!, update: true)
            self.promotions = promotions!
        }
    }
    
    //MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch collectionView.restorationIdentifier ?? "" {
        case "PromotionsHeaderView":
            
            return 1
        default:
            return Sections.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch collectionView.restorationIdentifier ?? "" {
        case "PromotionsHeaderView":
            return promotions.head.count
        default:
            let sect = Sections(rawValue: section)!
            switch sect {
            case .header:
                return 1
            case .single:
                return promotions.single.count
            case .pair:
                return promotions.pair.count/2 + promotions.pair.count % 2
            case .content:
                return promotions.content.count
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.restorationIdentifier ?? "" {
        case "PromotionsHeaderView":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
            cell.promo = promotions.head[indexPath.row]
            return cell
        default:
            let sect = Sections(rawValue: indexPath.section)!
            switch sect {
            case .header:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCollectionViewCell
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
                cell.promotions = promotions.head
                return cell
            case .single:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
                cell.promo = promotions.single[indexPath.row]
                return cell
            case .pair:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pairIdentifier, for: indexPath) as! PairCollectionViewCell
                let index = indexPath.row * 2
                if (index + 1) < promotions.pair.count {
                    cell.promotions = (promotions.pair[index], promotions.pair[index + 1])
                } else {
                    cell.promotions = (promotions.pair[index], nil)
                }
                return cell
            case .content:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentIdentifier, for: indexPath) as! ContentCollectionViewCell
                cell.promo = promotions.content[indexPath.row]
                return cell
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
           
            let sect = Sections(rawValue: indexPath.section)!
            
            
            
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "SectionHeader",
                                                                             for: indexPath) as! SectionHeaderCollectionReusableView
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.sectionHeadersPinToVisibleBounds = true
            
            
            switch sect {
            case .header:
                headerView.title.text = "Header".uppercased()
            case .single:
                headerView.title.text = "Single".uppercased()
            case .pair:
                headerView.title.text = "Pair".uppercased()
            case .content:
                headerView.title.text = "Content".uppercased()
            }
            return headerView
        }
        return UICollectionReusableView()
    }


//MARK: - CollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let sect = Sections(rawValue: indexPath.section)!
        switch sect {
        case .single, .header:
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler:
                { alert in
                    
                    try! self.realm.write {
                        self.realm.delete((cell as! SingleCollectionViewCell).promo!)
                        collectionView.deleteItems(at: [indexPath])
                    }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .content:
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler:
                { alert in
                    
                    try! self.realm.write {
                        self.realm.delete((cell as! ContentCollectionViewCell).promo!)
                    }
                    collectionView.deleteItems(at: [indexPath])
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        default: break
        
        }
    }

//    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        <#code#>
//    }
//    collection
}


//MARK: - FlowLayout

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = collectionView.bounds.width//UIScreen.main.bounds.width
        let scaleFactor = collectionView.bounds.height //screenWidth
        
        switch collectionView.restorationIdentifier ?? "" {
        case "PromotionsHeaderView":
            return CGSize(width: screenWidth/2, height: scaleFactor)
        default:
            let sect = Sections(rawValue: indexPath.section)!
            switch sect {
            case .header:
                return CGSize(width: screenWidth, height: scaleFactor/3)
            default:
                return CGSize(width: screenWidth - 20, height: scaleFactor/3)
            }
            
        }
    }
    
}

//MARK: - enum extension

protocol CaseCountable: RawRepresentable {}
extension CaseCountable where RawValue == Int {
    static var count: RawValue {
        var i: RawValue = 0
        while let _ = Self(rawValue: i) { i += 1 }
        return i
    }
}
