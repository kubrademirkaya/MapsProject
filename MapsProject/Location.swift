//
//  Location.swift
//  MapsProject
//
//  Created by Kübra Demirkaya on 10.03.2023.
//

import Foundation
import UIKit

class Location {
    
    var locationName : String
    var id : UUID
    
    init(locationName: String, id: UUID) {
        self.locationName = locationName
        self.id = id
    }
    
}
