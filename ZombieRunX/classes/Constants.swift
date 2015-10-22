//
//  Constants.swift
//  ZombieRunX
//
//  Created by Henry Spindell on 10/22/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation

#if DEBUG
let __DEV_MODE = true
#else
let __DEV_MODE = false
#endif

let kParseApplicationID = __DEV_MODE ?  "fEzVacO5gJMMaZBveiq5WWacZhqacHX6lw3CimcB" : "ZVDFIiZs7dvGqL8eRaKT0mdNMxCwMCzaiTu2yVlO"
let kParseClientKey =  __DEV_MODE ? "7ZW27v8E8ibfqWHwRKCFCJF79qS6lLBVxgHbBu2O" : "SnXEAMgw0LRKufUzBmnMOtFRtcBgsK7Pz8W7gQCn"