//
//  ViewController.swift
//  GoSave
//
//  Created by Thai Nguyen on 2/28/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import os.log
import MapKit

class PlaceTableViewController: UITableViewController {
    //MARK: Properties
    var places = [Place]()
    let locationmgr = CLLocationManager()
    var selectedPlace: Place?
    
    //MARK: Private Methods
    private func loadSamplePlace() {
        /*
        let photo1 = UIImage(named: "DefaultImage")
        guard let place1 = Place(name: "Place 1", photo: photo1) else {
            fatalError("Unable to instantiate place")
        }
        guard let place2 = Place(name: "Place 2", photo: photo1) else {
            fatalError("Unable to instantiate place")
        }
        guard let place3 = Place(name: "Place 3", photo: photo1) else {
            fatalError("Unable to instantiate place")
        }
        places += [place1, place2, place3]
         */
        
    }
    
    private func savePlaces() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(places, toFile: Place.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Place successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Place...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadPlaces() -> [Place]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Place.ArchiveURL.path) as? [Place]
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlaceTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        if let description = place.placeDescription {
            cell.placeDescriptionLabel.text = description
        } else {
            cell.placeDescriptionLabel.text = ""
        }
        cell.photoImageView.image = place.photo
        cell.photoImageView.layer.cornerRadius = 23
        cell.photoImageView.layer.masksToBounds = true
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSamplePlace()
        // Do any additional setup after loading the view, typically from a nib.
        if let savedPlaces = loadPlaces() {
            places += savedPlaces
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func unwindToPlaceList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddPlaceViewController, let place = sourceViewController.place {
            // Add a new meal.
            let newIndexPath = IndexPath(row: places.count, section: 0)
            places.append(place)
            savePlaces()
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    @IBAction func addPlace(_ sender: UIBarButtonItem) {
        if let location = locationmgr.location {
            Place.getAddressForLocation(location: location, handler: {(placeMark: CLPlacemark) in
                if let draftPlace = Place(placeMark: placeMark, location: location) {
                    let newIndexPath = IndexPath(row: self.places.count, section: 0)
                    self.places.append(draftPlace)
                    self.savePlaces()
                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                } else {
                    fatalError("Error when init Draft Place")
                }
            })
        } else {
            let vc = (storyboard?.instantiateViewController(
                withIdentifier: "NoLocation"))!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddPlace":
            os_log("Adding a new place.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let placeDetailViewController = segue.destination as? PlaceDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? PlaceTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            self.selectedPlace = places[indexPath.row]
            savePlaces()
            placeDetailViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(openEditPlaceControllerView))
            placeDetailViewController.place = self.selectedPlace
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // Mark: Private functions
    func openEditPlaceControllerView(button: UIBarButtonItem) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "EditPlaceController") as! AddPlaceViewController
        viewController.place = self.selectedPlace!
        present(viewController, animated: true, completion: nil)
    }

    
}

