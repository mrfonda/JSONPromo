//
//  ContentPromo.swift
//  JSONPromo
//
//  Created by Vladislav Dorfman on 13/05/2017.
//  Copyright © 2017 Vladislav Dorfman. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm


class ContentPromo: Object, Mappable {
  dynamic var promo_text : String = ""
  dynamic var image_url : String = ""
  dynamic var link : String = ""
  required convenience init?(map: Map) {
    self.init()
  }
  override class func primaryKey() -> String? {
    return "link"
  }
  func mapping(map: Map) {
    promo_text <- map["cat_id"]
    image_url <- map["image_url"]
    link <- map["link"]
  }
}
