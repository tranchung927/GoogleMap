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
    
    var startLocation = CLLocation()
    var endLocation = CLLocationCoordinate2D()
    
    // Declare GMSMarker instance at the class level.
    let infoMarker = GMSMarker()
    
    // Initialize map view
    var zoomLevel: Float = 15.0
    var marker = GMSMarker()
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
    }
    func polyLines(start: CLLocation, end: CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        path.addLatitude(start.coordinate.latitude, longitude: start.coordinate.longitude)
        path.addLatitude(end.latitude, longitude: end.longitude)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }
}

// Delegates to handle event for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        startLocation = location
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
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoMarker.position = coordinate
        endLocation = coordinate
        infoMarker.title = "Destination"
        infoMarker.opacity = 0.8
        infoMarker.infoWindowAnchor.y = 0
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        
        polyLines(start: startLocation, end: endLocation)
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
    }
}

