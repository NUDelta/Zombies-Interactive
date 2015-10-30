//
//  Extensions.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/8/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation

extension Double {
    var minutesToSeconds : Float { return Float(self * 60) }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    func randomItemIndex() -> Int {
        return Int(arc4random_uniform(UInt32(self.count)))
    }
}