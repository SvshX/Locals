//
//  PhotoLibraryCacheController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 02/03/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import Photos


class PhotoLibraryCacheController {

    private var cachedIndices = NSIndexSet()
    var cachePreheatSize: Int
    var imageCache: PHCachingImageManager
    var images: PHFetchResult<PHAsset>!
    var targetSize = CGSize(width: 200, height: 200)
    var contentMode = PHImageContentMode.aspectFill
    
    init(imageManager: PHCachingImageManager, images: PHFetchResult<AnyObject>, preheatSize: Int = 1) {
        self.cachePreheatSize = preheatSize
        self.imageCache = imageManager
        self.images = images as! PHFetchResult<PHAsset>
    }
    
    func updateVisibleCells(visibleCells: [NSIndexPath]) {
        let updatedCache = NSMutableIndexSet()
        for path in visibleCells {
            updatedCache.add(path.item)
        }
        let minCache = max(0, updatedCache.firstIndex - cachePreheatSize)
        let maxCache = min(images.count - 1, updatedCache.lastIndex + cachePreheatSize)
        updatedCache.add(in: NSMakeRange(minCache, maxCache - minCache + 1))
        
        // Which indices can be chucked?
        self.cachedIndices.enumerate({
            index, _ in
            if !updatedCache.contains(index) {
                let asset: PHAsset! = self.images[index]
                self.imageCache.stopCachingImages(for: [asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)
                print("Stopping caching image \(index)")
            }
        })
        
        // And which are new?
        updatedCache.enumerate({
            index, _ in
            if !self.cachedIndices.contains(index) {
                let asset: PHAsset! = self.images[index]
                self.imageCache.startCachingImages(for: [asset], targetSize: self.targetSize, contentMode: self.contentMode, options: nil)
                print("Starting caching image \(index)")
            }
        })
        cachedIndices = NSIndexSet(indexSet: updatedCache as IndexSet)
    }
}
