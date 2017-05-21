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
    var promotions: Promotions = Promotions()

    enum Sections : Int, CaseCountable {
        case header     = 0
        case single     = 1
        case pair       = 2
        case content    = 3
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.autoresizesSubviews = true
        
        self.collectionView!.register(UINib(nibName: "PairCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: pairIdentifier)
        
        setupCollectionViewLayout()
        collectionView?.isPrefetchingEnabled = true
        
        // Observe Results Notifications
        
        promotions = realm.objects(Promotions.self)[0]
        singleNotificationToken = promotions.single.registerNotification(collectionView: collectionView, section: Sections.single.rawValue)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reparse))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteSelected))
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(changeSetting))
        
        self.navigationItem.leftBarButtonItems = [deleteButton, editButton]
    }
    
    deinit {
        headerNotificationToken?.stop()
        singleNotificationToken?.stop()
    }
    //MARK: - UI
    
    func reparse() {
        let promotions = Promotions(JSON: JSONUtils.goodJSON)
        try! realm.write {
            realm.add(promotions!, update: true)
        }
    }
    
    func changeSetting() {
        Settings.enambleSpring = !Settings.enambleSpring
        UIView.animate(withDuration: 1, animations: {
            self.navigationItem.prompt = Settings.enambleSpring ? "Spring enabled" : "Spring disabled"
        }) { _ in
            self.navigationItem.prompt = nil
        }
        
    }
    
    func deleteSelected() {
        
        if let selected = collectionView?.indexPathsForSelectedItems {
            var toDelete = selected
            if let headerCell = (self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as? HeaderCollectionViewCell) {
                if let headerToDelete = headerCell.collectionView.indexPathsForSelectedItems {
                    for iP in headerToDelete {
                        toDelete.append(iP)
                    }
                }
            }
            if !toDelete.isEmpty {
                let alert = UIAlertController()
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler:
                    { alert in
                        for indexPath in toDelete {
                            let sect = Sections(rawValue: indexPath.section)!
                            switch sect {
                            case .header:
                                if let headerCollectionView = (self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as! HeaderCollectionViewCell).collectionView {
                                    let cell = headerCollectionView.cellForItem(at: indexPath)
                                    try! self.realm.write {
                                        self.realm.delete((cell as! SingleCollectionViewCell).promo!)
                                    }
                                }
                            case .single:
                                let cell = self.collectionView?.cellForItem(at: indexPath)
                                try! self.realm.write {
                                    self.realm.delete((cell as! SingleCollectionViewCell).promo!)
                                }
                            default: break
                                
                            }
                        }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
    
    // CollectionView.cellForItemAt Animation
    
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
                cell.collectionView.isDirectionalLockEnabled = false
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
                
                //Animation on cellForItemAt
                
                cell.imageLeft.layer.newsAnimation()
                cell.imageRight.layer.newsAnimation()
                return cell
            case .content:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentIdentifier, for: indexPath) as! ContentCollectionViewCell
                cell.promo = promotions.content[indexPath.row]
                return cell
            }
            
        }
    }
    
    //Headers titles
    
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
    
    //MARK: - CollectionViewDelegate Animation
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.05, animations: {
            cell?.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.6, animations: {
            cell?.transform = CGAffineTransform.identity
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            cell?.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                
                cell?.transform = CGAffineTransform.identity
            })
        })
        cell?.selectedBackgroundView?.backgroundColor = UIColor.getRandomColor()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            cell?.transform = CGAffineTransform.identity
            cell?.backgroundColor = UIColor.clear
        })
    }
}

//MARK: - FlowLayout Delegate Item's size

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
    // Setting header size and custom collectionview
    func setupCollectionViewLayout() {
        let layout = CustomFlowLayout()
        layout.headerReferenceSize = CGSize(width: 100, height: 20 )
        collectionView?.collectionViewLayout = layout
    }
}

//MARK: - List extension for different collectionview's batch update

extension List {
    func registerNotification(collectionView: UICollectionView?, section : Int ) -> NotificationToken
    {
        return self.addNotificationBlock { [weak collectionView] changes in
            guard let collectionView = collectionView else { return }
            switch changes
            {
            case .initial:
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [UIViewAnimationOptions.preferredFramesPerSecond60, ], animations:
                    { () -> Void in
                        collectionView.reloadSections(IndexSet(integer: section))
                }, completion: { _ in })
                
            case .update(_, let deletions, let insertions, let modifications):
                print(deletions, insertions, modifications,section)
                
                //Animation
                
                if Settings.enambleSpring
                {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations:
                        
                        { () -> Void in
                            collectionView.performBatchUpdates(
                                {
                                    collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: section)}))
                                    
                                    collectionView.deleteItems(at: deletions.map({IndexPath(row: $0, section: section)}))
                                    
                                    collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: section)}))
                                    
                                    
                            }, completion: nil)
                    }, completion: { _ in })
                //No Animation
                } else {
                    collectionView.performBatchUpdates(
                        {
                            collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: section)}))
                            
                            collectionView.deleteItems(at: deletions.map({IndexPath(row: $0, section: section)}))
                            
                            collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: section)}))
                            
                            
                    }, completion: nil)
                }
                
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
    }
}


//MARK: - CustomFlowLayout extension animation

class CustomFlowLayout : UICollectionViewFlowLayout {
    //Initial zoom in
    override func initialLayoutAttributesForAppearingItem( at itemIndexPath: IndexPath) ->UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        attributes?.alpha = 0.0
        attributes?.transform = CGAffineTransform(
            scaleX: 0.01,
            y: 0.01
        )
        return attributes
    }
    
}

