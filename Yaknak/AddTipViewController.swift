//
//  AddTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import MBProgressHUD
import HTHorizontalSelectionList
import Photos
import GooglePlaces
import Kingfisher
import Firebase



private let selectionListHeight: CGFloat = 50
private let SCREEN_SIZE = UIScreen.main.bounds


@objc protocol ImagePickerDelegate {
    @objc optional func imagePicker(pickedImage image: UIImage?)
}



class AddTipViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver {
    
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tipField: PlaceholderTextView!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var saveTipButton: UIButton!
    @IBOutlet weak var tipFieldHeightConstraint: NSLayoutConstraint!
    
    private let collectionReuseIdentifier = "PhotoCell"
    private let cameraReuseIdentifier = "CameraCell"
    var imageArray = [UIImage]()
    var pinMapViewController: PinMapViewController!
    var selectedCategory: String?
    var destination: CLLocation?
    private var responseData: NSMutableData?
    var selectedPlaceId: String?
    private var selectedTipCoordinates: CLLocationCoordinate2D?
    private var connection: NSURLConnection?
    private var dataTask: URLSessionDataTask?
    private let autocompleteAPIKey = Constants.Config.AutocompleteAPIKey
    private let baseURLString = Constants.Config.AutomCompleteString
    private let geoCodeBaseUrl = Constants.Config.GeoCodeString
    let picker = UIImagePickerController()
    let reuseIdentifier = Constants.Identifier.CategoryIdentifier
    var categories = [String]()
    var selectionList: HTHorizontalSelectionList!
    var finalImageView: UIImageView!
    var finalImageViewContainer: UIView!
    var cancelImageIcon: UIButton!
    var layoutFinalImage: Bool?
    var delegate: ImagePickerDelegate?
    let dataService = DataService()
    var loadingNotification = MBProgressHUD()
    var didFindLocation: Bool = false
    let geoTask = GeoTasks()
    var images: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    var cacheController: PhotoLibraryCacheController!
    var didAddCoordinates: Bool = false
    var isEditMode: Bool = false
    var tipEdit: TipEdit?
    var catRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tipFieldHeightConstraint.constant = tipFieldHeightConstraintConstant()
        self.tipField.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        self.tipField.textColor = UIColor.primaryTextColor()
        self.catRef = self.dataService.CATEGORY_REF
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false) ]
        images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        cacheController = PhotoLibraryCacheController(imageManager: imageManager, images: self.images as! PHFetchResult<AnyObject>, preheatSize: 1)
        PHPhotoLibrary.shared().register(self)
        
        PhotoLibraryHelper.sharedInstance.onPermissionReceived = { received in
            
            if received {
                print("Photo permission received...")
                self.setupPhotoLibrary()
            }
            else {
                self.showNoAccessLabel()
            }
            
        }
        
        
        PhotoLibraryHelper.sharedInstance.onSettingsPrompt = {
            let title = "Info"
            let message = "Yaknak needs to get access to your photos"
            self.showNeedAccessMessage(title: title, message: message)
        }
        
        
        PhotoLibraryHelper.sharedInstance.requestPhotoPermission()
        
        self.finalImageView = UIImageView()
        self.finalImageViewContainer = UIView()
        self.configureSaveTipButton()
        self.layoutFinalImage = false
        self.tipField.delegate = self
        self.autocompleteTextfield.delegate = self
        self.configureNavBar()
        self.picker.delegate = self
        self.configureTextField()
        self.handleTextFieldInterfaces()
        
        LocationService.sharedInstance.onTracingLocation = { currentLocation in
            
            if !self.didFindLocation {
                print("Location is being tracked...")
                let lat = currentLocation.coordinate.latitude
                let lon = currentLocation.coordinate.longitude
                
                self.dataService.setUserLocation(lat, lon)
                self.didFindLocation = true
                
                self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: lon, completionHandler: { (address, success) in
                    
                    if success {
                        DispatchQueue.main.async {
                            self.autocompleteTextfield.text = address
                        }
                        LocationService.sharedInstance.stopUpdatingLocation()
                        
                    }
                    else {
                        print("Could not get current location...")
                    }
                })
            }
            
        }
        
        LocationService.sharedInstance.onTracingLocationDidFailWithError = { error in
            print("tracing Location Error : \(error.description)")
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTipViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        self.characterCountLabel.text = "\(Constants.Counter.CharacterLimit)"
        self.characterCountLabel.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        self.categories = Constants.HomeView.Categories
        self.selectionList = HTHorizontalSelectionList()
        self.selectionList.delegate = self
        self.selectionList.dataSource = self
        self.selectionList.translatesAutoresizingMaskIntoConstraints = false
        self.selectionList.selectionIndicatorStyle = .bottomBar
        self.selectionList.selectionIndicatorColor = UIColor.primaryColor()
        self.selectionList.setTitleColor(UIColor.primaryTextColor(), for: .normal)
        self.selectionList.bottomTrimHidden = true
        self.selectionList.centerButtons = true
        self.selectionList.layer.borderWidth = 1
        self.selectionList.layer.borderColor = UIColor.smokeWhiteColor().cgColor
        self.selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);
        
        self.selectionView.addSubview(self.selectionList)
        
        let widthConstraint = NSLayoutConstraint(item: selectionList, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let heightConstraint = NSLayoutConstraint(item: selectionList, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: selectionListHeight)
        
        let topConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.selectionView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
      
        let leadingConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0)
        
        let trailingConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        
        self.view.addConstraints([widthConstraint, heightConstraint, topConstraint, leadingConstraint, trailingConstraint])
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "editTip"),
                                               object: nil, queue: nil, using: catchNotification)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureProfileImage()
        if !isEditMode {
        self.selectionList.setSelectedButtonIndex(0, animated: false)
        self.selectedCategory = Constants.HomeView.DefaultCategory
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationService.sharedInstance.stopUpdatingLocation()
        
        if self.pinMapViewController != nil && self.pinMapViewController.isViewLoaded {
            self.pinMapViewController.removeAnimate()
            self.autocompleteTextfield.text = nil
        }
        
        if self.isEditMode {
            self.resetFields()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dataService.removeProfilePicObserver()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureNavBar() {
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tipFieldHeightConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568:
            return 205
            
        case 667:
            return 300
            
        case 736:
            return 356
            
        default:
            return 205
        }
    }
    
    
    func popUpPrompt() {
        let alertController = UIAlertController()
        alertController.networkAlert(Constants.NetworkConnection.NetworkPromptMessage)
    }
    
    
    
    private func setupPhotoLibrary() {
        
        for subView in self.collectionView.subviews {
            if (subView.tag == 100 || subView.tag == 200) {
                subView.removeFromSuperview()
            }
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    
    func catchNotification(notification: Notification) -> Void {
        guard let tip = notification.userInfo!["tip"] else {
            return
        }
        self.prefillTipDetails(tip as! Tip)
    }
    
    
    private func showNoAccessLabel() {
        
        DispatchQueue.main.async {
            
            let noAccessLabel = UILabel()
            noAccessLabel.tag = 100
            noAccessLabel.text = "No Access"
            noAccessLabel.font = UIFont.systemFont(ofSize: 17)
            noAccessLabel.textColor = UIColor.primaryTextColor()
            self.collectionView.addSubview(noAccessLabel)
            noAccessLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let style = NSMutableParagraphStyle()
            let attributes = [NSParagraphStyleAttributeName : style]
            style.lineSpacing = 2
            
            let noAccessText = UILabel()
            noAccessText.tag = 200
            noAccessText.attributedText = NSAttributedString(string: "Yaknak does not have access to your photos. You can enable access in Privacy Settings.", attributes:attributes)
            noAccessText.textAlignment = .center
            noAccessText.font = UIFont.systemFont(ofSize: 15)
            noAccessText.textColor = UIColor.primaryTextColor()
            noAccessText.numberOfLines = 3
            noAccessText.lineBreakMode = NSLineBreakMode.byWordWrapping
            noAccessText.sizeToFit()
            self.collectionView.addSubview(noAccessText)
            noAccessText.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: noAccessLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: noAccessLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -20).isActive = true
            
            NSLayoutConstraint(item: noAccessText, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: noAccessText, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: noAccessLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 4).isActive = true
            
            NSLayoutConstraint(item: noAccessText, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20).isActive = true
            
            NSLayoutConstraint(item: noAccessText, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20).isActive = true
        }
    }
    
    
    private func showNeedAccessMessage(title: String, message: String) {
        let alertController = UIAlertController()
        alertController.promptRedirectToSettings(title: title, message: message)
    }
    
    
    private func configureSaveTipButton() {
        self.saveTipButton.backgroundColor = UIColor.smokeWhiteColor()
        self.saveTipButton.setTitleColor(UIColor.secondaryTextColor(), for: .normal)
        self.saveTipButton.layer.cornerRadius = 5
        self.saveTipButton.isEnabled = false
    }
    
    
    
    @IBAction func addCurrentLocation(_ sender: Any) {
        self.openPinMap()
    }
    
    
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        
        if !isEditMode {
            if let resizedImage = self.finalImageView.image?.resizeImageAspectFill(newSize: CGSize(500, 700)) {
                
                if let pictureData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                    
                    self.uploadTip(tipPic: pictureData)
                }
            }
        }
        else {
            self.uploadTipEdit()
        }
        
        
    }
    
    
    func prefillTipDetails(_ tip: Tip) {
        
        for subView in self.view.subviews {
            if (subView.tag == 1) {
                resetFields()
            }
        }
        
        self.isEditMode = true
        
        
        self.postButton.setTitle("Done", for: .normal)
        if !tip.description.isEmpty {
            self.tipField.text = tip.description
            checkRemainingChars()
        }
        
        self.tipEdit = tip.toEdit()
        
        if !tip.category.isEmpty {
            if let category = tip.category {
                
                var index: Int
                
                switch category {
                case "eat":
                    index = 0
                case "drink":
                    index = 1
                case "dance":
                    index = 2
                case "free":
                    index = 3
                case "coffee":
                    index = 4
                case "shop":
                    index = 5
                case "deals":
                    index = 6
                case "outdoors":
                    index = 7
                case "watch":
                    index = 8
                case "special":
                    index = 9
                default:
                    index = 0
                }
                
                self.selectionList.setSelectedButtonIndex(index, animated: false)
                self.selectedCategory = Constants.HomeView.Categories[index]
            }
        }
        
        if let tipPicUrl = tip.tipImageUrl {
            
            if let url = URL(string: tipPicUrl) {
                
                self.finalImageView.kf.indicatorType = .activity
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 100), mode: .aspectFill)
                self.finalImageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    print("Progress: \(receivedSize)/\(totalSize)")
                    
                }, completionHandler: { (image, error, cacheType, imageUrl) in
                    
                    
                    if let placeId = tip.placeId {
                        if !placeId.isEmpty {
                            self.geoTask.getAddressFromPlaceId(placeId, completionHandler: { (address, success, error) in
                                
                                if let err = error {
                                    print("lookup place id query error: \(err.localizedDescription)")
                                }
                                
                                if success {
                                    DispatchQueue.main.async {
                                        self.autocompleteTextfield.text = address
                                    }
                                }
                                
                            })
                        }
                        else {
                            
                            if let key = tip.key {
                            self.dataService.getTipLocation(key, completion: { (location, error) in
                        
                                if error == nil {
                                    
                                    if let lat = location?.coordinate.latitude {
                                        
                                        if let long = location?.coordinate.longitude {
                                            
                                            self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completionHandler: { (address, success) in
                                                
                                                if success {
                                                    self.tipEdit?.placeId = self.selectedPlaceId
                                                    DispatchQueue.main.async {
                                                        self.autocompleteTextfield.text = address
                                                    }
                                                }
                                            })
                                            
                                        }
                                        
                                    }
                                    
                                }
                                else {
                                    if let err = error {
                                    print(err.localizedDescription)
                                    }
                                }
                                
                            })
                        }
                        }
                    }
                    
                    if image != nil {
                        self.setupFinalImage(image: image!)
                    }
                    else {
                        self.setupFinalImage(image: UIImage(named: Constants.Images.TipImagePlaceHolder)!)
                    }
                    
                })
                
            }
        }
        
    }
    
    
    
    private func uploadTip(tipPic: Data) {
        
        ProgressOverlay.show("0%")
        
        self.dataService.getCurrentUser { (user) in
            
            if let uid = user.key {
                
                if let name = user.name {
                
                    if let url = user.photoUrl {
                    
                        print("Category selected: " + self.selectedCategory!)
                        
                        let tipRef = self.dataService.TIP_REF.childByAutoId()
                        let key = tipRef.key
                
                        if let coordinates = self.selectedTipCoordinates {
                            
                            if let description = self.tipField.text {
                                
                                if let category = self.selectedCategory?.lowercased() {
                                
                                self.upload(key, tipPic, tipRef, uid, name, url, description, category) { (success) in
                                    
                                    if success {
                                        
                                        self.dataService.setTipLocation(coordinates.latitude, coordinates.longitude, key)
                                        
                                        if let tips = user.totalTips {
                                            
                                            var newTipCount = tips
                                            newTipCount += 1
                                            self.dataService.CURRENT_USER_REF.updateChildValues(["totalTips" : newTipCount], withCompletionBlock: { (error, ref) in
                                                
                                                if error == nil {
                                                    print("Tip succesfully stored in database...")
                                                    Analytics.logEvent("tipAdded", parameters: ["tipId" : key as NSObject, "category" : category as NSObject, "addedByUser" : name as NSObject])
                                                }
                                                
                                                
                                            })
                                            
                                        }
                                    }
                                    else {
                                        self.showUploadFailed()
                                        
                                    }
                                    
                                }
                            }
                            }
                        }
                        
                    }
                }
            }

        }
     
    }
    
    
    private func upload(_ key: String, _ tipPic: Data, _ tipRef: DatabaseReference, _ userId: String, _ userName: String, _ userPicUrl: String, _ description: String, _ category: String, completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        //Create Path for the tip Image
        let imagePath = "\(key)/tipImage.jpg"
        
        // Create image Reference
        let imageRef = self.dataService.STORAGE_TIP_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let uploadTask = imageRef.putData(tipPic as Data, metadata: metaData) { (metaData, error) in
            if error == nil {
                
                if let photoUrl = metaData?.downloadURL()?.absoluteString {
                    
                    var placeId = String()
                    if let id = self.selectedPlaceId {
                        if id.isEmpty {
                            placeId = ""
                        }
                        else {
                            placeId = id
                        }
                    }
                    
                    
                    let tip = Tip(category, description.censored(), 0, userName, userId, userPicUrl, photoUrl, true, placeId)
                    
                    tipRef.setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                        
                        if error == nil {
                            
                            self.catRef.child(category).child(key).setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    
                                    self.dataService.USER_TIP_REF.child(userId).child(key).setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                                        
                                        if error == nil {
                                            completionHandler(true)
                                            
                                        }
                                        else {
                                            completionHandler(false)
                                        }
                                        
                                    })
                                    
                                }
                            })
                        }
                        
                    })
                }
            }
            else {
                self.showUploadFailed()
            }
            
        }
        uploadTask.observe(.progress) { snapshot in
            
            if let progress = snapshot.progress {
            print(progress) // NSProgress object
            
            let percentageComplete = 100.0 * Double(progress.completedUnitCount)
                / Double(progress.totalUnitCount)
            
            
            ProgressOverlay.updateProgress(receivedSize: progress.completedUnitCount, totalSize: progress.totalUnitCount, percentageComplete: percentageComplete)
            }
            
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            DispatchQueue.main.async {
                //  ProgressOverlay.shared.hideOverlayView()
                self.showUploadSuccess()
                self.resetFields()
            }
        }
        
    }
    
    
    func uploadTipEdit() {
        
        let updateDict = createUpdateDict()
        ProgressOverlay.show("0%")
        
        self.dataService.getCurrentUser { (user) in
            
            if let uid = user.key {
            
                if let key = self.tipEdit?.key {
                
                    self.createTipObject(key, uid, updateDict, completionHandler: { (dict, updateCategory, success) in
                        
                        if success {
                            
                            self.dataService.BASE_REF.updateChildValues(dict, withCompletionBlock: { (error, ref) in
                                
                                if error == nil {
                                    
                                    if updateCategory {
                                        self.setTipCategory(key)
                                    }
                                    DispatchQueue.main.async {
                                        ProgressOverlay.hide()
                                        print("Successfully edited the tip...")
                                        self.resetFields()
                                        self.showEditSuccess()
                                    }
                                    Analytics.logEvent("tipEdited", parameters: ["tipId" : key as NSObject])
                                    
                                }
                                else {
                                    DispatchQueue.main.async {
                                        ProgressOverlay.hide()
                                        print("Editing failed...")
                                        self.resetFields()
                                        self.showEditFailed()
                                    }
                                    
                                }
                            })
                        }
                        else {
                            DispatchQueue.main.async {
                                ProgressOverlay.hide()
                                print("Editing failed...")
                                self.resetFields()
                                self.showEditFailed()
                            }
                        }
                        
                    })

                }
            }
        }
        
    }
    
    
    func removeTipFromCategory(_ category: String, _ key: String, _ userId: String,  _ updateCategory: Bool, completionHandler: @escaping (( _ obj: [String : String], _ success: Bool) -> Void)) {
        
        var tipObject = [String : String]()
        if updateCategory {
            self.dataService.CATEGORY_REF.child(category).child(key).removeValue(completionBlock: { (error, ref) in
                
                if error == nil {
                    print("Tip successfully deleted from previous category...")
                    
                    if let cat = self.tipEdit?.categoryEdited {
                        tipObject["tips/\(key)/category"] = cat.lowercased()
                        tipObject["userTips/\(userId)/\(key)/category"] = cat.lowercased()
                        completionHandler(tipObject, true)
                    }
                }
                else {
                    completionHandler(tipObject, false)
                }
            })
        }
        else {
            completionHandler(tipObject, true)
        }
    }
    
    
    func createTipObject(_ key: String, _ userId: String, _ updateDict: [String : Bool], completionHandler: @escaping ((_ dict: [String : String], _ updateCategory: Bool, _ success: Bool) -> Void)) {
        
        var dict = [String : String]()
        if let updateCategory = updateDict["updateCategory"] {
            
            if let category = self.tipEdit?.category {
                
                
                self.removeTipFromCategory(category, key, userId, updateCategory, completionHandler: { (obj, success) in
                    
                    if success {
                        
                        dict = obj
                        
                        if let updateDescription = updateDict["updateDescription"] {
                            
                            if updateDescription {
                                if let description = self.tipEdit?.descriptionEdited {
                                    dict["tips/\(key)/description"] = description
                                    dict["userTips/\(userId)/\(key)/description"] = description
                                    if !updateCategory {
                                        dict["categories/\(category)/\(key)/description"] = description
                                    }
                                }
                            }
                            
                            if let updateLocation = updateDict["updateLocation"] {
                                
                                if updateLocation {
                                    if let placeId = self.tipEdit?.placeIdChanged {
                                        dict["tips/\(key)/placeId"] = placeId
                                        dict["userTips/\(userId)/\(key)/placeId"] = placeId
                                        if !updateCategory {
                                            dict["categories/\(category)/\(key)/placeId"] = placeId
                                        }
                                        
                                        if !placeId.isEmpty {
                                            self.geoTask.getCoordinatesFromPlaceId(placeId, completionHandler: { (coordinates, success, error) in
                                                
                                                if let err = error {
                                                 print("lookup place id query error: \(err.localizedDescription)")
                                                }
                                                if success {
                                                   
                                                        if let lat = coordinates?.latitude {
                                                            if let lon = coordinates?.longitude {
                                                                self.dataService.setTipLocation(lat, lon, key)
                                                            }
                                                        }
                                                }
                                                else {
                                                    print("Could not get coordinates for this place...")
                                                }
                                            })
                                        }
                                    }
                                    
                                }
                                
                                if let updateImage = updateDict["updateImage"] {
                                    
                                    if updateImage {
                                        
                                        if let resizedImage = self.finalImageView.image?.resizeImageAspectFill(newSize: CGSize(500, 700)) {
                                            
                                            if let pictureData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                                                self.uploadImageEdit(key, pictureData, completionHandler: { (photoUrl, success) in
                                                    
                                                    if success {
                                                        if !photoUrl.isEmpty {
                                                            dict["tips/\(key)/tipImageUrl"] = photoUrl
                                                            dict["userTips/\(userId)/\(key)/tipImageUrl"] = photoUrl
                                                            if !updateCategory {
                                                                dict["categories/\(category)/\(key)/tipImageUrl"] = photoUrl
                                                            }
                                                            completionHandler(dict, updateCategory, true)
                                                        }
                                                    }
                                                    else {
                                                        completionHandler(dict, updateCategory, false)
                                                    }
                                                })
                                            }
                                        }
                                        
                                        
                                    }
                                    else {
                                        ProgressOverlay.updateProgress(receivedSize: 100, totalSize: 100, percentageComplete: 100.0)
                                        completionHandler(dict, updateCategory, true)
                                    }
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                })
                
            }
            
        }
        
        
        
    }
    
    
    func createUpdateDict() -> [String: Bool] {
        
        var updateDict = [String : Bool]()
        
        if let categoryDidChange = self.tipEdit?.categoryDidChange {
            
            updateDict["updateCategory"] = categoryDidChange
            
            if let descriptionDidChange = self.tipEdit?.descriptionDidChange {
                
                updateDict["updateDescription"] = descriptionDidChange
                
                if let locationDidChange = self.tipEdit?.locationDidChange {
                    
                    updateDict["updateLocation"] = locationDidChange
                    
                    if let imageDidChange = self.tipEdit?.imageChanged {
                        
                        updateDict["updateImage"] = imageDidChange
                        
                    }
                    
                }
            }
            
        }
        return updateDict
    }
    
    
    func setTipCategory(_ key: String) {
        
        self.dataService.TIP_REF.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
                
                if let category = dictionary["category"] as? String {
                    let tip = Tip(snapshot: snapshot)
                    self.dataService.CATEGORY_REF.child(category).child(key).setValue(tip.toAnyObject(), withCompletionBlock: { (error, ref) in
                        
                        if error == nil {
                            print("Tip in category set...")
                        }
                        
                    })
                }
            }
            
        })
    }
    
    
    func uploadImageEdit(_ key: String, _ data: Data, completionHandler: @escaping ((_ url: String, _ success: Bool) -> Void)) {
        
        //Create Path for the tip Image
        let imagePath = "\(key)/tipImage.jpg"
        
        // Create image Reference
        let imageRef = self.dataService.STORAGE_TIP_IMAGE_REF.child(imagePath)
        
        // Create Metadata for the image
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let uploadTask = imageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
            if error == nil {
                
                if let photoUrl = metaData?.downloadURL()?.absoluteString {
                    completionHandler(photoUrl, true)
                }
        
            }
            else {
                self.showUploadFailed()
            }
            
        }
        uploadTask.observe(.progress) { snapshot in
            print(snapshot.progress!) // NSProgress object
            
            let percentageComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            
            
            ProgressOverlay.updateProgress(receivedSize: snapshot.progress!.completedUnitCount, totalSize: snapshot.progress!.totalUnitCount, percentageComplete: percentageComplete)
            
        }
        
        uploadTask.observe(.success) { snapshot in
        }
        
    }
    
    
     private func showUploadSuccess() {
         ProgressOverlay.hide()
       delayWithSeconds(2) { 
         NotificationCenter.default.post(name: Notification.Name(rawValue: "tipsUpdated"), object: nil)
        }
     }
    
    
    private func showUploadFailed() {
        DispatchQueue.main.async {
             ProgressOverlay.hide()
            //   self.configureSaveTipButton()
            let alertController = UIAlertController()
            alertController.defaultAlert(Constants.Notifications.UploadFailedAlertTitle, Constants.Notifications.UploadFailedMessage)
        }
    }
    
    private func showEditSuccess() {
        let message = Constants.Notifications.TipEditedMessage
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { action in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "tipsUpdated"), object: nil)
            self.dismiss(animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 1
        }
        
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
        
    }
    
    private func showEditFailed() {
        let alertController = UIAlertController()
        alertController.defaultAlert(Constants.Notifications.UploadFailedAlertTitle, Constants.Notifications.EditFailedMessage)
    }
    
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
    private func resetFields() {
        
        self.autocompleteTextfield.text = nil
        self.tipField.text = nil
        self.finalImageView!.image = nil
        self.cancelImageIcon.isHidden = true
        self.collectionView.isHidden = false
        self.saveTipButton.isEnabled = false
        self.finalImageView.isHidden = true
        self.finalImageViewContainer.isHidden = true
        self.characterCountLabel.text = "\(Constants.Counter.CharacterLimit)"
        self.selectionList.setSelectedButtonIndex(0, animated: false)
        self.selectedCategory = Constants.HomeView.DefaultCategory
        self.characterCountLabel.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        self.configureSaveTipButton()
        if isEditMode {
            self.tipEdit = nil
            self.postButton.setTitle("Post", for: .normal)
            self.isEditMode = false
        }
        
    }
    
    // MARK: TextViewDelegates
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        checkRemainingChars()
        if (textView.text.isEmpty) {
            self.configureSaveTipButton()
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if isEditMode {
            self.tipEdit?.descriptionEdited = textView.text
            checkValidTipEdit()
        }
        else {
            checkValidTip()
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = (textView.text!.utf16.count) + (text.utf16.count) - range.length
        
        if(newLength <= Constants.Counter.CharacterLimit) {
            
            self.characterCountLabel.text = "\(Constants.Counter.CharacterLimit - newLength)"
            
            if (text == "\n") {
                self.characterCountLabel.text = "\(Constants.Counter.CharacterLimit - newLength + 1)"
                textView.resignFirstResponder()
            }
            
            return true
        } else {
            
            if (text == "\n") {
                textView.resignFirstResponder()
            }
            return false
        }
    }
    
    
    
    
    // MARK: TextFieldDelegates
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveTipButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !isEditMode {
            checkValidTip()
        }
        else {
            
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.configureSaveTipButton()
        return true
    }
    
    
    func checkValidTip() {
        // Disable the Save button if the text field is empty.
        let text = tipField.text ?? ""
        let locationText = autocompleteTextfield.text ?? ""
        if (self.finalImageView.image != nil) {
            self.saveTipButton.isEnabled = !text.isEmpty && !locationText.isEmpty && self.finalImageView.image != nil && self.selectionList.selectedButtonIndex != -1
        }
        
        if (self.saveTipButton.isEnabled == true) {
            
            self.saveTipButton.backgroundColor = UIColor.primaryColor()
            self.saveTipButton.setTitleColor(UIColor.white, for: .normal)
            
        }
        
    }
    
    
    func checkValidTipEdit() {
        // Disable the Save button if the text field is empty.
        let text = tipField.text ?? ""
        let locationText = autocompleteTextfield.text ?? ""
        if let descriptionDidChange = self.tipEdit?.descriptionDidChange {
            if let categoryDidChange = self.tipEdit?.categoryDidChange {
                if let locationDidChange = self.tipEdit?.locationDidChange {
                    if let imageDidChange = self.tipEdit?.imageChanged {
                       
                        if (self.finalImageView.image != nil) {
                            self.saveTipButton.isEnabled = !text.isEmpty && !locationText.isEmpty && self.finalImageView.image != nil && self.selectionList.selectedButtonIndex != -1 && descriptionDidChange || categoryDidChange || locationDidChange || imageDidChange
                        }
                        
                        if self.saveTipButton.isEnabled {
                            
                            self.saveTipButton.backgroundColor = UIColor.primaryColor()
                            self.saveTipButton.setTitleColor(UIColor.white, for: .normal)
                            
                        }
                        else {
                            self.configureSaveTipButton()
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    private func configureProfileImage() {
        
        self.dataService.addProfilePicObserver { (url) in
            
            let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
                self.userProfileImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    
                    print("\(receivedSize)/\(totalSize)")
                    
                }, completionHandler: { (image, error, cacheType, imageUrl) in
                    
                    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                    self.userProfileImage.clipsToBounds = true
                    self.userProfileImage.contentMode = .scaleAspectFill
                })
        }
        
    }
    
    
    private func configureTextField() {
        
        autocompleteTextfield.autocorrectionType = .no
        autocompleteTextfield.autoCompleteCellHeight = 50.0
        autocompleteTextfield.maximumAutoCompleteCount = 4
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.backgroundColor = UIColor.smokeWhiteColor()
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.primaryTextColor()
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 17.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
    }
    
    
    private func handleTextFieldInterfaces() {
        autocompleteTextfield.onTextChange = { [weak self] text in
            if !text.isEmpty {
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(keyword: text)
            }
        }
        
        autocompleteTextfield.onTextEnd = { [weak self] text in
            if !text.isEmpty {
                self?.geoTask.geocodeAddress(text, withCompletionHandler: { (status, success) in
                    
                    if success {
                        //   if !self?.isEditMode {
                        if let coord = self?.geoTask.fetchedAddressCoordinates {
                            if let placeId = self?.geoTask.fetchedPlaceId {
                                
                                if let editMode = self?.isEditMode {
                                    
                                    if !editMode {
                                        self?.addPlaceCoordinates(coord, placeId)
                                    }
                                    else {
                                        self?.tipEdit?.placeIdChanged = placeId
                                        self?.checkValidTipEdit()
                                    }
                                }
                                
                            }
                        }
                    }
                    else {
                        self?.autocompleteTextfield.text = nil
                        let alert = UIAlertController()
                        alert.defaultAlert(nil, "Invalid address")
                    }
                })
            }
            
            
        }
        
        autocompleteTextfield.onSelect = { [weak self] text, placeId, indexpath in
            
            if !placeId.isEmpty {
                self?.geoTask.getCoordinatesFromPlaceId(placeId, completionHandler: { (coordinates, success, error) in
                    
                    if let err = error {
                    print(err.localizedDescription )
                    }
                    if success {
                        if let coord = coordinates {
                            
                            if let editMode = self?.isEditMode {
                                
                                if !editMode {
                                    self?.addPlaceCoordinates(coord, placeId)
                                }
                                else {
                                    self?.tipEdit?.placeIdChanged = placeId
                                }
                            }
                        }
                    }
                    else {
                        print("Could not get coordinates for this place...")
                    }
                })
            }
            else {
                
                self?.geoTask.geocodeAddress(text, withCompletionHandler: { (status, success) in
                    
                    if success {
                        
                        if let coordinates = self?.geoTask.fetchedAddressCoordinates {
                            self?.addPlaceCoordinates(coordinates, nil)
                        }
                        
                    }
                    else {
                        print(status)
                        
                        if status == "ZERO_RESULTS" {
                            print("The location could not be found...")
                        }
                        
                    }
                })
            }
        }
    }
    
    
    
    private func fetchAutocompletePlaces(keyword: String) {
        let urlString = "\(baseURLString)?key=\(autocompleteAPIKey)&input=\(keyword)"
        let s = NSMutableCharacterSet() //create an empty mutable set
        s.formUnion(with: NSCharacterSet.urlQueryAllowed)
        //    let s = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(url: url as URL)
                dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if let data = data {
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"] as AnyObject as? String {
                                if status == "OK" {
                                    if let predictions = result["predictions"] as AnyObject as? NSArray {
                                        var locations = [String]()
                                        var placeIds = [String]()
                                        for dict in predictions as! [NSDictionary] {
                                            locations.append(dict["description"] as! String)
                                            placeIds.append(dict["place_id"] as! String)
                                        }
                                        DispatchQueue.main.async(execute: {
                                            self.autocompleteTextfield.autoCompleteStrings = locations
                                            self.autocompleteTextfield.autoCompletePlaceIds = placeIds
                                        })
                                        
                                        return
                                    }
                                }
                                if status == "REQUEST_DENIED" {
                                    print("Request denied...")
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                self.autocompleteTextfield.autoCompleteStrings = nil
                                self.autocompleteTextfield.autoCompletePlaceIds = nil
                            })
                        }
                        catch let error as NSError {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }

    
    
    
    //MARK: Map Utilities
    
    func addPlaceCoordinates(_ coordinates: CLLocationCoordinate2D, _ placeId: String?) {
        selectedTipCoordinates = coordinates
        selectedPlaceId = placeId
    }
    
    
    //MARK: Private Methods
    
    func dismissKeyboard() {
        self.tipField.resignFirstResponder()
        self.autocompleteTextfield.resignFirstResponder()
    }
    
    // MARK: Actions
    
    
    @IBAction func capturePhoto(sender: UIButton) {
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    
    
    //MARK: UIImagePickerDelegate
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
        self.setupFinalImage(image: chosenImage)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func noCamera() {
        let alertController = UIAlertController()
        alertController.defaultAlert(Constants.Notifications.NoCameraTitle, Constants.Notifications.NoCameraMessage)
    }
    
    
    
    func checkRemainingChars() {
        
        let allowedChars = Constants.Counter.CharacterLimit
        
        let charsInTextView = -tipField.text!.characters.count
        
        let remainingChars = allowedChars + charsInTextView
        
        
        if remainingChars <= allowedChars {
            characterCountLabel.textColor = UIColor.lightGray
        }
        
        
        if remainingChars <= 20 {
            characterCountLabel.textColor = UIColor(red: 232/255, green: 158/255, blue: 48/255, alpha: 1)
        }
        
        if remainingChars <= 15 {
            characterCountLabel.textColor = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1)
        }
        
        if remainingChars <= 10 {
            characterCountLabel.textColor = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1)
        }
        
        if remainingChars <= 5 {
            characterCountLabel.textColor = UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1)
        }
        
        
        characterCountLabel.text = String(remainingChars)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if (self.layoutFinalImage == true) {
            self.setUpFinalImageEffects()
        }
    }
    
    func setupFinalImage(image: UIImage) {
        
        self.layoutFinalImage = true
        self.finalImageViewContainer.isHidden = false
        self.finalImageView.isHidden = false
        self.finalImageView.contentMode = .scaleAspectFill
        self.finalImageViewContainer.backgroundColor = UIColor.smokeWhiteColor()
        self.collectionView.isHidden = true
        self.finalImageView.clipsToBounds = true
        self.finalImageView.image = image
        self.view.addSubview(self.finalImageViewContainer)
        self.view.addSubview(self.finalImageView)
        self.cancelImageIcon = UIButton()
        self.cancelImageIcon.tag = 1
        let cancelImage = UIImage(named: "cross-icon-white")
        self.cancelImageIcon.setBackgroundImage(cancelImage, for: .normal)
        self.cancelImageIcon.addTarget(self, action: #selector(cancelImageIconTapped), for: .touchUpInside)
        self.view.addSubview(self.cancelImageIcon)
        self.finalImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.finalImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelImageIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let imageWidthConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .width, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width/3)
        
        
        
        let imageHeightConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.collectionView.frame.size.height - 4)
        
        
        let imageTopConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 4.0)
        
        
        let imageBottomConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
    
        let imageXConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let cancelImageWidthConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: .width, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 15)
        
        let cancelImageHeightConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: .height, relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 15)
        
        let cancelImageTrailingConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.finalImageView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -8.0)
        
        let cancelImageTopConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.finalImageView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 8.0)
        
        
        
        
        let containerWidthConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: .width, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let containerHeightConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.collectionView.frame.size.height)
        
        let containerBottomConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        
        
        self.view.addConstraints([imageWidthConstraint, imageTopConstraint, imageBottomConstraint, imageHeightConstraint, imageXConstraint, cancelImageWidthConstraint, cancelImageHeightConstraint, cancelImageTopConstraint, cancelImageTrailingConstraint, containerWidthConstraint, containerHeightConstraint, containerBottomConstraint])
        
        
        if !isEditMode {
            checkValidTip()
        }
        else {
            checkValidTipEdit()
        }
        
    }
    
    
    private func setUpFinalImageEffects() {
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.finalImageView.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        self.finalImageView.layer.insertSublayer(overlay, at: 0)
        self.layoutFinalImage = false
    }
    
    
    private func openPinMap() {
        self.pinMapViewController = PinMapViewController()
        self.pinMapViewController.delegate = self
        self.addChildViewController(self.pinMapViewController)
        self.pinMapViewController.view.frame = self.view.frame
        self.view.addSubview(self.pinMapViewController.view)
        self.pinMapViewController.didMove(toParentViewController: self)
    }
    
    
    func cancelImageIconTapped() {
        self.finalImageView.isHidden = true
        self.finalImageViewContainer.isHidden = true
        self.cancelImageIcon.isHidden = true
        self.collectionView.isHidden = false
        finalImageView.image = nil
        self.configureSaveTipButton()
    }
    
    
    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraReuseIdentifier, for: indexPath as IndexPath) as! CameraCell
        return cell
    }
    
    func photoCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath as IndexPath) as! PhotoThumbnail
        
        
        // Configure the cell
        cell.imageManager = imageManager
        cell.imageAsset = self.images?[indexPath.item - 1]
        return cell
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            
            if let changeDetails = changeInstance.changeDetails(for: self.images) {
                
                self.images = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadData()
            }
        }
    }
    
}




