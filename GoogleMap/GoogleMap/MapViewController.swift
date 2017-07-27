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
    
    var startLocation = CLLocationCoordinate2D()
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
        resultNotification()
    }
    
    func resultNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(drawPolyLines), name: notificationJSON, object: nil)
    }
    @objc func drawPolyLines() {
        guard let points = DataServices.shared.polyLines?.routes[0].overview_polyline.points else {return}
        guard let path = GMSPath(fromEncodedPath: points) else {
            return
        }
        DispatchQueue.main.async {
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .blue
            polyline.strokeWidth = 4.0
            polyline.map = self.mapView
        }
    }
    func markLocation(location: CLLocationCoordinate2D){
        marker.map = self.mapView
        marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        marker.snippet = "Population: 8,174,100"
        marker.title = "Your location"
        marker.icon = GMSMarker.markerImage(with: .black)
    }
    func markDestination(destination: CLLocationCoordinate2D){
        infoMarker.map = self.mapView
        infoMarker.position = CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
        infoMarker.title = "Destination"
        infoMarker.opacity = 0.8
        infoMarker.infoWindowAnchor.y = 0
        mapView.selectedMarker = infoMarker
    }
}

// Delegates to handle event for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        startLocation = location.coordinate
        markLocation(location: startLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Error\(error)")
    }
}
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        endLocation = coordinate
        markLocation(location: startLocation)
        markDestination(destination: coordinate)
        DataServices.shared.drawPath(start: startLocation, end: endLocation)
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
    }
}

