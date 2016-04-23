//
//  SeaIceTemp.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import Foundation

class SeaIceTemp {
    let lat: Float
    let long: Float
    let temp: Float
    let thick: Float
    let date: NSDate
    
    init(lat: Float, long: Float, temp: Float, thick: Float, date: NSDate) {
        self.lat = lat
        self.long = long
        self.temp = temp
        self.thick = thick
        self.date = date
    }
}