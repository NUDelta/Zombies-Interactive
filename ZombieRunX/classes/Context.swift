//
//  Context.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 12/8/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation

struct Context {
    var timeElapsed: NSTimeInterval // experience time, not real time
    var timeRemaining: NSTimeInterval
    var speed: CLLocationSpeed
    var location: CLLocationCoordinate2D
}