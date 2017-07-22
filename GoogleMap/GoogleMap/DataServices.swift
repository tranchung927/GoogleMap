//
//  DataServices.swift
//  GoogleMap
//
//  Created by Admin on 7/19/17.
//  Copyright © 2017 ChungSama. All rights reserved.
//

import Foundation
import CoreLocation

let notificationJSON = Notification.Name.init("notificationJSON")
class DataServices {
    static let shared: DataServices = DataServices()
    
    private var _polyLines: PolyLines?
    var polyLines: PolyLines? {
        get {
            if _polyLines == nil {
                update()
            }
            return _polyLines
        }
        set {
            _polyLines = newValue
        }
    }
    func update() {
        print("Nodata")
    }
    func drawPath(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let origin = "\(start.latitude),\(start.longitude)"
        let destination = "\(end.latitude),\(end.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=AIzaSyDOn7QCEOzkfEOkzBQgxOVYtXrVQtYR4Vg&mode=driving"
        guard let urlRequest = URL(string: url) else {return}
        DispatchQueue.main.async {
            self.requestAPI(request: urlRequest)
        }
    }
    
    func requestAPI(request: URL) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {return}
            do {
                self._polyLines = try JSONDecoder().decode(PolyLines.self, from: data)
                NotificationCenter.default.post(name: notificationJSON, object: nil)
            } catch let error {
                print("\(error)")
            }
        }
        task.resume()
    }
}
