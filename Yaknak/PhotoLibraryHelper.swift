//
//  PhotoLibraryHelper.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/02/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import Photos


class PhotoLibraryHelper: NSObject {
    
    static let shared = PhotoLibraryHelper()
  //  var photos: PHFetchResult<AnyObject>?
  //  var assetThumbnailSize: CGSize!
  //  var imageArray = [UIImage]()
  //  var fetchResult : PHFetchResult<AnyObject>
   // var askForSettings: Bool = false
 //   let imageManager = PHCachingImageManager()
 //   var cacheController: PhotoLibraryCacheController!
    
    
    var onPermissionReceived: ((_ received: Bool)->())?
 //   var onPhotosLoaded: ((_ photos: [UIImage], _ result: PHFetchResult<PHAsset>?
 //   )->())?
    var onSettingsPrompt: (()->())?
    
    
    override init() {
        super.init()
        
     //   fetchResult = PHAsset.fetchAssets(with: .image, options: nil) as! PHFetchResult<AnyObject>
     //   cacheController = PhotoLibraryCacheController(imageManager: imageManager, images: fetchResult, preheatSize: 1)
     //   PHPhotoLibrary.shared().register(self)
     //   self.assetThumbnailSize = CGSize(200, 200)
      //  self.askForSettings = false
    }
    
    
    func requestPhotoPermission() {
        
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            //  self.loadAssets()
            self.onPermissionReceived?(true)
        }
        else { PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            
            switch (status) {
                
            case .authorized:
                self.onPermissionReceived?(true)
                break
                
            case .denied:
                
                if (UserDefaults.standard.bool(forKey: "askForSettings_photo")) {
                    self.onSettingsPrompt?()
                    UserDefaults.standard.removeObject(forKey: "askForSettings_photo")
                }
                else {
                    self.onPermissionReceived?(false)
                    UserDefaults.standard.set(true, forKey: "askForSettings_photo")
                }
                
                break
            case .notDetermined:
                
                // Access has not been determined.
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        self.onPermissionReceived?(true)
                    }
                        
                    else {
                        self.onPermissionReceived?(false)
                    }
                })
                
                break
                
            default:
                break
                
            }
            
        })
            
        }
        
    }
 /*
    
    func loadAssets() {
        
        
        let imgMananager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult!.count > 0 {
            
            for i in 0..<fetchResult!.count {
                imgMananager.requestImage(for: fetchResult!.object(at: i) , targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { image, error in
                    self.imageArray.append(image!)
                    
                })
            }
            if imageArray.count > 0 {
                self.onPhotosLoaded?(imageArray, self.fetchResult)
            }
        }
        else {
            if imageArray.count > 0 {
                self.onPhotosLoaded?(imageArray, self.fetchResult)
            }
            //  collectionView.reloadData()
        }
        
        
        // Sorting condition
        //      let options = PHFetchOptions()
        //      options.sortDescriptors = [
        //         NSSortDescriptor(key: "creationDate", ascending: false)
        //     ]
        
        //     photos = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        /*
         if photos!.count > 0 {
         
         collectionView.reloadData()
         collectionView.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
         }
         */
        
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        
    }
   */
    
    
}