extension AddTipViewController: HTHorizontalSelectionListDelegate {
    
    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        
        // update the category for the corresponding index
        self.selectedCategory = Constants.HomeView.Categories[index]
        print("Category selected: " + Constants.HomeView.Categories[index])
        if isEditMode {
            self.tipEdit?.categoryEdited = Constants.HomeView.Categories[index]
            checkValidTipEdit()
        }
    }
    
}


extension AddTipViewController: HTHorizontalSelectionListDataSource {
    
    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return Constants.HomeView.Categories.count
    }
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return Constants.HomeView.Categories[index]
    }
    
}




extension AddTipViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            return self.cameraCellForIndexPath(indexPath: indexPath as NSIndexPath)
        }
        else {
            return self.photoCellForIndexPath(indexPath: indexPath as NSIndexPath)
        }
    }
    
    
}


extension AddTipViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                present(picker, animated: true, completion: nil)
            } else {
                noCamera()
            }
        }
        else {
            
            let storyboard = UIStoryboard(name: "Picker", bundle: Bundle.main)
            let showPreviewVC = { (image: UIImage!) -> Void in
                let previewVC = storyboard.instantiateViewController(withIdentifier: "ImagePickerPreviewVC") as! ImagePickerPreviewViewController
                previewVC.definesPresentationContext = true
                previewVC.modalPresentationStyle = .overCurrentContext
                previewVC.setImage(image: image)
                previewVC.delegate = self
                self.show(previewVC, sender: nil)
            }
            
            let width = self.view.bounds.width
            let height = self.view.bounds.height
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            let asset = self.images[indexPath.item - 1]
            
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width, height), contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                
                if let _image = image {
                    showPreviewVC(_image)
                }
                
            })
            
        }
        
    }
    
    
}


