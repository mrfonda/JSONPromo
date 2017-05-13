//
//  AppDelegate.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 11/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import UIKit
import RealmSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      let promotions = Promotions(JSON: JSONUtils.goodJSON)
      let realm = try! Realm()
      try! realm.write {
        realm.add(promotions!, update: true)
      }
    return true
  }
}

