//
//  SingleTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GeoFire
import GoogleMaps
import GooglePlaces
import CoreLocation
//import PXGoogleDirections


class SingleTipViewController: UIViewController {
    
    
    var tip: Tip!
    let dataService = DataService()
    var style = NSMutableParagraphStyle()
    var mapTasks = MapTasks()
    var tipImage: UIImage!
    var img: UIImageView!
    var ai = UIActivityIndicatorView()
    var travelMode = TravelMode.Modes.walking
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        
        //     self.preheater = Preheater()
        //    directionsAPI.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.style.lineSpacing = 2
        /*
         //   User enters the screen:
         if (self.urlRequest != nil) {
         preheater.startPreheating(with: [self.urlRequest])
         }
         
         if tipImage != nil {
         print("")
         }
         */
        
        
    }
    
    
    
    @IBAction func cancelContainerTapped(_ sender: UITapGestureRecognizer) {
        self.removeAnimate()
    }
    
    
    @IBAction func reportContainerTapped(_ sender: UITapGestureRecognizer) {
        self.popUpReportPrompt()
    }
    
    
    private func initTipView() {
        
        if let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView {
            
            self.ai = UIActivityIndicatorView(frame: singleTipView.frame)
            singleTipView.addSubview(ai)
            self.ai.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.gray
            self.ai.center = CGPoint(UIScreen.main.bounds.width / 2, UIScreen.main.bounds.height / 2)
            self.ai.startAnimating()
            singleTipView.layoutIfNeeded()
            
            if let img = self.tipImage {
                
                singleTipView.tipImage.isHidden = true
                singleTipView.likes.isHidden = true
                singleTipView.likeLabel.isHidden = true
                singleTipView.likeIcon.isHidden = true
                singleTipView.tipDescription.isHidden = true
                singleTipView.walkingIcon.isHidden = true
                singleTipView.reportContainer.isHidden = true
                singleTipView.cancelContainer.isHidden = true
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    if appDelegate.isReachable {
                        self.getLocationDetails(singleTipView, completionHandler: { (success, showDistance) in
                            
                            if success {
                                
                                singleTipView.tipImage.image = img
                                singleTipView.reportContainer.makeCircle()
                                singleTipView.cancelContainer.makeCircle()
                                
                                if let likes = self.tip.likes {
                                    singleTipView.likes.text = "\(likes)"
                                    
                                    if likes == 1 {
                                        singleTipView.likeLabel.text = "Like"
                                    }
                                    else {
                                        singleTipView.likeLabel.text = "Likes"
                                    }
                                }
                                
                                if let desc = self.tip.description {
                                    
                                    let attributes = [NSParagraphStyleAttributeName : self.style]
                                    singleTipView.tipDescription?.attributedText = NSAttributedString(string: desc, attributes: attributes)
                                    singleTipView.tipDescription.textColor = UIColor.primaryTextColor()
                                    singleTipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                    singleTipView.tipDescription.textContainer.lineFragmentPadding = 0
                                    
                                }
                                
                                
                                if showDistance {
                                    self.showUI(singleTipView)
                                }
                                else {
                                    self.hideDistance(singleTipView)
                                }
                                
                            }
                            
                            
                        })
                    }
                }
                
            }
            
        }
    }
    
    
    private func getLocationDetails(_ view: SingleTipView, completionHandler: @escaping ((_ success: Bool, _ showDistance: Bool) -> Void)) {
        
        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        geo?.getLocationForKey(tip.key, withCallback: { (location, error) in
            
            if error == nil {
                
                if let lat = location?.coordinate.latitude {
                    
                    if let long = location?.coordinate.longitude {
                        
                        let latitudeText: String = "\(lat)"
                        let longitudeText: String = "\(long)"
                        
                        self.getAddressForLatLng(latitude: latitudeText, longitude: longitudeText, completionHandler: { (placeName, success) in
                            
                            if success {
                                view.placeName.text = placeName
                                
                                self.mapTasks.getDirections(latitudeText, originLong: longitudeText, destinationLat: LocationService.sharedInstance.currentLocation?.coordinate.latitude, destinationLong: LocationService.sharedInstance.currentLocation?.coordinate.longitude, travelMode: self.travelMode, completionHandler: { (status, success) in
                                    
                                    if success {
                                        
                                        let minutes = self.mapTasks.totalDurationInSeconds / 60
                                        if (minutes <= 60) {
                                            view.walkingDistance.text = "\(minutes)"
                                            
                                            if minutes == 1 {
                                                view.walkingLabel.text = "Min"
                                            }
                                            else {
                                                view.walkingLabel.text = "Mins"
                                            }
                                        }
                                        else {
                                            completionHandler(true, false)
                                        }
                                        completionHandler(true, true)
                                        
                                        print("The total distance is: " + "\(self.mapTasks.totalDistanceInMeters)")
                                        
                                        
                                    }
                                    else {
                                        completionHandler(true, false)
                                    }
                                    
                                })
                                
                                
                                
                                
                                
                                
                            }
                            
                        })
                        
                    }
                    
                }
                
                
            }
            else {
                
                print(error?.localizedDescription)
            }
            
            
        })
    }
    
    private func showUI(_ view: SingleTipView) {
        view.tipImage.isHidden = false
        view.likes.isHidden = false
        view.likeLabel.isHidden = false
        view.likeIcon.isHidden = false
        view.tipDescription.isHidden = false
        view.walkingIcon.isHidden = false
        view.reportContainer.isHidden = false
        view.cancelContainer.isHidden = false
        view.tipImageHeightConstraint.setMultiplier(multiplier: self.tipImageHeightConstraintMultiplier())
        view.tipImage.contentMode = .scaleAspectFill
        view.tipImage.clipsToBounds = true
        self.ai.stopAnimating()
        self.ai.removeFromSuperview()
    }
    
    
    private func hideDistance(_ view: SingleTipView) {
        view.likeIconLeadingConstraint.constant = 20.0
        view.walkingIcon.removeFromSuperview()
        view.walkingLabel.removeFromSuperview()
        view.walkingDistance.removeFromSuperview()
        self.showUI(view)
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.0, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.initTipView()
        })
    }
    
    func removeAnimate() {
        
        
        UIView.animate(withDuration: 0.15, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }
    
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        self.popUpReportPrompt()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
    
    private func popUpReportPrompt() {
        
        let title = Constants.Notifications.ReportMessage
        //   let message = Constants.Notifications.ShareMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let okButtonTitle = Constants.Notifications.ReportTip
        //     let shareTitle = Constants.Notifications.ShareOk
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        //     let shareButton = UIAlertAction(title: shareTitle, style: .Default) { (Action) in
        //         self.showSharePopUp(self.currentTip)
        //     }
        
        let reportButton = UIAlertAction(title: okButtonTitle, style: .default) { (Action) in
            self.showReportVC(tipId: self.tip.key!)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (Action) in
            //  alertController.d
        }
        
        //     alertController.addAction(shareButton)
        alertController.addAction(reportButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
    func tipImageHeightConstraintMultiplier() -> CGFloat {
        switch self.screenHeight() {
        case 568:
            return 0.68
            
        case 667:
            return 0.73
            
        case 736:
            return 0.75
            
        default:
            return 0.73
        }
    }
    
    
    
    
    
    private func showReportVC(tipId: String) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tipId
        self.show(previewVC, sender: nil)
        
        //    self.showViewController(previewVC, sender: nil)
        
    }
    
    
    func getAddressForLatLng(latitude: String, longitude: String, completionHandler: @escaping ((_ tipPlace: String, _ success: Bool) -> Void)) {
        let url = URL(string: "\(Constants.Config.GeoCodeString)latlng=\(latitude),\(longitude)")
        
        let request: URLRequest = URLRequest(url:url!)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if(error != nil) {
                
                print(error?.localizedDescription)
                completionHandler("", false)
                
            } else {
                
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                //let dataAsString: NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                
                let jsonResult: NSDictionary = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                
                var status = jsonResult.value(forKey: kStatus) as! NSString
                status = status.lowercased as NSString
                
                if(status.isEqual(to: kOK)) {
                    
                    let address = AddressParser()
                    
                    address.parseGoogleLocationData(jsonResult)
                    
                    let addressDict = address.getAddressDictionary()
                    //     let placemark:CLPlacemark = address.getPlacemark()
                    
                    
                    
                    if let placeId = addressDict["placeId"] as? String {
                        
                        DispatchQueue.main.async {
                            
                            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, err) -> Void in
                                if let error = error {
                                    print("lookup place id query error: \(error.localizedDescription)")
                                    return
                                }
                                
                                if let place = place {
                                    
                                    
                                    if !place.name.isEmpty {
                                        print(place.name)
                                        completionHandler(place.name, true)
                                    }
                                    else {
                                        if let address = addressDict["formattedAddess"] as? String {
                                            completionHandler(address, true)
                                        }
                                    }
                                    
                                    
                                } else {
                                    print("No place details for \(placeId)")
                                    if let address = addressDict["formattedAddess"] as? String {
                                        completionHandler(address, true)
                                    }
                                }
                            })
                            
                        }
                    }
                    
                }
                else if(!status.isEqual(to: kZeroResults) && !status.isEqual(to: kAPILimit) && !status.isEqual(to: kRequestDenied) && !status.isEqual(to: kInvalidRequest)){
                    
                    completionHandler("", false)
                    
                }
                    
                else {
                    
                    //status = (status.componentsSeparatedByString("_") as NSArray).componentsJoinedByString(" ").capitalizedString
                    
                    completionHandler("", false)
                    
                }
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    
    
    private class AddressParser: NSObject {
        
        fileprivate var latitude = NSString()
        fileprivate var longitude  = NSString()
        fileprivate var streetNumber = NSString()
        fileprivate var route = NSString()
        fileprivate var locality = NSString()
        fileprivate var subLocality = NSString()
        fileprivate var formattedAddress = NSString()
        fileprivate var administrativeArea = NSString()
        fileprivate var administrativeAreaCode = NSString()
        fileprivate var subAdministrativeArea = NSString()
        fileprivate var postalCode = NSString()
        fileprivate var country = NSString()
        fileprivate var subThoroughfare = NSString()
        fileprivate var thoroughfare = NSString()
        fileprivate var ISOcountryCode = NSString()
        fileprivate var state = NSString()
        fileprivate var placeId = NSString()
        
        
        override init(){
            
            super.init()
            
        }
        
        fileprivate func getAddressDictionary()-> NSDictionary {
            
            let addressDict = NSMutableDictionary()
            
            addressDict.setValue(latitude, forKey: "latitude")
            addressDict.setValue(longitude, forKey: "longitude")
            addressDict.setValue(streetNumber, forKey: "streetNumber")
            addressDict.setValue(locality, forKey: "locality")
            addressDict.setValue(subLocality, forKey: "subLocality")
            addressDict.setValue(administrativeArea, forKey: "administrativeArea")
            addressDict.setValue(postalCode, forKey: "postalCode")
            addressDict.setValue(country, forKey: "country")
            addressDict.setValue(formattedAddress, forKey: "formattedAddress")
            addressDict.setValue(placeId, forKey: "placeId")
            
            return addressDict
        }
        
        
        
        
        fileprivate func parseGoogleLocationData(_ resultDict:NSDictionary) {
            
            let locationDict = (resultDict.value(forKey: "results") as! NSArray).firstObject as! NSDictionary
            
            let formattedAddrs = locationDict.object(forKey: "formatted_address") as! NSString
            
            let geometry = locationDict.object(forKey: "geometry") as! NSDictionary
            let location = geometry.object(forKey: "location") as! NSDictionary
            let lat = location.object(forKey: "lat") as! Double
            let lng = location.object(forKey: "lng") as! Double
            let placeId = locationDict.object(forKey: "place_id") as! NSString
            
            self.latitude = lat.description as NSString
            self.longitude = lng.description as NSString
            self.placeId = placeId
            
            let addressComponents = locationDict.object(forKey: "address_components") as! NSArray
            
            self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
            self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
            self.streetNumber = self.subThoroughfare
            self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
            self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
            self.route = component("route", inArray: addressComponents, ofType: "long_name")
            self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
            self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
            self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
            self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
            self.country =  component("country", inArray: addressComponents, ofType: "long_name")
            self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
            
            
            self.formattedAddress = formattedAddrs;
            
        }
        
        fileprivate func component(_ component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
            let index = inArray.indexOfObject(passingTest:) {obj, idx, stop in
                
                let objDict:NSDictionary = obj as! NSDictionary
                let types:NSArray = objDict.object(forKey: "types") as! NSArray
                let type = types.firstObject as! NSString
                return type.isEqual(to: component as String)
            }
            
            if (index == NSNotFound){
                
                return ""
            }
            
            if (index >= inArray.count) {
                return ""
            }
            
            let type = ((inArray.object(at: index) as! NSDictionary).value(forKey: ofType as String)!) as! NSString
            
            if (type.length > 0){
                
                return type
            }
            return ""
            
        }
        
        fileprivate func getPlacemark() -> CLPlacemark {
            
            var addressDict = [String : AnyObject]()
            
            let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as Array
            
            let kSubAdministrativeArea = "SubAdministrativeArea"
            let kSubLocality           = "SubLocality"
            let kState                 = "State"
            let kStreet                = "Street"
            let kThoroughfare          = "Thoroughfare"
            let kFormattedAddressLines = "FormattedAddressLines"
            let kSubThoroughfare       = "SubThoroughfare"
            let kPostCodeExtension     = "PostCodeExtension"
            let kCity                  = "City"
            let kZIP                   = "ZIP"
            let kCountry               = "Country"
            let kCountryCode           = "CountryCode"
            let kPlaceId               = "PlaceId"
            
            addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
            addressDict[kSubLocality] = self.subLocality as NSString
            addressDict[kState] = self.administrativeAreaCode
            
            addressDict[kStreet] = formattedAddressArray.first! as NSString
            addressDict[kThoroughfare] = self.thoroughfare
            addressDict[kFormattedAddressLines] = formattedAddressArray as AnyObject?
            addressDict[kSubThoroughfare] = self.subThoroughfare
            addressDict[kPostCodeExtension] = "" as AnyObject?
            addressDict[kCity] = self.locality
            
            addressDict[kZIP] = self.postalCode
            addressDict[kCountry] = self.country
            addressDict[kCountryCode] = self.ISOcountryCode
            addressDict[kPlaceId] = self.placeId
            
            let lat = self.latitude.doubleValue
            let lng = self.longitude.doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict as [String : AnyObject]?)
            
            return (placemark as CLPlacemark)
            
            
        }
    }
}
