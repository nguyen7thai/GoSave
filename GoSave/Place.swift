//
//  Place.swift
//  GoSave
//
//  Created by Thai Nguyen on 2/28/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import os.log

class Place: NSObject, NSCoding {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var location: CLLocation
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let location = "location"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("places")

    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, location: CLLocation) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.location = location
    }
    
    init?(photo: UIImage?, location: CLLocation) {
        self.name = "Auto Generated"
        self.photo = photo
        self.location = location
    }
    
    //MARK: NSCodin
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(location, forKey: PropertyKey.location)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? CLLocation
        // Must call designated initializer.
        self.init(name: name, photo: photo, location: location!)
    }
    
    //MARK: Maps function
    func askGoogleForRoute(sourceCoordinate: CLLocationCoordinate2D) {
//        let dataURL = URL(string: "https://foodeals.herokuapp.com/deal_items")!
//        let task = URLSession.shared.dataTask(with: dataURL, completionHandler: { (data, response, error) in
//            if error == nil {
//                do {
//                    let data = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//                    let dealItemsRaw = data["deal_items"] as! [[String:AnyObject]]
//                    var dealItems = [DealItem]()
//                    for dict in dealItemsRaw {
//                        dealItems.append(DealItem(dict: dict))
//                    }
//                    handler(dealItems, nil)
//                } catch {
//                    handler(nil, NSError(domain: "getDeals", code: 1, userInfo: nil))
//                }
//            } else {
//                handler(nil, error as NSError?)
//            }
//            
//        })
//        task.resume()
    }
}
