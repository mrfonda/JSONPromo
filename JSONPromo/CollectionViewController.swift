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
private let headerIdentifier = "SectionHeader"
class CollectionViewController: UICollectionViewController  {
    
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
       self.collectionView!.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // collectionView?.setCollectionViewLayout(CustomFlowLayout(), animated: false)
        setupCollectionViewLayout()
        //collectionView?.layout.headerReferenceSize = CGSizeMake(HEADER_WIDTH, HEADER_HEIGHT)
        
        collectionView?.isPrefetchingEnabled = true
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
    
    //    func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes {
    //        let attr: UICollectionViewLayoutAttributes? = layoutAttributesForItem(at: itemIndexPath)
    //        attr?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: .pi)
    //        attr?.center = CGPoint(x: CGFloat(collectionView?.bounds.midX), y: CGFloat(collectionView?.bounds.maxY))
    //        return attr!
    //    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.restorationIdentifier ?? "" {
        case "PromotionsHeaderView":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
            //cell.imageView.layer.newsAnimation()
            cell.promo = promotions.head[indexPath.row]
            return cell
        default:
            let sect = Sections(rawValue: indexPath.section)!
            switch sect {
            case .header:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCollectionViewCell
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
                cell.promotions = promotions.head
                //cell.collectionView?.setCollectionViewLayout(CustomFlowLayout(), animated: false)
                cell.collectionView.isDirectionalLockEnabled = false
                return cell
            case .single:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
                cell.promo = promotions.single[indexPath.row]
                
                //cell.imageView.layer.newsAnimation()
                
                return cell
            case .pair:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pairIdentifier, for: indexPath) as! PairCollectionViewCell
                let index = indexPath.row * 2
                if (index + 1) < promotions.pair.count {
                    cell.promotions = (promotions.pair[index], promotions.pair[index + 1])
                } else {
                    cell.promotions = (promotions.pair[index], nil)
                }
                //cell.imageLeft.layer.newsAnimation()
                //cell.imageRight.layer.newsAnimation()
                return cell
            case .content:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentIdentifier, for: indexPath) as! ContentCollectionViewCell
                cell.promo = promotions.content[indexPath.row]
                //cell.imageView.layer.newsAnimation()
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
            let layout = collectionView.collectionViewLayout as? CustomFlowLayout
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
    //MARK: - Animation FlowLayout
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1.0
        }
       // cell.layer.newsAnimation()
    }
    
    func setupCollectionViewLayout() {
        let layout = CustomFlowLayout()
        //layout.headerReferenceSize = CGSize(width: 100, height: 40 )
        collectionView?.collectionViewLayout = layout
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
//                UIView.animate(withDuration: 2.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [UIViewAnimationOptions.preferredFramesPerSecond60, ], animations:
//                    { () -> Void in
                        collectionView.reloadSections(IndexSet(integer: section))
//                }, completion: { _ in })
            case .update(_, let deletions, let insertions, let modifications):
                print(deletions, insertions, modifications,section)
                // Query results have changed, so apply them to the UITableView
//                UIView.animate(withDuration: 0.5, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [UIViewAnimationOptions.preferredFramesPerSecond60, ], animations:
//                    { () -> Void in
                        collectionView.performBatchUpdates(
                            {
                                collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: section)}))
                                collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: section)}))
                                collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: section)
                                }))
                        }, completion: nil)
//                }, completion: { _ in })
                
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
    
}

//MARK: - CALayer extension

extension CALayer {
    
    func newsAnimation() {
        let scaleAnim      = CAKeyframeAnimation(keyPath:"transform")
        scaleAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)),
                              NSValue(caTransform3D: CATransform3DIdentity)]
        scaleAnim.keyTimes = [0, 1]
        scaleAnim.duration = 2
        
        
        let opacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        opacityAnim.values   = [0, 1]
        opacityAnim.keyTimes = [0, 1]
        opacityAnim.duration = 2
        
        let rotateAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        rotateAnim.values   = [0,
                               -2880 * CGFloat(M_PI/180)]
        rotateAnim.keyTimes = [0, 1]
        rotateAnim.duration = 2
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnim, rotateAnim, opacityAnim]
        groupAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        
        if let animations = groupAnimation.animations {
            for anim in animations {
                anim.fillMode = kCAFillModeForwards
            }
        }
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.isRemovedOnCompletion = false
        
        
        groupAnimation.duration = 2
        
        
        self.add(groupAnimation, forKey: "groupAnimation")
        self.animation(forKey: "groupAnimation")
    }
}


//MARK: - CustomFlowLayout

class CustomFlowLayout : UICollectionViewFlowLayout {
    var insertingIndexPaths = [IndexPath]()
    
//    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        <#code#>
//    
//    }
    
        override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
            super.prepare(forCollectionViewUpdates: updateItems)
            
            insertingIndexPaths.removeAll()
            
            for update in updateItems {
                if let indexPath = update.indexPathAfterUpdate,
                    update.updateAction == .insert {
                    insertingIndexPaths.append(indexPath)
                }
            }
        }
    
        override func finalizeCollectionViewUpdates() {
            super.finalizeCollectionViewUpdates()
            
            insertingIndexPaths.removeAll()
        }
    
    override func initialLayoutAttributesForAppearingItem( at itemIndexPath: IndexPath) ->UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        attributes?.alpha = 0.0
            attributes?.transform = CGAffineTransform(
                scaleX: 0.01,
                y: 0.01
            )
        return attributes
    }
    
  
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        attributes?.transform = CGAffineTransform(
                    translationX: 0,
                    y: -500.0 )
        attributes?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        return attributes
    }
    
}
