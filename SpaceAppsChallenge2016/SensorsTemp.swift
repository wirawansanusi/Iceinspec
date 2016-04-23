//
//  SensorsTemp.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import Foundation

class SensorsTemp {
    let cel: Float
    let fah: Float
    let heat: Float
    let hum: Float
    let lat: Float
    let long: Float
    let thick: Float
    let date: NSDate
    
    init(cel: Float, fah: Float, heat: Float, hum: Float, lat: Float, long: Float, thick: Float, date: NSDate) {
        self.cel = cel
        self.fah = fah
        self.heat = heat
        self.hum = hum
        self.lat = lat
        self.long = long
        self.thick = thick
        self.date = date
    }
}