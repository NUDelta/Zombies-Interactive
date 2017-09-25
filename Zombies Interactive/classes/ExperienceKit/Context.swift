//
//  Context.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 12/8/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation

struct Context {
    var timeElapsed: TimeInterval? // experience time, not real time
    var timeRemaining: TimeInterval?
    var speed: CLLocationSpeed?
    var location: CLLocationCoordinate2D?
    var heading: CLLocationDirection?
}
