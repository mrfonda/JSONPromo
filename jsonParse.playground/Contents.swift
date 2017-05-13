

import UIKit

func readJSON(fileName: String) -> [String: Any]?
{
  do
  {
    if let file = Bundle.main.url(forResource: fileName, withExtension: "json")
    {
      let data = try Data(contentsOf: file)
      let json = try? JSONSerialization.jsonObject(with: data, options: [])
      if let object = json as? [String: Any]
      {
        return object
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  catch
  {
    //handle error
    return nil
  }
}

let badJSON = readJSON(fileName: "bad")

func makeGoodJSON(_ badJson: [String: Any]) -> [String: Any] {
  
  func makeGoodSingle(_ badData: Dictionary<String, Any>) -> Dictionary<String, Any> {
    var goodData = Dictionary<String, Any>()
    goodData["image_url"] = badData["image_url"]
    goodData["cat_id"] = (badData["query"] as! String).components(separatedBy: "|").last ?? ""
    return goodData
  }
  
  func makeGoodPair(_ badData: Dictionary<String, Any>) -> (Dictionary<String, Any>, Dictionary<String, Any>) {
    var firstGoodData = Dictionary<String, Any>()
    var secondGoodData = Dictionary<String, Any>()
    
    firstGoodData["image_url"] = badData["image_url_start"]
    secondGoodData["image_url"] = badData["image_url_end"]
    firstGoodData["cat_id"] = (badData["query_start"] as! String).components(separatedBy: "|").last ?? ""
    secondGoodData["cat_id"] = (badData["query_end"] as! String).components(separatedBy: "|").last ?? ""
    return (firstGoodData, secondGoodData)
  }
  
  
  var goodHeaders = [Dictionary<String, Any>]()
  if let badHeaders = badJSON?["header"] as? [[String:Any]] {
    for badHeader in badHeaders {
      goodHeaders.append(makeGoodSingle(badHeader))
    }
  }
  
  let homepage = badJSON?["homepage"] as? [Dictionary<String, Any>]
  var singlePromo = [Dictionary<String, Any>]()
  var pairPromo = [Dictionary<String, Any>]()
  var contentPromo = [Dictionary<String, Any>]()
  var bestsellers = [[Dictionary<String, Any>]]()
  var location = [[Dictionary<String, Any>]]()
  if let homepage = homepage{
    for page in homepage{
      if let type = page["type"] as? String {
        switch type {
        case "single_promo":
          if let badSinglePromo = page["data"] as? [String:Any] {
            singlePromo.append(makeGoodSingle(badSinglePromo))
          }
        case "pair_promo":
          if let badPairPromo = page["data"] as? [String:Any] {
            let (first, second) = makeGoodPair(badPairPromo)
            pairPromo.append(first)
            pairPromo.append(second)
          }
        case "content_promo":
          if let content = page["data"] as? Dictionary<String, Any> {
            contentPromo.append(content)
          }
        case "location":
          if let loc = page["data"] as? [Dictionary<String, Any>]
          {
            location.append(loc)
          }
        case "bestsellers":
          if let best = page["data"] as? [Dictionary<String, Any>]
          {
            bestsellers.append(best)
          }
        default:
          break
        }
      }
    }
  }
  //let vari = ["header": goodHeaders, "single_promo" : singlePromo ]
  var goodJSON: [String: Any] = ["header": goodHeaders]
  
  if !singlePromo.isEmpty {
    goodJSON["single_promo"] = singlePromo
  }
  if !pairPromo.isEmpty {
    goodJSON["pair_promo"] = pairPromo
  }
  if !contentPromo.isEmpty {
    goodJSON["content_promo"] = contentPromo
  }
  if !location.isEmpty {
    goodJSON["location"] = location
  }
  if !bestsellers.isEmpty {
    goodJSON["bestsellers"] = bestsellers
  }
  return goodJSON
}

let goodJSON = makeGoodJSON(badJSON!)
//let json = try JSONSerialization.jsonObject(with: goodJSON, options: []) as? [String : Any]

if JSONSerialization.isValidJSONObject(goodJSON) {
print(goodJSON)
} else {
  print("Not a json!")
}


