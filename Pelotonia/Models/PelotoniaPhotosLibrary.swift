//
//  PelotoniaPhotosLibrary.swift
//  Pelotonia
//
//  Created by Mark Harris on 4/9/16.
//
//

import Photos

class PelotoniaPhotosLibrary: NSObject {
    
    let albumName:String = "Pelotonia"
    var collection:PHAssetCollection!
    
    @objc func library() -> PHPhotoLibrary?
    {
        if (PHPhotoLibrary.authorizationStatus() != .notDetermined) {
            return PHPhotoLibrary.shared();
        }
        else {
            return nil;
        }
    }

    @objc func createAlbum(_ completion: @escaping (PHAssetCollection) -> Void) {
        
        var assetCollectionPlaceholder: PHObjectPlaceholder!
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            assetCollectionPlaceholder = request.placeholderForCreatedAssetCollection
            },
            completionHandler: { (success:Bool, error:Error?) in
                if (success) {
                    let result:PHFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                    self.collection = result.firstObject
                    completion(self.collection)
                }
        })
    }

    @objc func album(_ completion: @escaping (PHAssetCollection) -> Void) {
        if (self.collection == nil) {
            let options:PHFetchOptions = PHFetchOptions()
            options.predicate = NSPredicate(format: "estimatedAssetCount >= 0")
            
            let userAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: options)
            
            userAlbums.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    if (obj.localizedTitle == self.albumName) {
                        self.collection = obj
                        stop.initialize(to: true)
                    }
                }
            })
            if (self.collection == nil) {
                self.createAlbum(completion)
            }
            else {
                completion(self.collection)
            }
        }
        else {
            completion(self.collection)
        }
    }
    
    @objc func saveImage(_ image : UIImage, completion: @escaping (URL?, Error?) -> Void) {
        
        library()!.performChanges({ () -> Void in
            let createAssetRequest  = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder  = createAssetRequest.placeholderForCreatedAsset!
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.collection)
    
            albumChangeRequest!.addAssets([assetPlaceholder] as NSArray)
            })
            { (success : Bool, error : Error?) -> Void in
                if (success) {
                    completion(nil, nil)
                }
                else {
                    completion(nil, error)
                }
            }
    }
    
    @objc func images(_ completion:@escaping (PHFetchResult<AnyObject>) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        self.album { (pelotoniaAlbum : PHAssetCollection) -> Void in
            let images: PHFetchResult = PHAsset.fetchAssets(in: pelotoniaAlbum, options: options)
            completion(images as! PHFetchResult<AnyObject>)
        }
    }
    
}


