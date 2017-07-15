//
//  ViewController.swift
//  GoogleMap
//
//  Created by Admin on 7/15/17.
//  Copyright © 2017 ChungSama. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import SystemConfiguration

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    // Initialize the location manager
    var locationManager: CLLocationManager = {
       var locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 500
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        return locationManager
    }()
    
    // Initialize map view
    var zoomLevel: Float = 15.0
    var marker = GMSMarker()
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isInternetAvailable() == true
        {
            print("Connected")
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(ok)
            controller.addAction(cancel)
            
            present(controller, animated: true, completion: nil)
        }
    }
}

// Delegates to handle event for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        marker.map = self.mapView
        marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        marker.title = "Your location"
        marker.snippet = "Population: 8,174,100"
        marker.icon = GMSMarker.markerImage(with: .black)
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error\(error)")
    }
}

extension MapViewController {
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
