//
//  Promotions.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 13/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class Promotions : Object, Mappable  {
  var key = "promotions"
  var head = List<Promo>()
  var single = List<Promo>()
  var pair = List<Promo>()
  var content = List<ContentPromo>()
  
  
  
  required convenience init?(map: Map) {
    self.init()
  }
  override class func primaryKey() -> String? {
    return "key"
  }
  func mapping(map: Map) {
    head <- (map["header"],ListTransform<Promo>())
    single <- (map["single_promo"],ListTransform<Promo>())
    pair <- (map["pair_promo"],ListTransform<Promo>())
    content <- (map["content_promo"],ListTransform<ContentPromo>())
  }
}
