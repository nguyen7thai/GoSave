//
//  EditPlaceViewController.swift
//  GoSave
//
//  Created by Thai Nguyen on 2/28/17.
//  Copyright © 2017 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import os.log

class EditPlaceViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    var place: Place?
    var placeIndex: Int?

    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        if let index = self.placeIndex {
            let place = Place.savedPlaces[index]
            self.place = place
            nameTextField.text = place.name
            photoImageView.image = place.photo
            descriptionTextView.text = place.placeDescription
        } else {
            fatalError("No Place to Edit")
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: nameTextField.frame.height - 1, width: nameTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(hex: "979797").cgColor
//        bottomLine.backgroundColor = UIColor.red.cgColor
        nameTextField.layer.addSublayer(bottomLine)
        
    
        
//        descriptionTextView.layer.addSublayer(bottomLine)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatePlace(_ sender: UIButton) {
        var name = nameTextField.text
        if name == nil || name == "" {
            name = nameTextField.placeholder ?? ""
        }
        
        let photo = photoImageView.image
        let description = descriptionTextView.text
        if let place = self.place {
            place.photo = photo
            place.name = name!
            place.placeDescription = description
            Place.savePlace(index: self.placeIndex!, place: place)
        } else {
            fatalError("No Place To Edit")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
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

}
