//
//  PolyLines.swift
//  GoogleMap
//
//  Created by Admin on 7/22/17.
//  Copyright © 2017 ChungSama. All rights reserved.
//

import Foundation

struct PolyLines: Codable {
    let routes: [Routes]
}
struct Routes: Codable {
    let overview_polyline: Overview_polyline
}
struct Overview_polyline: Codable {
    let points: String
}
