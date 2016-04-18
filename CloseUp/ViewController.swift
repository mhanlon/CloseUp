//
//  ViewController.swift
//  CloseUp
//
//  Created by Matthew Hanlon on 4/15/16.
//  Copyright © 2016 Q.I. Software. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var long1: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var long2: UILabel!
    
    var imagePicker: UIImagePickerController!
    var clManager: CLLocationManager!
    var cameFrom: NSInteger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressButtonOne(sender: AnyObject) {
        // Take a picture, load it in image view 1, and then dump its CoreLocation values in label1
        // This approach won't work in reality, only as a thought exercise, since we wouldn't be super-
        // graceful with someone moving quickly or someone who presses button 1 and then button 2 in
        // rapid succession.su
        self.cameFrom = 1
        self.clManager.requestLocation()
        takePicture()
    }

    @IBAction func pressButtonTwo(sender: UIButton) {
        // Take a picture, load it in image view 2, and then dump its CoreLocation values in label2
        self.cameFrom = 2
        self.clManager.requestLocation()
        takePicture()
    }
    
    
    func takePicture() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func setupLocation()
    {
        let status = CLLocationManager.authorizationStatus()
        var shouldRequestAuth = false
        switch status {
        case .Restricted:
            return
        case .Denied:
            return
        case .NotDetermined:
            shouldRequestAuth = true
        default:
            break
        }
        
        self.clManager = CLLocationManager()
        self.clManager.delegate = self
        
        self.clManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (shouldRequestAuth) {
            if (CLLocationManager.locationServicesEnabled()) {
                self.clManager.requestWhenInUseAuthorization()
            }
        }

    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)

        
        print("Original image: \(image)")
    }

    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        var asset: PHAsset!;
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:true)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        
        if ( fetchResult.count > 0 )
        {
            asset = fetchResult.lastObject as! PHAsset
            // Now we can write our location to the PHAsset with a PHAssetChangeRequest...
            print(asset)
        }
        
        switch self.cameFrom! {
        case 1:
            self.imageView1.image = image
        case 2:
            self.imageView2.image = image
        default:
            break
        }

        dispatch_async(dispatch_get_main_queue(), {
        let alert = UIAlertController(title: "Success", message: "This image has been saved to your Camera Roll successfully", preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action: UIAlertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion:nil)
        })
    }


    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let coords = "Lat: \(location.coordinate.latitude)"
        let longCoords = "Long: \(location.coordinate.longitude)"
        switch self.cameFrom! {
        case 1:
            self.label1.text = coords
            self.long1.text = longCoords
        case 2:
            self.label2.text = coords
            self.long2.text = longCoords
        default:
            break
        }
    }
}

