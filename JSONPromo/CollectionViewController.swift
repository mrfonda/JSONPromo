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
    
    var promotions: Promotions = Promotions()

    var storedOffsets = [Int: CGFloat]()
    
    enum Sections : Int, CaseCountable {
        case header = 0
        case single = 1
        case pair = 2
        case content = 3
//        var countInSection : Int {
//            get {
//                switch self {
//                case .header:
//                    return self.headerItems
//                }
//            }
//            set {
//                
//            }
//        }
    }
    //
    var singleItems = 0
    var pairItems = 0
    var contentItems = 0
    var headerItems = 0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.autoresizesSubviews = true
        self.collectionView!.register(UINib(nibName: "PairCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: pairIdentifier)
        
        // Observe Results Notifications
        promotions = realm.objects(Promotions.self)[0]
        //singleNotificationToken = promotions.single.registerNotification(collectionView: collectionView, section: Sections.single.rawValue)
        //pairNotificationToken = promotions.pair.registerNotification(collectionView: collectionView, section: Sections.pair.rawValue)
        contentNotificationToken = promotions.content.registerNotification(collectionView: collectionView, section: Sections.content.rawValue)
        singleNotificationToken = promotions.single.registerNotification(collectionView: collectionView, section: Sections.single.rawValue)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reparse))
    }
    
    deinit {
        headerNotificationToken?.stop()
        singleNotificationToken?.stop()
        //pairNotificationToken?.stop()
        contentNotificationToken?.stop()
    }
    
    //MARK: - UI
    
    func reparse() {
        let promotions = Promotions(JSON: JSONUtils.goodJSON)
        try! realm.write {
            realm.add(promotions!, update: true)
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

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let sect = Sections(rawValue: section)!
//        switch sect {
//        case .header:
//            if promotions.head.isEmpty {
//                return CGSize.zero
//            }
//        case .single:
//            if promotions.single.isEmpty {
//                return CGSize.zero
//            }
//        case .pair:
//            if promotions.pair.isEmpty {
//                return CGSize.zero
//            }
//        case .content:
//            if promotions.content.isEmpty {
//                return CGSize.zero
//            }
//        }
//        return CGSize(width: 10, height: 10)
//    }


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
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        default: break
        
        }
    }
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

//MARK: - List extension

extension List {
    func registerNotification(collectionView: UICollectionView?, section : Int ) -> NotificationToken
    {
        return self.addNotificationBlock { [weak collectionView] changes in
            guard let collectionView = collectionView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                collectionView.reloadSections(IndexSet(integer: section))
            case .update(_, let deletions, let insertions, let modifications):
                print(deletions, insertions, modifications,section)
                // Query results have changed, so apply them to the UITableView
                collectionView.performBatchUpdates(
                    {
                        collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: section)}))
                        collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: section)}))
                        collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: section)
                        }))
                }, completion: nil)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }

}
