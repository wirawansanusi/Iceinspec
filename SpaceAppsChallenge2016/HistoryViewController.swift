//
//  HistoryViewController.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {

    var sensors = [Sensors]()
    
    override func viewDidLoad() {
        fetchSensors()
    }
    
    func fetchSensors() {
        let sensors = Sensors.MR_findAllSortedBy("date", ascending: true) as! [Sensors]
        self.sensors = sensors
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let sensor = sensors[indexPath.row]
        let date = sensor.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        
        cell.textLabel?.text = "H: \(sensor.hum!); C: \(sensor.cel!); F: \(sensor.fah!); T: \(sensor.thick!); H: \(sensor.heat!);"
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(date!)
        
        return cell
    }
}
