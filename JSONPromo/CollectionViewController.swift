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

class CollectionViewController: UICollectionViewController {
  let realm = try! Realm()
  var promotions: Promotions {
    get {
      let storedPromotions = realm.objects(Promotions.self)
      return storedPromotions[0]
    }
  }
  var storedOffsets = [Int: CGFloat]()
  
  enum Sections : Int, CaseCountable {
    case header = 0
    case single = 1
    case pair = 2
    case content = 3
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    //self.collectionView!.register(SingleCollectionViewCell.self, forCellWithReuseIdentifier: singleIdentifier)
    collectionView?.autoresizesSubviews = true
    self.collectionView!.register(UINib(nibName: "PairCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: pairIdentifier)
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  
  
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    switch collectionView.restorationIdentifier ?? "" {
    case "PromotionsHeaderView":
      return 1
    default:
      return Sections.count
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      //3
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: "SectionHeader",
                                                                       for: indexPath) as! SectionHeaderCollectionReusableView
      
      let sect = Sections(rawValue: indexPath.section)!
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
      cell.imageView.image = nil
      cell.layer.cornerRadius = 2
      cell.layer.masksToBounds = true
      cell.frame.size.height = collectionView.frame.height
      Nuke.loadImage(with: URL(string: promotions.head[indexPath.row].image_url)!,
                     into: cell.imageView)
      return cell
    default:
      let sect = Sections(rawValue: indexPath.section)!
      switch sect {
      case .header:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCollectionViewCell
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        return cell
      case .single:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
        cell.imageView.image = nil
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        Nuke.loadImage(with: URL(string: promotions.single[indexPath.row].image_url)!,
                       into: cell.imageView)
        return cell
      case .pair:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pairIdentifier, for: indexPath) as! PairCollectionViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        cell.imageLeft.image = nil
        cell.imageRight.image = nil
        let index = indexPath.row * 2
        
        Nuke.loadImage(with: URL(string: promotions.pair[index].image_url)!,
                       into: cell.imageLeft)
        if (index + 1) < promotions.pair.count {
          Nuke.loadImage(with: URL(string: promotions.pair[index + 1].image_url)!,
                         into: cell.imageRight)
        }
        return cell
      case .content:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: singleIdentifier, for: indexPath) as! SingleCollectionViewCell
        cell.imageView.image = nil
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        Nuke.loadImage(with: URL(string: promotions.content[indexPath.row].image_url)!,
                       into: cell.imageView)
        return cell
      }
      
    }
  }
  
}

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let screenWidth = collectionView.bounds.width//UIScreen.main.bounds.width
    let scaleFactor = collectionView.bounds.height //screenWidth
    
    switch collectionView.restorationIdentifier ?? "" {
    case "PromotionsHeaderView":
      return CGSize(width: screenWidth/1.5, height: scaleFactor)
    default:
      let sect = Sections(rawValue: indexPath.section)!
      switch sect {
      case .header:
        return CGSize(width: screenWidth, height: scaleFactor/4)
      default:
        return CGSize(width: screenWidth - 20, height: scaleFactor/4)
      }
      
    }
  }
  
}
protocol CaseCountable: RawRepresentable {}
extension CaseCountable where RawValue == Int {
  static var count: RawValue {
    var i: RawValue = 0
    while let _ = Self(rawValue: i) { i += 1 }
    return i
  }
}
