//
//  Place.swift
//  GoSave
//
//  Created by Thai Nguyen on 2/28/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import os.log

class Place: NSObject, NSCoding {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var location: CLLocation
    var placeDescription: String?
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let location = "location"
        static let placeDescription = "placeDescription"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("places")

    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, location: CLLocation, placeDescription: String?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.location = location
        self.placeDescription = placeDescription
    }
    
    init?(placeMark: CLPlacemark, location: CLLocation) {
        self.name = placeMark.name!
        var description = ""
        description += "Address: \(placeMark.name!)\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let currentTime = formatter.string(from: Date())
        description += "Saved Time: \(currentTime)\n"
        self.placeDescription = description
        let defaultImage = UIImage(named: "DefaultImage")
        self.photo = defaultImage
        self.location = location
    }
    
    //MARK: NSCodin
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(placeDescription, forKey: PropertyKey.placeDescription)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? CLLocation
        let placeDescription = aDecoder.decodeObject(forKey: PropertyKey.placeDescription) as? String
        // Must call designated initializer.
        self.init(name: name, photo: photo, location: location!, placeDescription: placeDescription)
    }
    
    //MARK: Maps function
    func askGoogleForRoute(sourceCoordinate: CLLocationCoordinate2D, processPath: @escaping (_ path: GMSPath) -> Void) {
        //https://maps.googleapis.com/maps/api/directions/json?origin=Boston,MA&destination=Concord,MA&waypoints=Charlestown,MA|Lexington,MA&key=AIzaSyAVSznAZ0UJXFiDLNLJfN_rBajYLYnKV94
        var directionURL = URLComponents(string: "https://maps.googleapis.com/maps/api/directions/json")
        let originQuery = URLQueryItem(name: "origin", value: "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)")
        let placeCoordinate = self.location.coordinate
        let destinationQuery = URLQueryItem(name: "destination", value: "\(placeCoordinate.latitude),\(placeCoordinate.longitude)")
        let keyQuery = URLQueryItem(name: "key", value: "AIzaSyAVSznAZ0UJXFiDLNLJfN_rBajYLYnKV94")
        directionURL?.queryItems = [originQuery, destinationQuery, keyQuery]
        let url = directionURL?.url
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error == nil {
                do {
                    let data = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let routes = data["routes"] as! [[String:Any]]
                    let overviewPolyline = routes[0]["overview_polyline"] as! [String:String]
                    let encodedPolyline = overviewPolyline["points"]
                    let path = GMSPath(fromEncodedPath: encodedPolyline!)
                    processPath(path!)
                } catch {
                    fatalError("Error asking google for direction")
                }
            } else {
                fatalError("Error api call asking google for direction")
            }
        
        })
        
        task.resume()
    }
    
    static func getAddressForLocation(location: CLLocation, handler: @escaping (_ placeMark: CLPlacemark) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if error != nil {
                    os_log("reverse geodcode fail", type: .debug)
                } else {
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        handler(pm[0])
                    }
                }
        })
    }
}
