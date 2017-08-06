//
//  SignUpViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var nameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var signUpButton: LoadingButton!
    @IBOutlet weak var credentialStackView: UIStackView!
    
    let pickerController = UIImagePickerController()
    let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        signUpButton.backgroundColor = UIColor.tertiary()
        signUpButton.setTitleColor(UIColor.primaryText(), for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            nameField.becomeFirstResponder()
        }
        if textField == nameField {
            passwordField.becomeFirstResponder()
        }
        if textField == passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    func initLayout() {
        emailField.delegate = self
        nameField.delegate = self
        passwordField.delegate = self
        pickerController.delegate = self
        emailField.borderTop()
        nameField.borderTop()
        passwordField.borderTop()
        passwordField.borderBottom()
        credentialStackView.addBottomBorder(color: UIColor.tertiary(), width: 1.0)
        let placeholderImage = UIImage(named: Constants.Images.ProfilePlaceHolder)
        userImageView.image = placeholderImage
        view.layoutIfNeeded()
        userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.choosePicture(_:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @IBAction func choosePicture(_ sender: Any) {
        
        pickerController.allowsEditing = false
        var cameraAction = UIAlertAction()
        
        let alertController = UIAlertController(title: "Add a profile picture", message: "Choose From", preferredStyle: .actionSheet)
        
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
            self.present(
              self.pickerController, animated: true, completion: nil)
            
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
      
      guard let email = emailField.text, let password = passwordField.text, let name = nameField.text else {return}
        let alert = UIAlertController()
        
        if email.isEmpty || password.isEmpty || name.isEmpty {
            
            alert.defaultAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.RequiredFieldsMessage)
        }
            
        else if ValidationHelper.isValidEmail(email) && ValidationHelper.isPwdLength(password) {
            
            self.showLoading(true)
            
          guard let resizedImage = self.userImageView.image?.resizeImageAspectFill(newSize: CGSize(500, 500)), let data = UIImageJPEGRepresentation(resizedImage, 1) else {return}
                
                self.dataService.signUp(email, name, password, data as NSData, completion: { (success) in
                    
                    self.showLoading(false)
                    
                    if success {
                       alert.defaultAlert(nil, Constants.Notifications.VerifyEmailMessage)
                    }
                    else {
                        let message = "The email address is already in use by another account."
                       alert.defaultAlert(Constants.Notifications.GenericFailureTitle, message)
                    }
                })
            
            dismiss(animated: true, completion: nil)
        }
            
        else {
            alert.defaultAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoValidPasswordMessage)
            
        }
    }
    
    
    private func showLoading(_ loading: Bool) {
        
        if loading {
            signUpButton.showLoading()
            signUpButton.backgroundColor = UIColor.primary()
            signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        else {
            signUpButton.backgroundColor = UIColor.tertiary()
            signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            signUpButton.hideLoading()
        }
    }
    

    
    @IBAction func signUpCancelled(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func linkToTerms(_ sender: Any) {
        if let link = URL(string: Constants.ExternalLinks.YaknakTermsLink) {
        UIApplication.shared.openURL(link)
        }
    }
    
    
    @IBAction func linkToPolicy(_ sender: Any) {
        if let link = URL(string: Constants.ExternalLinks.YaknakPrivacyLink) {
        UIApplication.shared.openURL(link)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        userImageView.image = chosenImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func noCamera() {
        let alert = UIAlertController()
        alert.defaultAlert(Constants.Notifications.NoCameraTitle, Constants.Notifications.NoCameraMessage)
    }
    
}
