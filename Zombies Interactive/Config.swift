//
//  Config.swift
//  Zombies Interactive
//
//  Created by Olivia Barnett on 1/25/18.
//  Copyright © 2018 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import UIKit

struct Config {
    static let DEBUG = true
    static var URL = ""
    public static let sharedConfig = Config()
    
    init() {
        if Config.DEBUG {
            Config.URL = "http://10.105.74.198:5000"
        } else {
            Config.URL = "https://hs4x.herokuapp.com"
        }
    }
}
