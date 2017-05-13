//
//  Promo.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 11/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//
import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class Promo: Object, Mappable {
  dynamic var cat_id : String = ""
  dynamic var image_url : String = ""
 
  required convenience init?(map: Map) {
    self.init()
  }
  override class func primaryKey() -> String? {
    return "cat_id"
  }
  func mapping(map: Map) {
    cat_id <- map["cat_id"]
    image_url <- map["image_url"]
  }
}


 
