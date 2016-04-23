//
//  Sensors+CoreDataProperties.swift
//  
//
//  Created by wirawan sanusi on 4/23/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sensors {

    @NSManaged var hum: NSNumber?
    @NSManaged var cel: NSNumber?
    @NSManaged var fah: NSNumber?
    @NSManaged var heat: NSNumber?
    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var thick: NSNumber?
    @NSManaged var date: NSDate?

}
