//
//  MapViewController.swift
//  SpaceAppsChallenge2016
//
//  Created by wirawan sanusi on 4/23/16.
//  Copyright © 2016 Protogres. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        centerMapOnLocation(CLLocation(latitude: latitude!, longitude: longitude!))
        addAnnotationForDirection()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotationForDirection() {
        
        let sensors = Sensors.MR_findAll() as! [Sensors]
        
        for sensor in sensors {
            
            let datetime = sensor.date!
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let annotation = Annotation(title: "Temperature: \(sensor.cel!) with thickness: \(sensor.thick!)",
                                        locationName: "Date: \(dateFormatter.stringFromDate(datetime)) on Lat: \(sensor.lat!) & Long: \(sensor.long!)) ",
                                        discipline: "Map",
                                        coordinate: CLLocationCoordinate2D(latitude: sensor.lat!.doubleValue, longitude: sensor.long!.doubleValue))
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }

    @IBAction func didPressSync(sender: AnyObject) {
        
        //55.662352, 12.596242
        let sensor = Sensors.MR_findFirst()
        
        let datetime = sensor!.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let annotation = Annotation(title: "Temperature: \(sensor!.cel!) with thickness: \(sensor!.thick!)",
                                    locationName: "Date: \(dateFormatter.stringFromDate(datetime!)) on Lat: \(55.662352) & Long: \(12.596242)) ",
                                    discipline: "Map",
                                    coordinate: CLLocationCoordinate2D(latitude: 55.662352, longitude: 12.596242))
        mapView.addAnnotation(annotation)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
