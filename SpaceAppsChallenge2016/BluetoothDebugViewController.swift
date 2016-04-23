//
//  BluetoothDebugViewController.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import UIKit
import CoreBluetooth
import MagicalRecord
import SwiftyJSON

class BluetoothDebugViewController: UITableViewController,  BluetoothSerialDelegate {
    
//MARK: IBActions
    
    @IBOutlet weak var scanBtn: UIBarButtonItem!
    
//MARK: Variables
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parseJSON()
        
        scanBtn.enabled = true
        serial = BluetoothSerial(delegate: self)
        
        if serial.state != .PoweredOn {
            return
        }
        
        // start scanning and schedule the time out
        serial.startScan()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(BluetoothDebugViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    /// Should be called 10s after we've begun scanning
    func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        scanBtn.enabled = true
    }
    
    /// Should be called 10s after we've begun connecting
    func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
    }
    
    func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            print("Disconnect: \(serial.connectedPeripheral!.name)")
        } else if serial.state == .PoweredOn {
            print("Power on")
        } else {
        }
    }
    
    func performImport(seaIceTemps: [SeaIceTemp]) {
        
        MagicalRecord.saveWithBlock({ (localContext: NSManagedObjectContext!) -> Void in
            
            for seaIceTemp in seaIceTemps {
                let seaIce = SeaIce.MR_createEntityInContext(localContext)
                seaIce?.lat = seaIceTemp.lat
                seaIce?.long = seaIceTemp.long
                seaIce?.temp = seaIceTemp.temp
                seaIce?.thick = seaIceTemp.thick
                seaIce?.date = seaIceTemp.date
            }
            
        }) { (contextDidSave: Bool, error: NSError?) -> Void in
            
            print("Data import success : \(contextDidSave)")
        }
        
    }
    
    func parseJSON() {
        var seaIceTemps = [SeaIceTemp]()
        if let path = NSBundle.mainBundle().pathForResource("data", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    for jsonObjSingle in jsonObj {
                        
                        var (_,json) = jsonObjSingle
                        let lat = json["lat"].float!
                        let long = json["lon"].float!
                        let thick = json["thickness"].float!
                        let temp = json["temp"].float!
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd"
                        let date = dateFormatter.dateFromString("\(json["date"].int!)")
                        
                        let seaIceTemp = SeaIceTemp(lat: lat, long: long, temp: temp, thick: thick, date: date!)
                        seaIceTemps.append(seaIceTemp)
                    }
                    
                    performImport(seaIceTemps)
                } else {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }

    
//MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peripherals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = peripherals[indexPath.row].peripheral.name
        
        return cell
    }
    
//MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // the user has selected a peripheral, so stop scanning and proceed to the next view
        serial.stopScan()
        selectedPeripheral = peripherals[indexPath.row].peripheral
        performSegueWithIdentifier("showSensorViewController", sender: self)
    }
    
//MARK: BluetoothSerialDelegate
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append(peripheral: peripheral, RSSI: theRSSI)
        peripherals.sortInPlace { $0.RSSI < $1.RSSI }
        tableView.reloadData()
    }
    
    func serialDidFailToConnect(peripheral: CBPeripheral, error: NSError?) {
        scanBtn.enabled = true
    }
    
    func serialDidDisconnect(peripheral: CBPeripheral, error: NSError?) {
        scanBtn.enabled = true
        
        print("bluetooth disconnected")
    }
    
    func serialIsReady(peripheral: CBPeripheral) {
        NSNotificationCenter.defaultCenter().postNotificationName("reloadStartViewController", object: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func serialDidChangeState(newState: CBCentralManagerState) {
        reloadView()
        if newState != .PoweredOn {
            print("bluetooth connected")
        NSNotificationCenter.defaultCenter().postNotificationName("reloadStartViewController", object: self)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func serialDidReceiveString(message: String) {
        print(message)
    }
    
    func serialDidConnect(peripheral: CBPeripheral) {
        print(peripheral);
    }
    
//MARK: IBActions
    
    @IBAction func scanForPeripheral(sender: UIBarButtonItem) {
        // empty array an start again
        peripherals = []
        tableView.reloadData()
        scanBtn.enabled = false
        serial.startScan()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(BluetoothDebugViewController.scanTimeOut), userInfo: nil, repeats: false)
    }


//MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSensorViewController" {
            let destination = segue.destinationViewController as! SensorViewController
            destination.selectedPeripheral = selectedPeripheral
        }
    }
}
