//
//  PlaceDetailViewController.swift
//  GoSave
//
//  Created by Thai Nguyen on 3/1/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class PlaceDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var placeDescriptionLabel: UILabel!

    let locationmgr = CLLocationManager()
    var placeIndex: Int?
    var place: Place?
    var sourceMapItem: MKMapItem?
    var destinationMapItem: MKMapItem?
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationmgr.desiredAccuracy = kCLLocationAccuracyBest
        locationmgr.startUpdatingLocation()
        locationmgr.delegate = self
        }
    
    override func viewDidAppear(_ animated: Bool) {
        // Draw routes between current location and place location
        let currentLocation = locationmgr.location!
        let currentCoordinate = currentLocation.coordinate
        let places = Place.savedPlaces
        
        if let index = placeIndex {
            let place = places[index]
            self.place = place
            nameLabelField.text = place.name
            placeDescriptionLabel.text = place.placeDescription
            photoImageView.image = place.photo
            
            let location = place.location
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 14.0)
            mapView.camera = camera
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            
            // Creates a marker for place
            let marker = GMSMarker()
            marker.position = location.coordinate
            marker.title = "Place Destination"
            marker.map = mapView
            
            place.askGoogleForRoute(sourceCoordinate: currentCoordinate, processPath: { (path: GMSPath) -> Void in
                DispatchQueue.main.async {
                    let polyLine = GMSPolyline(path: path)
                    polyLine.strokeWidth = 2.0
                    polyLine.map = self.mapView
                }
            })
        }

    }
    
    //MARK: CLLocationManagerDelegate
    // Update map when location change
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
