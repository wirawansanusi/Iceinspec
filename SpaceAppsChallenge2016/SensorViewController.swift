//
//  SensorViewController.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import UIKit
import CoreBluetooth
import MagicalRecord

class SensorViewController: UIViewController, BluetoothSerialDelegate {
    
//MARK: IBActions
    
    @IBOutlet weak var hum: UILabel!
    @IBOutlet weak var cel: UILabel!
    @IBOutlet weak var fah: UILabel!
    @IBOutlet weak var heat: UILabel!
    @IBOutlet weak var thick: UILabel!
    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
//MARK: Variables
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral!
    
    var selectedSensors: SensorsTemp?
    
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serial.delegate = self
        
        if serial.state != .PoweredOn {
            title = "Bluetooth not turned on"
            return
        }
        
        serial.connectToPeripheral(selectedPeripheral)
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(SensorViewController.connectTimeOut), userInfo: nil, repeats: false)
        
    }
    
    /// Should be called 10s after we've begun scanning
    func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
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
    
//MARK: BluetoothSerialDelegate
    
    func serialDidDisconnect(peripheral: CBPeripheral, error: NSError?) {
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
        
        var dataArr = message.characters.split{$0 == " "}.map(String.init)
        
        let datetime = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        hum.text = "\(dataArr[0])g/m3";
        cel.text = "\(dataArr[1]) C"
        fah.text = "\(dataArr[2]) F"
        heat.text = "\(dataArr[3])"
        date.text = dateFormatter.stringFromDate(datetime)
        
        if let lang = latitude {
            lat.text = "\(lang)"
        }
        
        if let longi = longitude {
            long.text = "\(longi)"
        }
        
        let humStr = NSString(string: dataArr[0]).floatValue
        let celStr = NSString(string: dataArr[1]).floatValue
        let fahStr = NSString(string: dataArr[2]).floatValue
        let heatStr = NSString(string: dataArr[3]).floatValue
        fetchData(humStr, cel: celStr, fah: fahStr, heat: heatStr, date: datetime)
    }
    
    func fetchData(hum: Float, cel: Float, fah: Float, heat: Float, date: NSDate) {
        
        var thickStr: Float = 0
        
        let predicate = NSPredicate(format: "temp = %d", cel)
        let seaIce = SeaIce.MR_findFirstWithPredicate(predicate)
        if let seaIceTemp = seaIce {
            thick.text = "\(seaIceTemp.thick)"
            thickStr = seaIceTemp.thick!.floatValue
        }
        
        selectedSensors = SensorsTemp(cel: cel, fah: fah, heat: heat, hum: hum, lat: Float(latitude!), long: Float(longitude!), thick: thickStr, date: date)
    }
    
    func serialDidConnect(peripheral: CBPeripheral) {
        print(peripheral);
    }
    
//MARK: IBActions
    
    @IBAction func didPressSaveBtn(sender: AnyObject) {
        if let sensor = selectedSensors {
            
            MagicalRecord.saveWithBlock({ (localContext: NSManagedObjectContext!) -> Void in
                
                let sensorEntity = Sensors.MR_createEntityInContext(localContext)
                sensorEntity?.cel = sensor.cel
                sensorEntity?.fah = sensor.fah
                sensorEntity?.heat = sensor.heat
                sensorEntity?.hum = sensor.hum
                sensorEntity?.lat = sensor.lat
                sensorEntity?.long = sensor.long
                sensorEntity?.thick = sensor.thick
                sensorEntity?.date = sensor.date
                
            }) { (contextDidSave: Bool, error: NSError?) -> Void in
                
                let alertController = UIAlertController(title: "Save Completed", message: "The data has been saved", preferredStyle: UIAlertControllerStyle.Alert)
                let alertBtn = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(alertBtn)
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
}
