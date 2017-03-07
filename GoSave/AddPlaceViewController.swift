//
//  AddPlaceViewController.swift
//  GoSave
//
//  Created by Thai Nguyen on 2/28/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import os.log

class AddPlaceViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    var place: Place?
    let geocoder = CLGeocoder()
    let locationmgr = CLLocationManager()
    var location: CLLocation?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationmgr.requestWhenInUseAuthorization()
        nameTextField.delegate = self
        location = locationmgr.location
        getAddressForLocation(location: location!, handler: {(placeMark: CLPlacemark) in
            self.nameTextField.placeholder = placeMark.name
            var description = ""
            description += "Address: \(placeMark.name)\n"
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let currentTime = formatter.string(from: Date())
            description += "Saved Time: \(currentTime)\n"
            self.descriptionTextView.text = description
        })
        
        nameTextField.layer.shadowOffset = CGSize(width: 0, height: -4)
        nameTextField.layer.shadowColor = UIColor.red.cgColor
        nameTextField.layer.shadowOpacity = 0.4
        nameTextField.layer.shadowRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        var name = nameTextField.text
        if name == nil || name == "" {
            name = nameTextField.placeholder ?? ""
        }
        
        let photo = photoImageView.image
        let description = descriptionTextView.text
        if let location = location {
            if let place = Place(name: name!, photo: photo, location: location, placeDescription: description) {
                self.place = place
            } else {
                fatalError("Cannot init place")
            }
            
        }
        else {
            fatalError("Problem with location")
        }
    }
    
    
    //MARK: Actions
    @IBAction func selectPhoto(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken.
        
        imagePickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        }
        else
        {
            imagePickerController.sourceType = .photoLibrary
        }
        present(imagePickerController, animated: true, completion: nil)

    }
        
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            fatalError("The AddPlaceViewController is not inside a navigation controller.")
        }
    }
    
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
//        updateSaveButtonState()
        saveButton.isEnabled = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    //MARK: Private Methods
    private func getAddressForLocation(location: CLLocation, handler: @escaping (_ placeMark: CLPlacemark) -> Void) {
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