extension AddTipViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 2) / 3
        //    let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension AddTipViewController: PinLocationProtocol {
    
    func didSelectLocation(_ lat: CLLocationDegrees, _ long: CLLocationDegrees) {
        self.addPlaceCoordinates(CLLocationCoordinate2D(latitude: lat, longitude: long), nil)
        self.didAddCoordinates = true
        self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completionHandler: { (address, success) in
            
            if success {
                DispatchQueue.main.async {
                    self.autocompleteTextfield.text = address
                }
                if self.isEditMode {
                    self.tipEdit?.placeIdChanged = self.selectedPlaceId
                }
                
            }
            else {
                print("Could not get current location...")
            }
        })
    }
    
    
    func didClosePinMap(_ done: Bool) {
        self.didAddCoordinates = false
        if !done {
            self.autocompleteTextfield.text = nil
        }
        else {
            if isEditMode {
                self.checkValidTipEdit()
            }
        }
    }
    
}


extension AddTipViewController: ImagePickerPreviewDelegate {
    
    func imagePickerPreview(originalImage: UIImage?) {
        self.delegate?.imagePicker?(pickedImage: originalImage)
        self.dismiss(animated: true, completion: nil)
        self.setupFinalImage(image: originalImage!)
        
        if !isEditMode {
            checkValidTip()
        }
        else {
            self.tipEdit?.imageChanged = true
            checkValidTipEdit()
        }
        
    }
    
}
