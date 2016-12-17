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
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var nameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    
    
    let pickerController = UIImagePickerController()
    let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.nameField.delegate = self
        self.passwordField.delegate = self
        self.pickerController.delegate = self
        
        self.emailField.borderTop()
        self.nameField.borderTop()
        self.passwordField.borderTop()
        self.passwordField.borderBottom()
        
        let placeholderImage = UIImage(named: "splashIcon")
        self.userImageView.image = placeholderImage
        
        
        self.view.layoutIfNeeded()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.clipsToBounds = true
        
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.choosePicture(_:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.signUpButton.backgroundColor = UIColor.smokeWhiteColor()
        self.signUpButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.nameField.becomeFirstResponder()
        }
        if textField == self.nameField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
    @IBAction func choosePicture(_ sender: Any) {
        
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
        
        if emailField.text == "" || passwordField.text == "" || nameField.text == "" {
            
            let alertController = UIAlertController()
            alertController.defaultAlert(title: "Oops!", message: "Please fill in all required fields.")
        }
            
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            if let resizedImage = self.userImageView.image?.resizedImage(newSize: CGSize(250, 250)) {
                
                let data = UIImageJPEGRepresentation(resizedImage, 0.8)
                
                
                self.dataService.signUp(email: self.emailField.text!, name: self.nameField.text!, password: self.passwordField.text!, data: data! as NSData)
                self.signUpButton.backgroundColor = UIColor.primaryColor()
                self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            }
            dismiss(animated: true, completion: nil)
        }
            
        else {
            let alertController = UIAlertController()
            alertController.defaultAlert(title: "Oops!", message: "The password has to be 6 characters long or more.")
        }
        
    }
    
    
    @IBAction func signUpCancelled(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func linkToTerms(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://yaknakapp.com/terms/")! as URL)
    }
    
    
    @IBAction func linkToPolicy(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://yaknakapp.com/privacy/")! as URL)
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
        let alertController = UIAlertController()
        alertController.defaultAlert(title: Constants.Notifications.NoCameraTitle, message: Constants.Notifications.NoCameraMessage)
    }
    
    
}
