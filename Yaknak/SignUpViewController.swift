//
//  SignUpViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    let pickerController = UIImagePickerController()
    let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.passwordField.delegate = self
        self.pickerController.delegate = self
        
        let placeholderImage = UIImage(named: "splashIcon")
        self.userImageView.image = placeholderImage
        
        
        self.view.layoutIfNeeded()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.clipsToBounds = true
        
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.choosePicture(_:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.firstNameField.becomeFirstResponder()
        }
        if textField == self.firstNameField {
            self.lastNameField.becomeFirstResponder()
        }
        if textField == self.lastNameField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
    func choosePicture(_ sender: UITapGestureRecognizer) {
        
        
        pickerController.allowsEditing = false
        var cameraAction = UIAlertAction()
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        
        
         cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.pickerController.sourceType = .camera
            self.pickerController.cameraCaptureMode = .photo
           
                self.present(self.pickerController, animated: true, completion: nil)
        }
            
        
        
        
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            self.pickerController.sourceType = .photoLibrary
            self.present(self.pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            self.pickerController.sourceType = .savedPhotosAlbum
            self.present(self.pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            alertController.addAction(cameraAction)

        }
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    
    @IBAction func signUpTapped(_ sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" || firstNameField.text == "" {
            
            let alertController = UIAlertController(title: "Oops!", message: "Please fill in all required fields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
            
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            
            let data = UIImageJPEGRepresentation(self.userImageView.image!, 0.8)
            
            
            self.dataService.signUp(email: self.emailField.text!, name: self.firstNameField.text!, password: self.passwordField.text!, data: data! as NSData)
            
            dismiss(animated: true, completion: nil)
        }
            
        else {
            
            let alertController = UIAlertController(title: "Oops!", message: "The password has to be 6 characters long or more.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func signUpCancelled(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        self.userImageView.image = chosenImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func noCamera() {
        
        let alertVC = UIAlertController(
            title: Constants.Notifications.NoCameraTitle,
            message: Constants.Notifications.NoCameraMessage,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: Constants.Notifications.AlertConfirmation,
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                              animated: true,
                              completion: nil)
    }
    
    
}
