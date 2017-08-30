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
import GoogleMaps
import Kingfisher
import Firebase
import SwiftLocation


protocol ImagePickerDelegate: class {
    func imagePicker(pickedImage image: UIImage?)
}



class AddTipViewController: UIViewController, NSURLConnectionDataDelegate, UINavigationControllerDelegate {
    
    
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
    var imageArray: [UIImage] = []
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
    var categories: [String] = []
    var selectionList: HTHorizontalSelectionList!
    var finalImageView: UIImageView!
    var finalImageViewContainer: UIView!
    var backgroundContainer: UIView!
    var cancelImageIcon: UIButton!
    var layoutFinalImage: Bool?
    weak var delegate: ImagePickerDelegate?
    let dataService = DataService()
    var loadingNotification = MBProgressHUD()
    var didFindLocation: Bool = false
    let geoTask = GeoTasks()
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager!
    var cacheController: PhotoLibraryCacheController!
    var didAddCoordinates: Bool = false
    var isEditMode: Bool = false
    var tipEdit: TipEdit?
    var catRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      initLayout()
      NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "editTip"),
                                             object: nil, queue: nil, using: catchNotification)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureProfileImage()
        if !isEditMode {
        selectionList.setSelectedButtonIndex(0, animated: false)
        selectedCategory = Constants.HomeView.DefaultCategory
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if pinMapViewController != nil && pinMapViewController.isViewLoaded {
            pinMapViewController.removeAnimate()
            autocompleteTextfield.text = nil
        }
        
        if isEditMode {
            resetFields()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
     //   dataService.removeCurrentUserObserver()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  private func initLayout() {
  
    categories = Constants.HomeView.Categories
    tipFieldHeightConstraint.constant = tipFieldHeightConstraintConstant()
    tipField.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
    tipField.textColor = UIColor.primaryText()
    catRef = self.dataService.CATEGORY_REF
    finalImageView = UIImageView()
    finalImageViewContainer = UIView()
    configureSaveTipButton()
    layoutFinalImage = false
    tipField.delegate = self
    autocompleteTextfield.delegate = self
    configureNavBar()
    picker.delegate = self
    configureTextField()
    handleTextFieldInterfaces()
    initCategoryList()
    initPhotoLibrary()
    
    
    guard let lat = Location.lastLocation.last?.coordinate.latitude, let lon = Location.lastLocation.last?.coordinate.longitude else {return}
    geoTask.getAddressFromCoordinates(latitude: lat, longitude: lon, completion: { (address, success) in
      
      if success {
        DispatchQueue.main.async {
          self.autocompleteTextfield.text = address
        }
      }
      else {
        print("Could not get address from current location...")
      }
    })
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
    
    characterCountLabel.text = "\(Constants.Counter.CharacterLimit)"
    characterCountLabel.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)

  }
  
  
  private func initCategoryList() {
  
    selectionList = HTHorizontalSelectionList()
    selectionList.delegate = self
    selectionList.dataSource = self
    selectionList.selectionIndicatorStyle = .bottomBar
    selectionList.selectionIndicatorColor = UIColor.primary()
    selectionList.setTitleColor(UIColor.primaryText(), for: .normal)
    selectionList.bottomTrimHidden = true
    selectionList.centerButtons = true
    selectionList.layer.borderWidth = 1
    selectionList.layer.borderColor = UIColor.smokeWhite().cgColor
    selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10)
    selectionView.addSubview(selectionList)
    selectionList.fillSuperview()
  }
  
  
  private func configureNavBar() {
    
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        navigationItem.titleView = navLogo
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    
  
    
    func tipFieldHeightConstraintConstant() -> CGFloat {
        switch(Utils.screenHeight()) {
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
  
  
    
    private func initPhotoLibrary() {
      
        collectionView.delegate = self
        collectionView.dataSource = self
      imageManager = PHCachingImageManager()
      fetchAssets()
      setBackgroundView()
    }
  
  
  
  private func setBackgroundView() {
  
    backgroundContainer = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
    let noAccessLabel = UILabel()
    let enableButton = UIButton(type: .custom)
    backgroundContainer.tag = 100
    backgroundContainer.backgroundColor = UIColor.white
    noAccessLabel.text = "Yaknak does not have access to your photos."
    noAccessLabel.font = UIFont.systemFont(ofSize: 13)
    noAccessLabel.textColor = UIColor.primaryText()
    noAccessLabel.textAlignment = .center
    noAccessLabel.numberOfLines = 2
    noAccessLabel.lineBreakMode = .byWordWrapping
    noAccessLabel.sizeToFit()
    backgroundContainer.addSubview(noAccessLabel)
    noAccessLabel.anchorCenterXToSuperview()
    noAccessLabel.anchorCenterYToSuperview(constant: -12)
    noAccessLabel.widthAnchor.constraint(equalToConstant: backgroundContainer.bounds.size.width - 32).isActive = true
    
    enableButton.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
    enableButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    enableButton.setTitle("Enable access", for: .normal)
    enableButton.setTitleColor(UIColor.primary(), for: .normal)
    enableButton.addTarget(self, action: #selector(redirectToSettings), for: .touchUpInside)
    backgroundContainer.addSubview(enableButton)
    enableButton.anchorCenterXToSuperview()
    enableButton.anchorCenterYToSuperview(constant: 12)
    enableButton.widthAnchor.constraint(equalToConstant: backgroundContainer.bounds.size.width - 32).isActive = true
  }
  
  private func fetchAssets() {
  
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [
      NSSortDescriptor(key: "creationDate", ascending: false) ]
    images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    cacheController = PhotoLibraryCacheController(imageManager: imageManager, images: self.images as! PHFetchResult<AnyObject>, preheatSize: 1)
    PHPhotoLibrary.shared().register(self)

  }
  
    func catchNotification(notification: Notification) -> Void {
        guard let tip = notification.userInfo!["tip"] else {
            return
        }
        self.prefillTipDetails(tip as! Tip)
    }
  
  
  func checkCameraPermission() {
    
    let permission = YaknakCamera()
    permission.status { (status) in
      
      switch status {
        
      case .authorized:
        self.showCameraPicker()
        break
      case .denied:
        self.setupCameraPermission()
        break
      case .notAvailable:
        
        break
      case .notDetermined:
        self.setupCameraPermission()
        break
        
      }
    }
  }
  
  
   func setupCameraPermission() {
    
    let config = YaknakConfiguration(frequency: .JustOnce, presentInitialPopup: false, presentReEnablePopup: true)
    let initialData = YaknakPopupData(title: "a title", message: "a message", image: "", allowButtonTitle: "Allow", denyButtonTitle: "Deny", type: .native)
    let reEnableData = YaknakPopupData(title: "Enable camera", message: "Let Yaknak access your camera to capture a cool photo.", image: "", allowButtonTitle: "Allow", denyButtonTitle: "Deny", type: .native)
    
    let p = YaknakCamera(configuration: config, initialPopupData: initialData, reEnablePopupData: reEnableData)
    
    p.manage { (status) in
      
      switch status {
      
      case .authorized:
        self.showCameraPicker()
        break
      case .denied:
        
        break
      case .notAvailable:
    
        break
      case .notDetermined:
        
        break
      }
    }
  }
  
  
    func configureSaveTipButton() {
        self.saveTipButton.backgroundColor = UIColor.smokeWhite()
        self.saveTipButton.setTitleColor(UIColor.secondaryText(), for: .normal)
        self.saveTipButton.layer.cornerRadius = 5
        self.saveTipButton.isEnabled = false
    }
  
  
  func reloadPhotos() {
    
    UIView.animate(withDuration: 0.0, animations: { [weak self] in
      guard let strongSelf = self else { return }
      
      DispatchQueue.main.async {
        strongSelf.collectionView.reloadData()
      }
      
      }, completion: { [weak self] (finished) in
        guard let strongSelf = self else { return }
        for subView in strongSelf.collectionView.subviews {
          if (subView.tag == 100) {
            subView.removeFromSuperview()
          }
        }
    })
  }
  
  
  
  func redirectToSettings() {
  Utils.redirectToSettings()
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
        
        isEditMode = true
        
        
        postButton.setTitle("Done", for: .normal)
        if !tip.description.isEmpty {
            tipField.text = tip.description
            checkRemainingChars()
        }
        
        tipEdit = tip.toEdit()
        
        if !tip.category.isEmpty {
          guard let category = tip.category else {return}
          
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
      
              guard let tipPicUrl = tip.tipImageUrl, let url = URL(string: tipPicUrl) else {return}
                
                finalImageView.kf.indicatorType = .activity
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 100), mode: .aspectFill)
                finalImageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    print("Progress: \(receivedSize)/\(totalSize)")
                    
                }, completionHandler: { (image, error, cacheType, imageUrl) in
                    
                    
                    if let placeId = tip.placeId {
                        if !placeId.isEmpty {
                            self.geoTask.getAddressFromPlaceId(placeId, completionHandler: { (address, success, error) in
                                
                                if let error = error {
                                    print("lookup place id query error: \(error.localizedDescription)")
                                }
                                
                                if success {
                                    DispatchQueue.main.async {
                                        self.autocompleteTextfield.text = address
                                    }
                                }
                                
                            })
                        }
                        else {
                            
                          guard let key = tip.key else {return}
                            self.dataService.getTipLocation(key, completion: { (location, error) in
                        
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                else {
                                    guard let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude else {return}
                                      
                                      self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: lon, completion: { (address, success) in
                                        
                                        if success {
                                          self.tipEdit?.placeId = self.selectedPlaceId
                                          DispatchQueue.main.async {
                                            self.autocompleteTextfield.text = address
                                          }
                                        }
                                      })
                                }
                              
                            })
                        
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
    
    
    
    private func uploadTip(tipPic: Data) {
        
        ProgressOverlay.show("0%")
        
        self.dataService.getCurrentUser { (user) in
        
          guard let uid = user.key, let name = user.name, let url = user.photoUrl, let coordinates = self.selectedTipCoordinates, let description = self.tipField.text, let category = self.selectedCategory?.lowercased() else {
            print("Tip could not be uploaded...Something went wrong...")
            self.showUploadFailed()
            return
          }
          
                        let tipRef = self.dataService.TIP_REF.childByAutoId()
                        let key = tipRef.key
                                
                                self.upload(key, tipPic, tipRef, uid, name, url, description, category) { (success) in
                                    
                                    if success {
                                      
                                      self.dataService.incrementTotalTips(uid, completion: { (success, error) in
                                        
                                        if let error = error {
                                          print(error.localizedDescription)
                                        self.showUploadFailed()
                                        }
                                        else {
                                          self.dataService.setTipLocation(coordinates.latitude, coordinates.longitude, key)
                                          
                                          print("Tip succesfully stored in database...")
                                          #if DEBUG
                                            // do nothing
                                          #else
                                            Analytics.logEvent("tipAdded", parameters: ["tipId" : key as NSObject, "category" : category as NSObject, "addedByUser" : name as NSObject])
                                          #endif

                                        }
                                      })
                                    
                                    }
                                    else {
                                        self.showUploadFailed()
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
                
              guard let photoUrl = metaData?.downloadURL()?.absoluteString, let id = self.selectedPlaceId else {return}
                  var placeId = String()
                        if id.isEmpty {
                            placeId = ""
                        }
                        else {
                            placeId = id
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
                                  
                                  #if DEBUG
                                    // do nothing
                                  #else
                                     Analytics.logEvent("tipEdited", parameters: ["tipId" : key as NSObject])
                                  #endif
                                  
                                    
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
                                                
                                                if let error = error {
                                                 print("lookup place id query error: \(error.localizedDescription)")
                                                }
                                                if success {
                                                  
                                                  guard let lat = coordinates?.latitude, let lon = coordinates?.longitude else {return}
                                                                self.dataService.setTipLocation(lat, lon, key)
                                                                                                       }
                                                else {
                                                    print("Could not get coordinates for this place...")
                                                }
                                            })
                                        }
                                    }
                                    
                                }
                                
                              guard let updateImage = updateDict["updateImage"] else {return}
                              
                                    if updateImage {
                                        
                                      guard let resizedImage = self.finalImageView.image?.resizeImageAspectFill(newSize: CGSize(500, 700)), let pictureData = UIImageJPEGRepresentation(resizedImage, 1.0) else {return}
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
                                    else {
                                        ProgressOverlay.updateProgress(receivedSize: 100, totalSize: 100, percentageComplete: 100.0)
                                        completionHandler(dict, updateCategory, true)
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
          
          if let progress = snapshot.progress {
            print(progress) // NSProgress object
            
            let percentageComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            
            
            ProgressOverlay.updateProgress(receivedSize: progress.completedUnitCount, totalSize: progress.totalUnitCount, percentageComplete: percentageComplete)
          }
          
        }
        
        uploadTask.observe(.success) { snapshot in
        }
        
    }
  
  
  
     private func showUploadSuccess() {
         ProgressOverlay.hide()
      let alertController = UIAlertController()
      alertController.tipAddedAlert(nil, Constants.Notifications.TipUploadedMessage) { [weak self] _ in
        
        guard let strongSelf = self, let tabC = strongSelf.tabBarController as? TabBarController else {return}
        tabC.selectedIndex = 1
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
            NSForegroundColorAttributeName : UIColor.primaryText()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { action in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadProfile"), object: nil)
            self.dismiss(animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 1
        }
        
        defaultAction.setValue(UIColor.primary(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        alertController.show()
        
    }
    
    private func showEditFailed() {
        let alertController = UIAlertController()
        alertController.defaultAlert(Constants.Notifications.UploadFailedAlertTitle, Constants.Notifications.EditFailedMessage)
    }
    
    
    
    private func resetFields() {
        
        autocompleteTextfield.text = nil
        tipField.text = nil
        finalImageView!.image = nil
        cancelImageIcon.isHidden = true
        collectionView.isHidden = false
        saveTipButton.isEnabled = false
        finalImageView.isHidden = true
        finalImageViewContainer.isHidden = true
        characterCountLabel.text = "\(Constants.Counter.CharacterLimit)"
        selectionList.setSelectedButtonIndex(0, animated: false)
        selectedCategory = Constants.HomeView.DefaultCategory
        characterCountLabel.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        configureSaveTipButton()
        if isEditMode {
            tipEdit = nil
            postButton.setTitle("Post", for: .normal)
            isEditMode = false
        }
        
    }
  
  
    
    
    func checkValidTip() {
        // Disable the Save button if the text field is empty.
        let text = tipField.text ?? ""
        let locationText = autocompleteTextfield.text ?? ""
        if (self.finalImageView.image != nil) {
            self.saveTipButton.isEnabled = !text.isEmpty && !locationText.isEmpty && self.finalImageView.image != nil && self.selectionList.selectedButtonIndex != -1
        }
        
        if (self.saveTipButton.isEnabled == true) {
            
            self.saveTipButton.backgroundColor = UIColor.primary()
            self.saveTipButton.setTitleColor(UIColor.white, for: .normal)
            
        }
        
    }
    
    
    func checkValidTipEdit() {
        // Disable the Save button if the text field is empty.
        let text = tipField.text ?? ""
        let locationText = autocompleteTextfield.text ?? ""
      
      guard let descriptionDidChange = tipEdit?.descriptionDidChange, let categoryDidChange = tipEdit?.categoryDidChange, let locationDidChange = tipEdit?.locationDidChange, let imageDidChange = tipEdit?.imageChanged else {return}
                       
                        if finalImageView.image != nil {
                            saveTipButton.isEnabled = !text.isEmpty && !locationText.isEmpty && finalImageView.image != nil && selectionList.selectedButtonIndex != -1 && descriptionDidChange || categoryDidChange || locationDidChange || imageDidChange
                        }
                        
                        if saveTipButton.isEnabled {
                            
                            saveTipButton.backgroundColor = UIColor.primary()
                            saveTipButton.setTitleColor(UIColor.white, for: .normal)
                            
                        }
                        else {
                            configureSaveTipButton()
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
        autocompleteTextfield.backgroundColor = UIColor.smokeWhite()
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.primaryText()
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 17.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
    }
    
    
    private func handleTextFieldInterfaces() {
        autocompleteTextfield.onTextChange = { [weak self] text in
          
          guard let strongSelf = self else {
            return
          }
            if !text.isEmpty {
                if let dataTask = strongSelf.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(keyword: text)
            }
        }
        
        autocompleteTextfield.onTextEnd = { [weak self] text in
          
          guard let strongSelf = self else {
            return
          }
          
            if !text.isEmpty {
                strongSelf.geoTask.geocodeAddress(text, withCompletionHandler: { (status, success) in
                    
                    if success {
                        //   if !self?.isEditMode {
                        if let coord = strongSelf.geoTask.fetchedAddressCoordinates {
                            if let placeId = strongSelf.geoTask.fetchedPlaceId {
                              
                                    if !strongSelf.isEditMode {
                                        strongSelf.addPlaceCoordinates(coord, placeId)
                                    }
                                    else {
                                        strongSelf.tipEdit?.placeIdChanged = placeId
                                        strongSelf.checkValidTipEdit()
                                    }
                                
                                
                            }
                        }
                    }
                    else {
                        strongSelf.autocompleteTextfield.text = nil
                        let alert = UIAlertController()
                        alert.defaultAlert(nil, "Invalid address")
                    }
                })
            }
            
            
        }
        
        autocompleteTextfield.onSelect = { [weak self] text, placeId, indexpath in
          
          guard let strongSelf = self else {
            return
          }
            
            if !placeId.isEmpty {
                strongSelf.geoTask.getCoordinatesFromPlaceId(placeId, completionHandler: { (coordinates, success, error) in
                    
                    if let err = error {
                    print(err.localizedDescription )
                    }
                    if success {
                        if let coord = coordinates {
                          
                                if !strongSelf.isEditMode {
                                    strongSelf.addPlaceCoordinates(coord, placeId)
                                }
                                else {
                                    strongSelf.tipEdit?.placeIdChanged = placeId
                                }
                        }
                    }
                    else {
                        print("Could not get coordinates for this place...")
                    }
                })
            }
            else {
                
                strongSelf.geoTask.geocodeAddress(text, withCompletionHandler: { (status, success) in
                    
                    if success {
                        
                        if let coordinates = strongSelf.geoTask.fetchedAddressCoordinates {
                            strongSelf.addPlaceCoordinates(coordinates, nil)
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
                                      var locations: [String] = []
                                      var placeIds: [String] = []
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
        if layoutFinalImage == true {
            setUpFinalImageEffects()
        }
    }
    
    func setupFinalImage(image: UIImage) {
        
        layoutFinalImage = true
        finalImageViewContainer.isHidden = false
        finalImageView.isHidden = false
        finalImageView.contentMode = .scaleAspectFill
        finalImageViewContainer.backgroundColor = UIColor.smokeWhite()
        collectionView.isHidden = true
        finalImageView.clipsToBounds = true
        finalImageView.image = image
        view.addSubview(self.finalImageViewContainer)
        view.addSubview(self.finalImageView)
        cancelImageIcon = UIButton()
        cancelImageIcon.tag = 1
        let cancelImage = UIImage(named: "cross-icon-white")
        cancelImageIcon.setBackgroundImage(cancelImage, for: .normal)
        cancelImageIcon.addTarget(self, action: #selector(cancelImageIconTapped), for: .touchUpInside)
        view.addSubview(self.cancelImageIcon)
        finalImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        finalImageView.translatesAutoresizingMaskIntoConstraints = false
        cancelImageIcon.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        
        
        view.addConstraints([imageWidthConstraint, imageTopConstraint, imageBottomConstraint, imageHeightConstraint, imageXConstraint, cancelImageWidthConstraint, cancelImageHeightConstraint, cancelImageTopConstraint, cancelImageTrailingConstraint, containerWidthConstraint, containerHeightConstraint, containerBottomConstraint])
        
        
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
        finalImageView.layer.insertSublayer(overlay, at: 0)
        layoutFinalImage = false
    }
    
    
    private func openPinMap() {
        pinMapViewController = PinMapViewController()
        pinMapViewController.delegate = self
        addChildViewController(self.pinMapViewController)
        pinMapViewController.view.frame = self.view.frame
        view.addSubview(self.pinMapViewController.view)
        pinMapViewController.didMove(toParentViewController: self)
    }
  
  
  func showCameraPicker() {
    picker.allowsEditing = false
    picker.sourceType = UIImagePickerControllerSourceType.camera
    picker.cameraCaptureMode = .photo
    present(self.picker, animated: true, completion: nil)
  }
  
  
    func cancelImageIconTapped() {
        finalImageView.isHidden = true
        finalImageViewContainer.isHidden = true
        cancelImageIcon.isHidden = true
        collectionView.isHidden = false
        finalImageView.image = nil
        configureSaveTipButton()
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
    
    
  
    
}



extension AddTipViewController: PHPhotoLibraryChangeObserver {

  func photoLibraryDidChange(_ changeInstance: PHChange) {
    
    guard let changeDetails = changeInstance.changeDetails(for: self.images) else {return}
        
        self.images = changeDetails.fetchResultAfterChanges
        self.reloadPhotos()
  }
}


extension AddTipViewController: HTHorizontalSelectionListDelegate {
  
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
      
      var photoCount = Int()
      let permission = YaknakPhoto()
      permission.status { (status) in
        
        switch status {
          
        case .authorized:
          collectionView.backgroundView = nil
          print("Photo permission received...")
          photoCount = self.images.count + 1
          break
        case .denied:
          photoCount = 0
          collectionView.backgroundView = self.backgroundContainer
          break
          
        case .notAvailable:
          photoCount = 0
          collectionView.backgroundView = self.backgroundContainer
          break
          
        case .notDetermined:
          photoCount = 0
          collectionView.backgroundView = self.backgroundContainer
          break
          
        }
      }
         return photoCount
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
              self.checkCameraPermission()
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
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}



extension AddTipViewController: UITextViewDelegate {

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

}


extension AddTipViewController: UITextFieldDelegate {

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
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.configureSaveTipButton()
    return true
  }
}

extension AddTipViewController: PinLocationDelegate {
  
    func didSelectLocation(_ lat: CLLocationDegrees, _ long: CLLocationDegrees) {
        self.addPlaceCoordinates(CLLocationCoordinate2D(latitude: lat, longitude: long), nil)
        self.didAddCoordinates = true
        self.geoTask.getAddressFromCoordinates(latitude: lat, longitude: long, completion: { (address, success) in
            
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
    
    
    func didClosePinMap(withDone done: Bool) {
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


extension AddTipViewController: UIImagePickerControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
    let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    dismiss(animated: true, completion: nil)
    self.setupFinalImage(image: chosenImage)
    
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

}


extension AddTipViewController: ImagePickerPreviewDelegate {
    
    func imagePickerPreview(originalImage: UIImage?) {
        self.delegate?.imagePicker(pickedImage: originalImage)
        self.dismiss(animated: true, completion: nil)
      guard let image = originalImage else {return}
        self.setupFinalImage(image: image)
        
        if !isEditMode {
            checkValidTip()
        }
        else {
            self.tipEdit?.imageChanged = true
            checkValidTipEdit()
        }
        
    }
    
}
