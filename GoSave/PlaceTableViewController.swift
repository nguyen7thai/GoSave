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
    var selectedPlaceIndex: Int?
    
    //MARK: Private Methods
    
    private func savePlaces() {
        Place.saveAllPlace()
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
        let total = places.count
        let place = places[total - 1 - indexPath.row]
        
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.places.remove(at: indexPath.row)
            Place.saveAllPlace(places: self.places)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationmgr.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        places = Place.savedPlaces
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
 
    @IBAction func addPlace(_ sender: UIBarButtonItem) {
        if let location = locationmgr.location {
            Place.getAddressForLocation(location: location, handler: {(placeMark: CLPlacemark) in
                if let draftPlace = Place(placeMark: placeMark, location: location) {
                    let newIndexPath = IndexPath(row: 0, section: 0)
                    self.places.append(draftPlace)
                    Place.saveAllPlace(places: self.places)
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
            
            self.selectedPlaceIndex = self.places.count - 1 - indexPath.row
            placeDetailViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(openEditPlaceControllerView))
            placeDetailViewController.placeIndex = self.selectedPlaceIndex
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch(identifier) {
        case "ShowDetail":
            if locationmgr.location != nil {
                return true
            } else {
                let vc = (storyboard?.instantiateViewController(
                    withIdentifier: "NoLocation"))!
                self.navigationController?.pushViewController(vc, animated: true)
                return false
            }
        default :
            return true
        }
    }
    

    
    // Mark: Private functions
    func openEditPlaceControllerView(button: UIBarButtonItem) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "EditPlaceController") as! EditPlaceViewController
        viewController.placeIndex =  self.selectedPlaceIndex!
        present(viewController, animated: true, completion: nil)
    }

    
}

